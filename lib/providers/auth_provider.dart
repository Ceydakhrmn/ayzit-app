// =============================================
// providers/auth_provider.dart
// Central authentication state:
//   • Listens to FirebaseAuth.authStateChanges()
//   • Loads the Firestore AppUser doc for the signed-in user
//   • Exposes a single AuthState to the rest of the app
//
// Does NOT run Firebase init — main.dart must call Firebase.initializeApp()
// before MultiProvider is built.
// =============================================

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../services/purchase_service.dart';
import '../services/user_service.dart';

enum AuthStatus {
  /// Auth state is still resolving on app start.
  unknown,

  /// No Firebase user — show LoginScreen.
  loggedOut,

  /// Firebase user exists but email is not yet verified.
  needsVerification,

  /// Authenticated but no app mode selected yet — show onboarding.
  needsOnboarding,

  /// Fully authenticated — show MainShell.
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    UserService? userService,
    FcmService? fcmService,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService(),
        _fcmService = fcmService ?? FcmService() {
    _authSub = _authService.authStateChanges.listen(_handleAuthChange);
  }

  final AuthService _authService;
  final UserService _userService;
  final FcmService _fcmService;
  StreamSubscription<fb.User?>? _authSub;
  StreamSubscription<AppUser?>? _userDocSub;
  bool _fcmInitialized = false;

  AuthStatus _status = AuthStatus.unknown;
  fb.User? _firebaseUser;
  AppUser? _appUser;

  // ── Getters ──
  AuthStatus get status => _status;
  fb.User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthService get authService => _authService;
  UserService get userService => _userService;

  // ── Internal: auth state change handler ──
  Future<void> _handleAuthChange(fb.User? user) async {
    _firebaseUser = user;
    await _userDocSub?.cancel();
    _userDocSub = null;

    if (user == null) {
      _appUser = null;
      _status = AuthStatus.loggedOut;
      notifyListeners();
      return;
    }

    // For Google Sign-In, Firebase reports email as verified automatically,
    // so only email/password users land in `needsVerification`.
    if (!user.emailVerified) {
      _appUser = null;
      _status = AuthStatus.needsVerification;
      notifyListeners();
      return;
    }

    // Ensure a Firestore profile exists (Google first-sign-in path).
    try {
      final existing = await _userService.fetchUser(user.uid);
      if (existing == null) {
        await _userService.ensureUserProfileForGoogle(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
        );
      }
    } catch (e, st) {
      debugPrint('AuthProvider: ensure profile failed: $e\n$st');
    }

    // Live-subscribe to user doc for preference updates.
    _userDocSub = _userService.userStream(user.uid).listen((appUser) {
      _appUser = appUser;
      // Only show ModeSelectionScreen when no mode has been picked yet.
      // Once set, it persists across sessions until changed in Settings.
      final hasNoMode = appUser?.appMode.isEmpty ?? true;
      _status =
          hasNoMode ? AuthStatus.needsOnboarding : AuthStatus.authenticated;
      notifyListeners();
    });

    // Kick off FCM once per app lifecycle, after first successful auth.
    if (!_fcmInitialized) {
      _fcmInitialized = true;
      _fcmService.init();
    }

    // Sync RevenueCat with the signed-in user.
    await PurchaseService.instance.loginUser(user.uid);
  }

  // ── Actions ──
  Future<void> signOut() async {
    await _fcmService.deleteCurrentDeviceToken();
    await PurchaseService.instance.logoutUser();
    await _authService.signOut();
  }

  /// Called by ModeSelectionScreen right after it writes the chosen mode,
  /// so the UI doesn't wait on the Firestore stream round-trip to advance.
  void confirmModeForSession() {
    if (_appUser != null && _appUser!.appMode.isNotEmpty) {
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<void> refreshVerification() async {
    await _authService.reloadUser();
    final user = _authService.currentUser;
    _firebaseUser = user;
    if (user != null && user.emailVerified) {
      await _handleAuthChange(user);
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
