# Firebase Mesajlaşma Sistemi - Kurulum Rehberi

## 🎉 Yapılanlar

Uygulamanıza **tam çalışan bir mesajlaşma sistemi** eklendi:

### ✅ Özellikler
- 👥 **Grup Sohbeti**: Tüm kullanıcılarla ortak sohbet odası
- 💬 **1-1 Mesajlaşma**: Kullanıcılar arası özel mesajlaşma
- ⚡ **Gerçek Zamanlı**: Mesajlar anında güncellenir
- 🎨 **Modern UI**: Sohbet balonları, zaman damgaları, kullanıcı avatarları
- 🔐 **Anonim Giriş**: Hızlı başlangıç için kolay giriş sistemi

### 📁 Oluşturulan Dosyalar

**Servisler:**
- `lib/services/auth_service.dart` - Firebase Authentication
- `lib/services/chat_service.dart` - Firestore mesajlaşma yönetimi

**Ekranlar:**
- `lib/screens/auth_wrapper.dart` - Giriş ekranı
- `lib/screens/chat_list_screen.dart` - Chat listesi (grup + kullanıcılar)
- `lib/screens/group_chat_screen.dart` - Topluluk sohbet odası
- `lib/screens/private_chat_screen.dart` - 1-1 özel mesajlaşma

**Güncellemeler:**
- `lib/main.dart` - Firebase başlatma, 4. sekme eklendi
- `lib/l10n/app_tr.arb` & `app_en.arb` - Yeni çeviri anahtarları
- `pubspec.yaml` - Firebase paketleri eklendi

---

## 🚀 Firebase Kurulumu (ZORUNLU)

Mesajlaşma özelliğini kullanmak için Firebase projesi kurmalısınız:

### 1. Firebase Projesi Oluştur

1. [Firebase Console](https://console.firebase.google.com/) açın
2. "Add Project" / "Proje Ekle" tıklayın
3. Proje adı: `adet-dongusu` (veya istediğiniz isim)
4. Google Analytics **kapalı** (opsiyonel)
5. Projeyi oluşturun

### 2. Firestore Veritabanı Aktif Et

1. Firebase Console → **Firestore Database**
2. "Create database" tıklayın
3. **Test mode** seçin (başlangıç için)
4. Konum: `europe-west1` (Avrupa sunucusu)
5. "Enable" tıklayın

### 3. Authentication Aktif Et

1. Firebase Console → **Authentication**
2. "Get started" tıklayın
3. **Sign-in method** sekmesi → **Anonymous** etkinleştirin

### 4. FlutterFire CLI Kurulumu

```powershell
# Firebase CLI kur (Node.js gerekli)
npm install -g firebase-tools

# Firebase'e giriş yap
firebase login

# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# PATH'e ekle (eğer yoksa)
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
```

### 5. Firebase'i Uygulamaya Bağla

```powershell
# Proje dizinine git
cd c:\Users\ceyda\ajanda-app\src\app\flutter\yeni_uygulama

# Firebase yapılandırmasını oluştur
flutterfire configure

# Projeyi seç: adet-dongusu
# Platformları seç: Android, iOS, Web (isteğe bağlı)
```

Bu komut `lib/firebase_options.dart` dosyasını otomatik oluşturacak.

### 6. firebase_options.dart'ı main.dart'a ekle

`lib/main.dart` dosyasına şu satırı ekleyin (zaten ekli olmalı):

```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 7. Firestore Güvenlik Kuralları

Firebase Console → **Firestore Database** → **Rules** sekmesinde:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcı verileri
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Grup sohbeti - herkes okuyup yazabilir
    match /groupChat/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Özel sohbetler - sadece katılımcılar
    match /privateChats/{chatId} {
      allow read, write: if request.auth != null &&
        request.auth.uid in resource.data.participants;
    }
    
    match /privateChats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

"Publish" tıklayın.

---

## 📦 Paketleri Yükle

```powershell
flutter pub get
```

---

## ▶️ Uygulamayı Çalıştır

```powershell
# Windows
flutter run -d windows

# Android (emulator veya cihaz)
flutter run -d android

# Web
flutter run -d chrome
```

---

## 🎮 Kullanım

1. **İlk Giriş**: Uygulamayı açtığınızda bir isim gireceksiniz (örn: "Ayşe")
2. **4 Sekme**:
   - 🏠 Adet Takip
   - 🏃‍♀️ Egzersiz (su, nefes)
   - 🤖 hörü (AI asistan)
   - 💬 **Sohbet** (YENİ!)
3. **Grup Sohbeti**: Tüm kullanıcılarla sohbet et
4. **Özel Mesajlar**: Kullanıcı listesinden birine tıklayarak 1-1 sohbet başlat

---

## 🔧 Test Etme (Çoklu Kullanıcı)

İki tarayıcı veya cihazda uygulamayı açarak test edebilirsiniz:

```powershell
# Terminal 1 - Chrome
flutter run -d chrome

# Terminal 2 - Edge (başka bir kullanıcı simüle et)
flutter run -d edge
```

Her birinde farklı isim girin ve mesajlaşmayı test edin!

---

## 📊 Firestore Veri Yapısı

### Koleksiyonlar:

**`users/` koleksiyonu:**
```json
{
  "uid": "abc123",
  "displayName": "Ayşe",
  "email": "",
  "createdAt": Timestamp,
  "isOnline": true,
  "lastSeen": Timestamp
}
```

**`groupChat/` koleksiyonu:**
```json
{
  "senderId": "abc123",
  "senderName": "Ayşe",
  "text": "Merhaba!",
  "timestamp": Timestamp,
  "photoUrl": null
}
```

**`privateChats/{chatId}/messages/` koleksiyonu:**
```json
{
  "senderId": "abc123",
  "senderName": "Ayşe",
  "text": "Nasılsın?",
  "timestamp": Timestamp
}
```

---

## 🐛 Sorun Giderme

### "Firebase app not initialized"
→ `flutterfire configure` komutunu çalıştırın

### "Permission denied" hatası
→ Firestore güvenlik kurallarını kontrol edin

### Mesajlar görünmüyor
→ Firebase Console'da Firestore Database'de veriler var mı kontrol edin

### Android build hatası
→ `android/build.gradle` → `minSdkVersion 21` olmalı

---

## 🎨 Özelleştirme

### Renkleri Değiştir
`lib/main.dart` → `ColorScheme.fromSeed(seedColor: Colors.blue)`

### Sohbet Balonları
`lib/screens/group_chat_screen.dart` ve `private_chat_screen.dart` → `BoxDecoration` renkleri

### Mesaj Limiti
`lib/services/chat_service.dart` → `limit` parametresini değiştirin (varsayılan: 100)

---

## 📱 Gelecek Geliştirmeler

- [ ] Fotoğraf paylaşma
- [ ] Emoji reaksiyonları
- [ ] Ses mesajları
- [ ] Push bildirimleri
- [ ] Okundu bilgisi
- [ ] Mesaj silme/düzenleme
- [ ] Email/şifre ile kayıt

---

## 🛡️ Güvenlik Önerileri (Prodüksiyon için)

1. **Firestore Rules**: Test mode yerine production rules kullanın
2. **Email Doğrulama**: Anonim yerine email/şifre authentication ekleyin
3. **Rate Limiting**: Spam önlemek için mesaj limiti koyun
4. **Moderation**: Uygunsuz içerik filtreleme
5. **SSL/HTTPS**: Web sürümü için HTTPS kullanın

---

## 💡 İpuçları

- Firebase ücretsiz planı küçük projeler için yeterli (Spark Plan)
- Firestore okuma/yazma limitleri: günlük 50,000 okuma + 20,000 yazma (ücretsiz)
- Gerçek zamanlı güncellemeler için StreamBuilder kullanılıyor
- Mesajlar otomatik sıralı (timestamp'e göre)

---

**Hazır! 🎉** Artık tam çalışan bir mesajlaşma sisteminiz var!
