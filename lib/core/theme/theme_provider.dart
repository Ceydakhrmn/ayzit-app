// =============================================
// core/theme/theme_provider.dart
// Holds the current ThemeMode and keeps it in sync with the
// authenticated user's Firestore preference. Also listens to auth
// state so logging out snaps back to "system" mode.
// =============================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../utils/firestore_paths.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _authSub = _auth.authStateChanges().listen(_handleAuthChange);
    final current = _auth.currentUser;
    if (current != null) _handleAuthChange(current);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  AppThemeMode _mode = AppThemeMode.system;

  AppThemeMode get mode => _mode;

  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Imperatively update the mode. Used by SettingsScreen for instant UI
  /// feedback while the Firestore write is in flight.
  void setMode(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void _handleAuthChange(User? user) {
    _userDocSub?.cancel();
    _userDocSub = null;

    if (user == null || !user.emailVerified) {
      if (_mode != AppThemeMode.system) {
        _mode = AppThemeMode.system;
        notifyListeners();
      }
      return;
    }

    _userDocSub = _firestore
        .collection(FirestorePaths.users)
        .doc(user.uid)
        .snapshots()
        .listen((snap) {
      final data = snap.data();
      if (data == null) return;
      final prefs =
          (data['preferences'] as Map<String, dynamic>?) ?? const {};
      final raw = prefs['themeMode'] as String?;
      final mode = AppThemeMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => AppThemeMode.system,
      );
      if (_mode != mode) {
        _mode = mode;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
