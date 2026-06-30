// PLACEHOLDER - FIREBASE KURULUMU YAPILMALI!
// Bu dosya FlutterFire CLI ile değiştirilmelidir.
// Kurulum için: FIREBASE_SETUP.md dosyasını okuyun

// 1. Firebase projesini oluşturun: https://console.firebase.google.com/
// 2. FlutterFire CLI kurun: dart pub global activate flutterfire_cli
// 3. Yapılandırın: flutterfire configure

// GEÇICI OLARAK BOŞ SINIF (HATA VERMEMEK İÇİN)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBGU0d6_67zlCt5VlawiBd2-qArr2SP2pQ',
    appId: '1:325686381442:web:4fc6dba8bba98f987b9d9b',
    messagingSenderId: '325686381442',
    projectId: 'ayzit-app',
    authDomain: 'ayzit-app.firebaseapp.com',
    storageBucket: 'ayzit-app.firebasestorage.app',
    measurementId: 'G-L75D2ZP3YK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDzNVaAZG-yp97fpi_rYOUiuIMmWZCyZA',
    appId: '1:325686381442:android:2030ea332fb2ee897b9d9b',
    messagingSenderId: '325686381442',
    projectId: 'ayzit-app',
    storageBucket: 'ayzit-app.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxsA8P30mtIWAHP9xbkb2dhjcDnqrPq04',
    appId: '1:325686381442:ios:ba628fda351d468f7b9d9b',
    messagingSenderId: '325686381442',
    projectId: 'ayzit-app',
    storageBucket: 'ayzit-app.firebasestorage.app',
    iosBundleId: 'com.ayzit.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxsA8P30mtIWAHP9xbkb2dhjcDnqrPq04',
    appId: '1:325686381442:ios:70baef95f7b79a087b9d9b',
    messagingSenderId: '325686381442',
    projectId: 'ayzit-app',
    storageBucket: 'ayzit-app.firebasestorage.app',
    iosBundleId: 'com.example.yeniUygulama',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGU0d6_67zlCt5VlawiBd2-qArr2SP2pQ',
    appId: '1:325686381442:web:49b73a622655d1187b9d9b',
    messagingSenderId: '325686381442',
    projectId: 'ayzit-app',
    authDomain: 'ayzit-app.firebaseapp.com',
    storageBucket: 'ayzit-app.firebasestorage.app',
    measurementId: 'G-7P66F7CVV2',
  );
}
