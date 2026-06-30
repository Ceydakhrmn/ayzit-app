# Lunora — Manuel Kurulum Adımları

Kod tarafındaki tüm refactor tamamlandı. Aşağıdaki manuel adımları **sırayla** uygulaman gerekiyor. Bir adım bitmeden diğerine geçme.

---

## 0. Ön Gereksinimler

- Node 20 (Cloud Functions için)
- Flutter SDK 3.10+
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Xcode 15+ (iOS için) ve Android Studio (Android için)

Projenin kök dizininde olduğundan emin ol:
```bash
cd /Users/candroid/Documents/GitHub/lunora-app
```

---

## 1. Firebase CLI login

```bash
firebase login
```
Projelerinin listelendiğini görmelisin. Mevcut Lunora projesinin orada olduğunu doğrula.

---

## 2. Firebase Console — Servisleri aktif et

[Firebase Console](https://console.firebase.google.com) → proje

### 2.1 Authentication
- **Authentication → Sign-in method**:
  - **Email/Password** → Enable
  - **Google** → Enable, "Project support email" seç ve kaydet
- **Authentication → Settings → Authorized domains**: Web build için domain ekleyeceksen buraya ekle

### 2.2 Firestore
- **Build → Firestore Database** → *Create database*
- **Production mode** seç (rules'ları sonra deploy edeceğiz)
- Bölge: `europe-west1` (veya sana en yakın bölge)

### 2.3 Cloud Messaging
- **Build → Cloud Messaging** → Ayrıca bir işlem yok, zaten aktif

### 2.4 Crashlytics
- **Release & Monitor → Crashlytics** → *Get started*
- Platform seçmene gerek yok; SDK kod tarafında zaten wire-up edildi

### 2.5 Functions
- **Build → Functions** → *Get started* → Blaze plan uyarısını onayla (zaten Blaze aktif dedin)

### 2.6 Storage
- **Storage** kullanmıyoruz (profil fotoğrafı yok). Bu adımı **atla**.

---

## 3. FlutterFire configure (çok önemli!)

Bu komut `lib/firebase_options.dart` dosyasını gerçek değerlerle dolduracak.

```bash
flutterfire configure
```

Sorulduğunda:
- Projeni seç
- Platformları seç: **Android**, **iOS**, **Web** (hedeflediklerini)
- Bundle ID / application ID için default'u kullan

Komut bitince otomatik olarak:
- `lib/firebase_options.dart` güncellenir
- `android/app/google-services.json` yerleştirilir
- `ios/Runner/GoogleService-Info.plist` yerleştirilir
- `web/index.html`'e Firebase init script'i eklenir

---

## 4. Flutter paketleri

```bash
flutter pub get
```

Eğer versiyon çakışması olursa:
```bash
flutter pub upgrade --major-versions
```

Çıktıda hata yoksa devam.

---

## 5. Lokalizasyonu regenerate et

`.arb` dosyalarını güncelledik. `gen_l10n/*.dart` dosyaları eski haliyle kalmış olabilir — regenerate et:

```bash
flutter gen-l10n
```

Eğer komut yoksa: `flutter pub global activate intl_utils` sonra tekrar dene.

---

## 6. Android setup

### 6.1 SHA-1 / SHA-256 fingerprint (Google Sign-In için zorunlu)

```bash
cd android
./gradlew signingReport
cd ..
```

Çıktıdaki `Variant: debug` bölümündeki **SHA1** ve **SHA-256** değerlerini kopyala.

Firebase Console → Project Settings (dişli ikon) → Android app → **Add fingerprint** → SHA-1 yapıştır. Aynısını SHA-256 için de yap.

Release build için de yapacağın zaman `signingReport` → `Variant: release` kısmından al.

### 6.2 google-services.json kontrol

`flutterfire configure` zaten yerleştirdi, ama doğrula:
```bash
ls android/app/google-services.json
```

### 6.3 Test
```bash
flutter run -d android
```

---

## 7. iOS setup

### 7.1 GoogleService-Info.plist kontrol

```bash
ls ios/Runner/GoogleService-Info.plist
```
Yoksa `flutterfire configure`'u tekrar çalıştır.

### 7.2 URL Scheme (Google Sign-In için)

`ios/Runner/Info.plist`'i Xcode'da aç veya VS Code'da elle düzenle. `<dict>` içine şunu ekle:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- GoogleService-Info.plist içindeki REVERSED_CLIENT_ID değerini yapıştır -->
      <string>com.googleusercontent.apps.XXXXXXXXXXXX-XXXXXXXXXX</string>
    </array>
  </dict>
</array>
```

`REVERSED_CLIENT_ID` değerini `ios/Runner/GoogleService-Info.plist` içinde bul ve üstteki `XXXXX...` yerine yapıştır.

### 7.3 APNs Auth Key (FCM için)

Apple Developer Portal → Certificates, Identifiers & Profiles → **Keys** → `+` → **Apple Push Notifications service (APNs)** seç → Continue → Download the `.p8` key file → **Key ID** ve **Team ID**'yi kaydet.

Firebase Console → Project Settings → **Cloud Messaging** → iOS app → **APNs Authentication Key** → Upload:
- `.p8` dosyasını yükle
- Key ID
- Team ID

### 7.4 Xcode Capabilities

`ios/` dizininde Xcode'u aç:
```bash
open ios/Runner.xcworkspace
```

Runner target → **Signing & Capabilities** → `+ Capability`:
- **Push Notifications**
- **Background Modes** → içinde "Remote notifications" işaretle

### 7.5 Pod install
```bash
cd ios
pod install --repo-update
cd ..
```

### 7.6 Test
```bash
flutter run -d ios
```

---

## 8. Web setup

### 8.1 OAuth Client ID

Firebase Console → **Authentication → Sign-in method → Google** → genişlet → Web SDK configuration → "Web client ID"yi kopyala.

`web/index.html` dosyasını aç → `<head>` içine ekle:
```html
<meta name="google-signin-client_id" content="COPY_WEB_CLIENT_ID_HERE.apps.googleusercontent.com">
```

### 8.2 Test
```bash
flutter run -d chrome
```

---

## 9. Firestore deploy (rules + indexes)

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Eğer ilk kez deploy ediyorsan `firebase use` ile projeyi seçmen isteyebilir:
```bash
firebase use --add
```
→ Projeyi seç → alias ver (örn: `default`)

Sonra deploy komutunu tekrar çalıştır.

---

## 10. Cloud Functions deploy

```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

İlk deploy 5-10 dakika sürebilir. Bittiğinde Firebase Console → Functions altında 4 function görmelisin:
- `onCommentCreated`
- `onPostLikeWrite`
- `scheduledCycleReminders`
- `scheduledExerciseReminder`

---

## 11. Profanity list — ilk seed

Firebase Console → Firestore → **Start collection** → Collection ID: `config`
→ Document ID: `profanityList`
→ Alan ekle:
- `words` (type: **array**)
- Array içine bir-iki kelime ekle (örn: `["amk", "fuck"]`). Uygulama zaten built-in base listesini de kullanıyor; bu Firestore dokümanı o listeye **ek** kelimeler içerir.

Dokümanı kaydet.

---

## 12. İlk test kullanıcısı ile smoke test

```bash
flutter run -d <android|ios|chrome>
```

Test senaryosu:
1. Register ekranına git → test@test.com, şifre, test_user, Test Kullanıcı → Kayıt ol
2. Email verify sayfası gelmeli → emaile gönderilen linke tıkla → "Doğruladım" tuşuna bas
3. Main shell'e girmelisin (Takvim tabı açık)
4. 4 tab'ı sırayla gez: Takvim, Egzersiz, Sosyal (boş feed), Profil
5. Sosyal tab'ında FAB'a tıkla → bir test postu oluştur
6. Post'a tıkla → yorum yaz
7. Kendi yorumunu sil
8. Profile git → Çıkış yap
9. Login sayfasına dönmelisin

---

## 13. Son kontrol

- [ ] `firebase_options.dart` içinde TODO kalmadı
- [ ] Android'de Google Sign-In çalışıyor
- [ ] iOS'ta Google Sign-In çalışıyor (URL scheme eklendi)
- [ ] Web'de Google Sign-In çalışıyor
- [ ] Firestore rules deploy edildi
- [ ] Firestore indexes deploy edildi
- [ ] 4 Cloud Function deploy edildi
- [ ] Test notification Firebase Console'dan atıldı (Cloud Messaging → Send test message)
- [ ] Crashlytics dashboard'da "Waiting for first crash" yerine normal bir ekran var

Herhangi bir adımda takılırsan bana yaz — ilgili adımın loglarını/hatasını paylaş.

---

## 14. Deploy sonrası bakım

### Rules veya indexes güncellemek
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### Cloud Functions güncellemek
```bash
cd functions && npm run build && cd ..
firebase deploy --only functions
```

### Crashlytics sembolleri (release build için)
Flutter otomatik yükler (gradle plugin ile); ekstra iş yok.
