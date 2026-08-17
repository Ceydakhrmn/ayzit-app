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

console.log('\n🟡 #3 — Username enumerasyonu');
await check("Tek username get edilebilir (kayıt için)", assertSucceeds(getDoc(doc(B, 'usernames/ayse'))));
await check("Tüm username tablosu LİSTELENEMEZ", assertFails(getDocs(collection(B, 'usernames'))));

console.log(`\n──────────────\nSONUÇ: ${pass} geçti, ${fail} kaldı`);
await testEnv.cleanup();
process.exit(fail === 0 ? 0 : 1);
