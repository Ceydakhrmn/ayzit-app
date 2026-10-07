# Yorum / beğeni bildirimleri — Google Apps Script

Firebase ücretsiz (Spark) planda olduğu için Cloud Functions çalışmıyor.
Bildirimleri bunun yerine **Google Apps Script** gönderir: ücretsiz, kart
istemez, Firebase projesinin sahibi olan Google hesabıyla çalışır.

Akış:
1. Biri yorum yapınca / beğenince uygulama, paylaşım sahibinin
   `users/{uid}/activity` listesine bir kayıt yazar (`pushed: false`).
2. Bu script 5 dakikada bir `pushed == false` kayıtları bulur, kişinin
   ayarı açıksa telefonuna bildirim gönderir ve kaydı `pushed: true` yapar.

## Kurulum (bir kez)

> Önce Firestore kurallarını ve dizinini yayınla (bkz. aşağıdaki
> "Önce: kurallar ve dizin"). Yoksa script'in sorgusu dizin hatası verir.

1. **script.google.com** → **Yeni proje**. Adını `Ayzit bildirimleri` yap.
2. Soldaki **⚙ Proje Ayarları** → **"appsscript.json" manifest dosyasını
   düzenleyicide göster** kutusunu işaretle.
3. **Düzenleyici**'ye dön:
   - `appsscript.json` dosyasının içeriğini bu klasördeki `appsscript.json`
     ile değiştir.
   - `Kod.gs` (ya da `Code.gs`) içeriğini bu klasördeki `Code.gs` ile
     değiştir.
   - **Kaydet** (💾).
4. Üstteki işlev listesinden **`setup`**'ı seç → **Çalıştır**.
5. İzin penceresi açılır → Firebase projesinin sahibi olan Google hesabını
   seç → "Google bu uygulamayı doğrulamadı" çıkarsa **Gelişmiş → Ayzit
   bildirimleri'ne git (güvenli değil)** → **İzin ver**.
   (Script senin kendi hesabında, sadece senin projene erişiyor.)
6. Bitti. Soldaki **⏰ Tetikleyiciler**'de `sendPendingActivityPushes`
   için "5 dakikada bir" tetikleyici görünmeli.

## Önce: kurallar ve dizin

Proje klasöründe (ücretsiz planda da çalışır):

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Dizin oluşması birkaç dakika sürebilir. "Bu dizinler dosyada yok, silinsin
mi?" diye sorarsa **No** de.

## Kontrol

- **⏰ Tetikleyiciler → Yürütmeler**: her 5 dakikada bir çalışma ve hata
  varsa mesajı görünür.
- Yeni yorum/beğeni geldiğinde en geç ~5 dakika içinde bildirim gelir.

## Sınırlar

- Ücretsiz Google hesabında Apps Script tetikleyicileri günde toplam
  ~90 dakika çalışabilir; her tur birkaç saniye sürdüğü için 5 dakikalık
  aralık bunun çok altında kalır.
- Bildirim anlık değil, en fazla ~5 dakika gecikmeli gelir.
