// ============================================================
// Ayzit Firestore güvenlik kuralları — sızma testi
// Gerçek ../firestore.rules dosyasını emülatöre karşı test eder.
// "A" = hesap sahibi, "B" = saldırgan (başka kullanıcı).
//
// Çalıştırma:  npm test   (firestore_rules_test/ klasöründe)
// Kuralları her değiştirdiğinde çalıştır → regresyon koruması.
// ============================================================
import fs from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, getDocs,
  writeBatch, serverTimestamp, increment,
} from 'firebase/firestore';

// pretest adımı ../firestore.rules dosyasını buraya kopyalar (bkz. package.json)
const rules = fs.readFileSync('firestore.rules', 'utf8');

const testEnv = await initializeTestEnvironment({
  projectId: 'ayzit-test',
  firestore: { rules, host: '127.0.0.1', port: 8080 },
});

let pass = 0, fail = 0;
async function check(name, promise) {
  try {
    await promise;
    console.log(`  ✅ ${name}`);
    pass++;
  } catch (e) {
    console.log(`  ❌ ${name}\n       ${e.message}`);
    fail++;
  }
}

// ── Seed: kurallar devre dışıyken A'nın verisini oluştur ──
await testEnv.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  await setDoc(doc(db, 'users/userA'), {
    uid: 'userA', email: 'a@example.com', username: 'ayse',
    displayName: 'Ayse', avatarSeed: 'ayse', appMode: 'hamileTakip',
    postCount: 0, likesReceived: 0,
  });
  await setDoc(doc(db, 'usernames/ayse'), { uid: 'userA' });
  await setDoc(doc(db, 'usernames/zeynep'), { uid: 'userC' });
  await setDoc(doc(db, 'usernames/bku'), { uid: 'userB' });
  // C'nin A'ya bıraktığı eski bir beğeni kaydı (silme testi için)
  await setDoc(doc(db, 'users/userA/activity/like_post1_userC'), {
    type: 'like', actorId: 'userC', actorUsername: 'zeynep',
    postId: 'post1', createdAt: new Date(), read: false, pushed: false,
  });
  await setDoc(doc(db, 'posts/post1'), {
    authorId: 'userA', authorUsername: 'ayse', authorAvatarSeed: 'ayse',
    content: 'Merhaba', createdAt: new Date(), hidden: false,
    likeCount: 5, commentCount: 2, edited: false,
  });
  // Yorumlar: biri A'ya, biri B'ye ait (hesap silme testi için)
  await setDoc(doc(db, 'posts/post1/comments/cmtA'), {
    authorId: 'userA', authorUsername: 'ayse', authorAvatarSeed: 'ayse',
    content: 'A yorumu', createdAt: new Date(), hidden: false,
  });
  await setDoc(doc(db, 'posts/post1/comments/cmtB'), {
    authorId: 'userB', authorUsername: 'bku', authorAvatarSeed: 'bku',
    content: 'B yorumu', createdAt: new Date(), hidden: false,
  });
});

const A = testEnv.authenticatedContext('userA', { email_verified: true }).firestore();
const B = testEnv.authenticatedContext('userB', { email_verified: true }).firestore();

console.log('\n🔴 #1 — Profil gizliliği (e-posta + sağlık durumu)');
await check("A kendi profilini okuyabilir", assertSucceeds(getDoc(doc(A, 'users/userA'))));
await check("B, A'nin profilini OKUYAMAZ", assertFails(getDoc(doc(B, 'users/userA'))));
await check("B, A'nin profilini DEĞİŞTİREMEZ", assertFails(updateDoc(doc(B, 'users/userA'), { email: 'hack@x.com' })));

console.log('\n🟠 #2 — Gönderi sayaç/yazar manipülasyonu');
await check("B beğeni sayacını +1 yapabilir (normal)", assertSucceeds(updateDoc(doc(B, 'posts/post1'), { likeCount: 6 })));
await check("B likeCount'u 999999 YAPAMAZ", assertFails(updateDoc(doc(B, 'posts/post1'), { likeCount: 999999 })));
await check("B, YAZAR ADINI değiştiremez", assertFails(updateDoc(doc(B, 'posts/post1'), { likeCount: 6, authorUsername: 'sahte' })));
await check("B, gönderi İÇERİĞİNİ değiştiremez", assertFails(updateDoc(doc(B, 'posts/post1'), { content: 'ele geçirildi' })));
await check("B, A'nin gönderisini silemez", assertFails(deleteDoc(doc(B, 'posts/post1'))));

console.log('\n🟢 #4 — Yorum sahipliği & hesap silme temizliği');
await check("B kendi yorumunu silebilir", assertSucceeds(deleteDoc(doc(B, 'posts/post1/comments/cmtB'))));
await check("B, A'nin yorumunu SİLEMEZ", assertFails(deleteDoc(doc(B, 'posts/post1/comments/cmtA'))));
await check("Yorum silinince commentCount -1 düşürülebilir", assertSucceeds(updateDoc(doc(B, 'posts/post1'), { commentCount: 1 })));

console.log('\n🔔 #5 — Etkinlik (yorum / beğeni bildirimi) sahteciliği');
const activity = (overrides = {}) => ({
  type: 'comment', actorId: 'userB', actorUsername: 'bku', postId: 'post1',
  commentId: 'cmtNew', text: 'Güzel paylaşım', createdAt: serverTimestamp(),
  read: false, pushed: false, ...overrides,
});
function commentBatch(db, cmtId, act, actId = `comment_${cmtId}`) {
  const b = writeBatch(db);
  b.set(doc(db, `posts/post1/comments/${cmtId}`), {
    authorId: 'userB', authorUsername: 'bku', authorAvatarSeed: 'bku',
    content: 'Güzel paylaşım', createdAt: new Date(), hidden: false,
  });
  b.update(doc(db, 'posts/post1'), { commentCount: increment(1) });
  b.set(doc(db, `users/userA/activity/${actId}`), act);
  return b.commit();
}
await check("B yorum yapınca A'ya kayıt bırakabilir (normal)",
  assertSucceeds(commentBatch(B, 'cmtNew', activity())));
await check("Gerçek yorum olmadan kayıt YAZILAMAZ",
  assertFails(setDoc(doc(B, 'users/userA/activity/comment_yok'),
    activity({ commentId: 'yok' }))));
await check("Başkasının kullanıcı adıyla (ayse) kayıt YAZILAMAZ",
  assertFails(commentBatch(B, 'cmt2', activity({ commentId: 'cmt2', actorUsername: 'ayse' }))));
await check("actorId başkası olarak YAZILAMAZ",
  assertFails(commentBatch(B, 'cmt3', activity({ commentId: 'cmt3', actorId: 'userC' }))));
await check("pushed:true ile YAZILAMAZ (bildirim atlatılamaz)",
  assertFails(commentBatch(B, 'cmt4', activity({ commentId: 'cmt4', pushed: true }))));
await check("Kimliği uydurulmuş kayıt YAZILAMAZ",
  assertFails(commentBatch(B, 'cmt5', activity({ commentId: 'cmt5' }), 'rastgele')));
await check("Kendi paylaşımına kayıt YAZILAMAZ (A → A)",
  assertFails(setDoc(doc(A, 'users/userA/activity/comment_cmtA'),
    activity({ actorId: 'userA', actorUsername: 'ayse', commentId: 'cmtA' }))));

function likeBatch(db, actId, act) {
  const b = writeBatch(db);
  b.set(doc(db, 'posts/post1/likes/userB'), { createdAt: serverTimestamp() });
  b.update(doc(db, 'posts/post1'), { likeCount: increment(1) });
  b.set(doc(db, `users/userA/activity/${actId}`), act);
  return b.commit();
}
const likeAct = { type: 'like', actorId: 'userB', actorUsername: 'bku',
  postId: 'post1', createdAt: serverTimestamp(), read: false, pushed: false };
await check("Beğeni kimliği uydurulamaz",
  assertFails(likeBatch(B, 'like_post1_userX', likeAct)));
await check("B beğenince A'ya kayıt bırakabilir (normal)",
  assertSucceeds(likeBatch(B, 'like_post1_userB', likeAct)));

await check("A kendi kayıtlarını okuyabilir",
  assertSucceeds(getDocs(collection(A, 'users/userA/activity'))));
await check("B, A'nin kayıtlarını OKUYAMAZ",
  assertFails(getDocs(collection(B, 'users/userA/activity'))));
await check("A okundu işaretleyebilir",
  assertSucceeds(updateDoc(doc(A, 'users/userA/activity/like_post1_userB'), { read: true })));
await check("A 'pushed' alanını DEĞİŞTİREMEZ",
  assertFails(updateDoc(doc(A, 'users/userA/activity/like_post1_userB'), { pushed: true })));
await check("B, okundu bilgisini DEĞİŞTİREMEZ",
  assertFails(updateDoc(doc(B, 'users/userA/activity/like_post1_userB'), { read: false })));
await check("B beğeniyi geri alınca kendi kaydını silebilir",
  assertSucceeds(deleteDoc(doc(B, 'users/userA/activity/like_post1_userB'))));
await check("Olmayan kaydı silmek zararsız (eski beğeni geri alma)",
  assertSucceeds(deleteDoc(doc(B, 'users/userA/activity/like_post2_userB'))));
await check("B, C'nin kaydını SİLEMEZ",
  assertFails(deleteDoc(doc(B, 'users/userA/activity/like_post1_userC'))));
await check("A kendi kaydını silebilir",
  assertSucceeds(deleteDoc(doc(A, 'users/userA/activity/like_post1_userC'))));

console.log('\n🟡 #3 — Username enumerasyonu');
await check("Tek username get edilebilir (kayıt için)", assertSucceeds(getDoc(doc(B, 'usernames/ayse'))));
await check("Tüm username tablosu LİSTELENEMEZ", assertFails(getDocs(collection(B, 'usernames'))));

console.log(`\n──────────────\nSONUÇ: ${pass} geçti, ${fail} kaldı`);
await testEnv.cleanup();
process.exit(fail === 0 ? 0 : 1);
