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
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    authDomain: 'TODO',
    storageBucket: 'TODO',
    measurementId: 'TODO',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOqyY9LmnjAfpVOva5ruocb5O8fwxxfDc',
    appId: '1:475085184976:android:ecfedcfb9df3fc3b4ce3d5',
    messagingSenderId: '475085184976',
    projectId: 'adet-dongusu',
    storageBucket: 'adet-dongusu.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
    iosBundleId: 'TODO',
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
