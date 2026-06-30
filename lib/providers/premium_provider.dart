// =============================================
// providers/premium_provider.dart
// Keeps track of whether the current user has an
// active premium entitlement via RevenueCat.
// =============================================

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/purchase_service.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;
  bool _loading = true;
  Offerings? _offerings;

  bool get isPremium => _isPremium;
  bool get loading => _loading;
  Offerings? get offerings => _offerings;

  /// Call once after RevenueCat is initialised.
  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    _isPremium = await PurchaseService.instance.isPremium();
    _offerings = await PurchaseService.instance.getOfferings();

    _loading = false;
    notifyListeners();
  }

  /// Purchases [package] and refreshes premium state.
  Future<bool> purchase(Package package) async {
    final info = await PurchaseService.instance.purchase(package);
    if (info == null) return false;

    _isPremium = info.entitlements.active
        .containsKey(PurchaseService.entitlementId);
    notifyListeners();
    return _isPremium;
  }

  /// Restores purchases and refreshes premium state.
  Future<bool> restore() async {
    final info = await PurchaseService.instance.restore();
    if (info == null) return false;

    _isPremium = info.entitlements.active
        .containsKey(PurchaseService.entitlementId);
    notifyListeners();
    return _isPremium;
  }
}
