// =============================================
// functions/src/index.ts
// Cloud Functions for Ayzit:
//   • onCommentCreated  — push to post author when a new comment lands
//   • onPostLikeWrite — keep users/{uid}.likesReceived in sync + push
//
// Period / exercise / water reminders are scheduled on the device by the
// app (lib/services/reminder_notification_service.dart) — do not add server
// reminders back, users would get every reminder twice.
// =============================================

import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
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
