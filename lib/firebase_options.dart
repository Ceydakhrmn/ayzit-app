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
    apiKey: 'AIzaSyB2IE6araxoSVTYpRs1O3-oPSW1o8wqkpg',
    appId: '1:198781995461:web:835d8a0428da2cbd3963ac',
    messagingSenderId: '198781995461',
    projectId: 'lunora-app',
    authDomain: 'lunora-app.firebaseapp.com',
    storageBucket: 'lunora-app.firebasestorage.app',
    measurementId: 'G-2JMRFPG0VB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9OJ0S9M7D_jTBq_RpQluMQIiO-Z7Mm7Q',
    appId: '1:198781995461:android:94b290ba385589343963ac',
    messagingSenderId: '198781995461',
    projectId: 'lunora-app',
    storageBucket: 'lunora-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBcIcUmsjUzxggPk6uCRWPikaOCl8G94Ak',
    appId: '1:198781995461:ios:e33525b7eedb3bda3963ac',
    messagingSenderId: '198781995461',
    projectId: 'lunora-app',
    storageBucket: 'lunora-app.firebasestorage.app',
    iosClientId: '198781995461-u32dapcnh4v7ipbcd77ab0kpsu3j3sjb.apps.googleusercontent.com',
    iosBundleId: 'com.lunora.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
    iosBundleId: 'TODO',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
  );
}