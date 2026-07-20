// =============================================
// services/purchase_service.dart
// RevenueCat wrapper — call PurchaseService.init()
// once at startup (after Firebase.initializeApp).
//
// Product IDs must match exactly what you create in
// App Store Connect (iOS) and Google Play Console (Android).
// =============================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  PurchaseService._();
  static final instance = PurchaseService._();

  // ── RevenueCat API keys ──────────────────────────────────────
  // Replace these with your real keys from app.revenuecat.com
  static const _iosKey     = 'appl_REPLACE_WITH_YOUR_IOS_KEY';
  static const _androidKey = 'goog_REPLACE_WITH_YOUR_ANDROID_KEY';

  // ── Entitlement ID ──────────────────────────────────────────
  // Create this in RevenueCat dashboard → Entitlements → "premium"
  static const entitlementId = 'premium';

  // ── Product IDs ─────────────────────────────────────────────
  // Create these in App Store Connect / Google Play Console first,
  // then add them to RevenueCat dashboard → Products.
  static const monthlyProductId = 'ayzit_premium_monthly';
  static const yearlyProductId  = 'ayzit_premium_yearly';

  bool _initialized = false;

  /// True only when Purchases.configure() actually ran. While the API keys
  /// are placeholders the SDK is never configured, and calling any
  /// Purchases.* method would throw a PlatformException.
  bool _configured = false;

  Future<void> init({String? userId}) async {
    if (_initialized) return;
    // Skip init if placeholder keys are still in place
    if (_iosKey.contains('REPLACE') || _androidKey.contains('REPLACE')) {
      _initialized = true;
      return;
    }
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

    final apiKey = Platform.isIOS ? _iosKey : _androidKey;
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _configured = true;

    if (userId != null) {
      await Purchases.logIn(userId);
    }

    _initialized = true;
  }

  Future<void> loginUser(String uid) async {
    if (!_configured) return;
    await Purchases.logIn(uid);
  }

  Future<void> logoutUser() async {
    if (!_configured) return;
    await Purchases.logOut();
  }

  /// Returns true if the current user has an active "premium" entitlement.
  Future<bool> isPremium() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (_) {
      return false;
    }
  }

  /// Fetches the available offerings from RevenueCat.
  Future<Offerings?> getOfferings() async {
    if (!_configured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('PurchaseService.getOfferings: $e');
      return null;
    }
  }

  /// Purchases a [package]. Returns updated CustomerInfo on success.
  Future<CustomerInfo?> purchase(Package package) async {
    if (!_configured) return null;
    try {
      return await Purchases.purchasePackage(package);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return null;
      rethrow;
    }
  }

  /// Restores previous purchases (e.g. after reinstall).
  Future<CustomerInfo?> restore() async {
    if (!_configured) return null;
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService.restore: $e');
      return null;
    }
  }
}
