// =============================================
// services/fcm_service.dart
// Firebase Cloud Messaging wiring:
//   • Requests notification permission on first run
//   • Writes FCM token to users/{uid}/fcmTokens/{deviceId}
//   • Refreshes token on token changes
//   • Handles foreground + background messages
//
// Actual push notifications are sent by Cloud Functions
// (see functions/ directory).
// =============================================

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/firestore_paths.dart';

class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('FcmService.requestPermission: $e');
    }

    // iOS foreground presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _registerInitialToken();

    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_saveToken);

    _foregroundSub = FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('FCM foreground: ${msg.notification?.title}');
      // The UI can listen to a stream if it wants to show in-app banners,
      // but for MVP we rely on the OS notification.
    });
  }

  Future<void> _registerInitialToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('FcmService.getToken: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final deviceId = await _stableDeviceId(token);
    final platform = _platformName();

    try {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .collection(FirestorePaths.fcmTokens)
          .doc(deviceId)
          .set({
        'token': token,
        'platform': platform,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FcmService._saveToken: $e');
    }
  }

  /// Delete the current device's token (best-effort) before sign-out.
  Future<void> deleteCurrentDeviceToken() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      final deviceId = await _stableDeviceId(token);
      await _firestore
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .collection(FirestorePaths.fcmTokens)
          .doc(deviceId)
          .delete();
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('FcmService.deleteCurrentDeviceToken: $e');
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Use the first 16 chars of the token as a device identifier.
  /// Stable enough for our purposes (one doc per device install).
  Future<String> _stableDeviceId(String token) async {
    return token.length <= 16 ? token : token.substring(0, 16);
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
  }
}
