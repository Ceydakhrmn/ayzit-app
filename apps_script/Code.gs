// =============================================
// apps_script/Code.gs — Ayzit yorum / beğeni bildirimleri
//
// Firebase'in ücretsiz (Spark) planında Cloud Functions çalışmadığı için
// bildirimleri Google Apps Script gönderir (ücretsiz, kart gerekmez).
// Proje sahibinin Google hesabıyla 5 dakikada bir çalışır:
//   1. users/*/activity içinde pushed == false olan kayıtları bulur
//   2. Kişinin ayarı açıksa ("Paylaşımıma yorum ya da beğeni gelince")
//      telefonlarına FCM ile bildirim gönderir
//   3. Kayıtları pushed = true yapar (bir daha gönderilmez)
//
// Kurulum: apps_script/README.md
// =============================================

const PROJECT_ID = 'ayzit-app';
const FIRESTORE =
  'https://firestore.googleapis.com/v1/projects/' + PROJECT_ID +
  '/databases/(default)/documents';
const FCM_SEND =
  'https://fcm.googleapis.com/v1/projects/' + PROJECT_ID + '/messages:send';

/** Bir kez çalıştırılır: 5 dakikada bir çalışan tetikleyiciyi kurar. */
function setup() {
  ScriptApp.getProjectTriggers()
    .filter((t) => t.getHandlerFunction() === 'sendPendingActivityPushes')
    .forEach((t) => ScriptApp.deleteTrigger(t));
  ScriptApp.newTrigger('sendPendingActivityPushes')
    .timeBased()
    .everyMinutes(5)
    .create();
  sendPendingActivityPushes();
}

/** Tetikleyicinin çağırdığı ana iş. */
function sendPendingActivityPushes() {
  const pending = runQuery_({
    structuredQuery: {
      from: [{ collectionId: 'activity', allDescendants: true }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'pushed' },
          op: 'EQUAL',
          value: { booleanValue: false },
        },
      },
      limit: 200,
    },
  });
  if (pending.length === 0) return;

  // Aynı kişiye aynı turda gelenler tek bildirimde toplanır.
  const byOwner = {};
  pending.forEach((doc) => {
    const ownerUid = doc.name.split('/users/')[1].split('/')[0];
    (byOwner[ownerUid] = byOwner[ownerUid] || []).push(doc);
  });

  Object.keys(byOwner).forEach((uid) => {
    const docs = byOwner[uid];
    try {
      notifyOwner_(uid, docs);
    } catch (e) {
      console.error('notifyOwner_ ' + uid + ': ' + e);
      return; // pushed işaretlenmez, sonraki turda tekrar denenir
    }
    docs.forEach((d) => {
      try {
        markPushed_(d.name);
      } catch (e) {
        // Kayıt bu arada silinmiş olabilir (beğeni geri alındı); sorun değil.
        console.warn('markPushed_ ' + d.name + ': ' + e);
      }
    });
  });
}

function notifyOwner_(uid, docs) {
  const user = getDoc_('users/' + uid);
  if (!user) return; // hesap silinmiş
  const prefs = mapValue_(mapValue_(user.fields, 'preferences'), 'notifications');
  const enabled = boolValue_(prefs, 'commentOnPost', true);
  if (!enabled) return;
  // Uygulamada seçilen dil (Ayarlar → Dil) users/{uid}.language alanında;
  // yoksa eski preferences.locale, o da yoksa Türkçe.
  const locale = stringValue_(user.fields, 'language',
    stringValue_(mapValue_(user.fields, 'preferences'), 'locale', 'tr'));

  const tokens = listDocs_('users/' + uid + '/fcmTokens')
    .map((d) => ({ name: d.name, token: stringValue_(d.fields, 'token', '') }))
    .filter((t) => t.token);
  if (tokens.length === 0) return;

  const msg = buildMessage_(docs.map((d) => d.fields), locale);
  tokens.forEach((t) => {
    const res = UrlFetchApp.fetch(FCM_SEND, {
      method: 'post',
      contentType: 'application/json',
      headers: authHeaders_(),
      muteHttpExceptions: true,
      payload: JSON.stringify({
        message: {
          token: t.token,
          notification: { title: msg.title, body: msg.body },
          android: { priority: 'high' },
        },
      }),
    });
    const code = res.getResponseCode();
    // Uygulama silinmiş / token artık geçersiz: token kaydını temizle.
    if (code === 404 || /UNREGISTERED/.test(res.getContentText())) {
      deleteDocByName_(t.name);
    } else if (code >= 300) {
      throw new Error('FCM ' + code + ' ' + res.getContentText());
    }
  });
}

function buildMessage_(items, locale) {
  const tr = !locale || locale.toLowerCase().indexOf('tr') === 0;
  const first = items[0];
  const who = stringValue_(first, 'actorUsername', tr ? 'Birisi' : 'Someone');
  const isComment = stringValue_(first, 'type', '') === 'comment';
  if (items.length > 1) {
    return {
      title: tr ? 'Paylaşımlarına ' + items.length + ' yeni etkileşim 💜'
                : items.length + ' new interactions on your posts 💜',
      body: tr ? who + ' ve diğerleri paylaşımlarına yorum yaptı ya da beğendi.'
               : who + ' and others commented on or liked your posts.',
    };
  }
  if (isComment) {
    const text = stringValue_(first, 'text', '');
    return {
      title: tr ? '💬 ' + who + ' paylaşımına yorum yaptı' : '💬 ' + who + ' commented on your post',
      body: text ? '“' + text + '”' : (tr ? 'Görmek için dokun.' : 'Tap to view.'),
    };
  }
  return {
    title: tr ? '💜 ' + who + ' paylaşımını beğendi' : '💜 ' + who + ' liked your post',
    body: tr ? 'Görmek için dokun.' : 'Tap to view.',
  };
}

// ── Firestore REST yardımcıları ─────────────────────────

function authHeaders_() {
  return {
    Authorization: 'Bearer ' + ScriptApp.getOAuthToken(),
    // API kotası Apps Script'in varsayılan projesine değil ayzit-app'e yazılsın.
    'x-goog-user-project': PROJECT_ID,
  };
}

function fetchJson_(url, options) {
  const res = UrlFetchApp.fetch(url, Object.assign({
    headers: authHeaders_(),
    muteHttpExceptions: true,
  }, options || {}));
  const code = res.getResponseCode();
  if (code === 404) return null;
  if (code >= 300) throw new Error(code + ' ' + url + ' ' + res.getContentText());
  const text = res.getContentText();
  return text ? JSON.parse(text) : {};
}

function runQuery_(body) {
  const rows = fetchJson_(FIRESTORE + ':runQuery', {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(body),
  }) || [];
  return rows.filter((r) => r.document).map((r) => r.document);
}

function getDoc_(path) {
  return fetchJson_(FIRESTORE + '/' + path);
}

function listDocs_(path) {
  const res = fetchJson_(FIRESTORE + '/' + path + '?pageSize=50');
  return (res && res.documents) || [];
}

function markPushed_(fullName) {
  fetchJson_('https://firestore.googleapis.com/v1/' + fullName +
    '?updateMask.fieldPaths=pushed&currentDocument.exists=true', {
    method: 'patch',
    contentType: 'application/json',
    payload: JSON.stringify({ fields: { pushed: { booleanValue: true } } }),
  });
}

function deleteDocByName_(fullName) {
  fetchJson_('https://firestore.googleapis.com/v1/' + fullName, { method: 'delete' });
}

function mapValue_(fields, key) {
  const v = fields && fields[key];
  return (v && v.mapValue && v.mapValue.fields) || {};
}

function stringValue_(fields, key, fallback) {
  const v = fields && fields[key];
  return v && typeof v.stringValue === 'string' ? v.stringValue : fallback;
}

function boolValue_(fields, key, fallback) {
  const v = fields && fields[key];
  return v && typeof v.booleanValue === 'boolean' ? v.booleanValue : fallback;
}
