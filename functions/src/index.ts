// =============================================
// functions/src/index.ts
// Cloud Functions for Lunora:
//   • onCommentCreated  — push to post author when a new comment lands
//   • scheduledCycleReminders — daily sweep for period start / end pushes
//   • scheduledExerciseReminder — twice-weekly exercise reminder
//   • onPostLikeWrite — keep users/{uid}.likesReceived in sync
// =============================================

import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { setGlobalOptions } from 'firebase-functions/v2';

setGlobalOptions({region: "europe-west1"}); // Amsterdam, closest to Istanbul with FCM support

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// ── Helpers ─────────────────────────────────────────────
type NotificationPrefs = {
  commentOnPost?: boolean;
  periodStart?: boolean;
  periodEnd?: boolean;
  exerciseReminder?: boolean;
};

type LocalizedCopy = { title: string; body: string };
type CopyMap = Record<string, LocalizedCopy>;

function pickCopy(locale: string | undefined, copy: CopyMap): LocalizedCopy {
  const l = (locale || 'tr').toLowerCase();
  return copy[l] || copy.tr || copy.en;
}

async function sendToUser(uid: string, payload: LocalizedCopy): Promise<void> {
  const tokensSnap = await db
    .collection('users')
    .doc(uid)
    .collection('fcmTokens')
    .get();
  if (tokensSnap.empty) return;

  const tokens = tokensSnap.docs
    .map((d) => d.data().token as string | undefined)
    .filter((t): t is string => Boolean(t));
  if (tokens.length === 0) return;

  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: {
      title: payload.title,
      body: payload.body,
    },
  });

  // Clean up stale tokens
  const batch = db.batch();
  response.responses.forEach((res, idx) => {
    if (!res.success) {
      const tokenDocId = tokensSnap.docs[idx].id;
      batch.delete(
        db
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(tokenDocId),
      );
    }
  });
  await batch.commit().catch(() => undefined);
}

// ── 1. onCommentCreated → notify post author ─────────────
export const onCommentCreated = onDocumentCreated(
  'posts/{postId}/comments/{commentId}',
  async (event) => {
    const { postId } = event.params as { postId: string; commentId: string };
    const comment = event.data?.data();
    if (!comment) return;

    const postSnap = await db.collection('posts').doc(postId).get();
    const post = postSnap.data();
    if (!post) return;

    const authorId = post.authorId as string;
    if (!authorId || authorId === comment.authorId) return; // don't notify self

    const authorSnap = await db.collection('users').doc(authorId).get();
    const authorData = authorSnap.data();
    if (!authorData) return;

    const prefs = (authorData.preferences?.notifications ?? {}) as NotificationPrefs;
    if (prefs.commentOnPost === false) return;

    const locale = authorData.preferences?.locale as string | undefined;
    const commenter = comment.authorUsername || '';
    const copy = pickCopy(locale, {
      tr: {
        title: 'Yeni yorum',
        body: `${commenter} paylaşımına yorum yaptı`,
      },
      en: {
        title: 'New comment',
        body: `${commenter} commented on your post`,
      },
      fr: {
        title: 'Nouveau commentaire',
        body: `${commenter} a commenté ton post`,
      },
      de: {
        title: 'Neuer Kommentar',
        body: `${commenter} hat deinen Beitrag kommentiert`,
      },
      es: {
        title: 'Nuevo comentario',
        body: `${commenter} ha comentado tu publicación`,
      },
    });
    await sendToUser(authorId, copy);
  },
);

// ── 2. onPostLikeWrite → update likesReceived + notify post author ──
export const onPostLikeWrite = onDocumentWritten(
  'posts/{postId}/likes/{uid}',
  async (event) => {
    const { postId, uid } = event.params as { postId: string; uid: string };

    const before = event.data?.before?.exists;
    const after = event.data?.after?.exists;
    if (before === after) return;

    const postSnap = await db.collection('posts').doc(postId).get();
    const post = postSnap.data();
    const authorId = post?.authorId as string | undefined;
    if (!authorId) return;

    const delta = after ? 1 : -1;
    await db.collection('users').doc(authorId).update({
      likesReceived: FieldValue.increment(delta),
    });

    // Send push only when a new like is added (not removed), and not self-like
    if (!after || authorId === uid) return;

    const authorSnap = await db.collection('users').doc(authorId).get();
    const authorData = authorSnap.data();
    if (!authorData) return;

    const prefs = (authorData.preferences?.notifications ?? {}) as NotificationPrefs;
    if (prefs.commentOnPost === false) return; // reuse same pref toggle

    const locale = authorData.preferences?.locale as string | undefined;

    // Get liker's username
    const likerSnap = await db.collection('users').doc(uid).get();
    const likerUsername = likerSnap.data()?.username || '';

    const copy = pickCopy(locale, {
      tr: {
        title: 'Paylaşımın beğenildi',
        body: likerUsername ? `${likerUsername} paylaşımını beğendi` : 'Birisi paylaşımını beğendi',
      },
      en: {
        title: 'Someone liked your post',
        body: likerUsername ? `${likerUsername} liked your post` : 'Someone liked your post',
      },
    });
    await sendToUser(authorId, copy);
  },
);

// ── 3. scheduledCycleReminders → daily sweep ─────────────
export const scheduledCycleReminders = onSchedule(
  {
    schedule: 'every day 09:00',
    timeZone: 'Europe/Istanbul',
  },
  async () => {
    const usersSnap = await db.collection('users').get();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (const userDoc of usersSnap.docs) {
      const data = userDoc.data();
      const prefs = (data.preferences?.notifications ?? {}) as NotificationPrefs;
      const locale = data.preferences?.locale as string | undefined;
      const cycle = data.cycleData ?? {};
      const cycleStart = (cycle.cycleStart as FirebaseFirestore.Timestamp | undefined)?.toDate();
      const cycleLength = (cycle.cycleLength as number | undefined) ?? 28;
      const periodLength = (cycle.periodLength as number | undefined) ?? 5;
      if (!cycleStart) continue;

      const start = new Date(cycleStart);
      start.setHours(0, 0, 0, 0);
      const msPerDay = 86_400_000;
      const daysSinceStart = Math.floor(
        (today.getTime() - start.getTime()) / msPerDay,
      );
      if (daysSinceStart < 0) continue;

      const dayInCycle = daysSinceStart % cycleLength; // 0 = start day
      if (dayInCycle === 0 && prefs.periodStart !== false) {
        await sendToUser(userDoc.id, pickCopy(locale, {
          tr: { title: 'Regl gününe merhaba', body: 'Kendine iyi davran, bugün döngünün başlangıcı.' },
          en: { title: 'Period day', body: 'Be kind to yourself — today starts a new cycle.' },
          fr: { title: 'Début du cycle', body: 'Un nouveau cycle commence aujourd’hui.' },
          de: { title: 'Zyklusbeginn', body: 'Dein neuer Zyklus beginnt heute.' },
          es: { title: 'Inicio del ciclo', body: 'Hoy comienza un nuevo ciclo.' },
        }));
      } else if (dayInCycle === periodLength && prefs.periodEnd !== false) {
        await sendToUser(userDoc.id, pickCopy(locale, {
          tr: { title: 'Regl bitti', body: 'Bitiş günü. Kendini nasıl hissediyorsun?' },
          en: { title: 'Period ended', body: 'Your period window has ended.' },
          fr: { title: 'Règles terminées', body: 'Ta fenêtre de règles est terminée.' },
          de: { title: 'Periode beendet', body: 'Deine Periode ist heute zu Ende.' },
          es: { title: 'Fin del período', body: 'Tu período ha terminado.' },
        }));
      }
    }
  },
);

// ── 4. scheduledExerciseReminder → 2x weekly ─────────────
export const scheduledExerciseReminder = onSchedule(
  {
    // Tuesday + Friday at 18:00
    schedule: '0 18 * * 2,5',
    timeZone: 'Europe/Istanbul',
  },
  async () => {
    const usersSnap = await db.collection('users').get();
    for (const userDoc of usersSnap.docs) {
      const data = userDoc.data();
      const prefs = (data.preferences?.notifications ?? {}) as NotificationPrefs;
      if (prefs.exerciseReminder === false) continue;
      const locale = data.preferences?.locale as string | undefined;

      await sendToUser(userDoc.id, pickCopy(locale, {
        tr: { title: 'Egzersiz vakti', body: 'Bugün 15 dakikalık bir egzersize ne dersin?' },
        en: { title: 'Workout time', body: 'How about a 15-minute session today?' },
        fr: { title: 'Heure du sport', body: 'Que dirais-tu de 15 minutes aujourd’hui ?' },
        de: { title: 'Trainingszeit', body: 'Wie wäre es mit 15 Minuten heute?' },
        es: { title: 'Hora de entrenar', body: '¿Qué tal una sesión de 15 minutos?' },
      }));
    }
  },
);
