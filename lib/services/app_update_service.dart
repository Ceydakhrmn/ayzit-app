// =============================================
// services/app_update_service.dart
// Google Play uygulama içi güncelleme (esnek mod):
//   • Açılışta Play'de yeni sürüm var mı bakar
//   • Varsa Play'in "Güncelle" penceresini gösterir
//   • Kullanıcı kabul ederse indirme arka planda sürer; bitince
//     [onDownloaded] çağrılır ve arayüz "Yeniden başlat" seçeneği sunar
//
// Yalnızca Play Store'dan yüklenmiş Android release sürümlerinde çalışır;
// debug / emülatör / diğer platformlarda sessizce hiçbir şey yapmaz.
// =============================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  bool _checked = false;

  bool get _supported => !kIsWeb && Platform.isAndroid && kReleaseMode;

  /// Uygulama açılışında bir kez çağrılır.
  Future<void> checkForUpdate({required VoidCallback onDownloaded}) async {
    if (_checked || !_supported) return;
    _checked = true;
    try {
      final info = await InAppUpdate.checkForUpdate();

      // Önceki açılışta indirilmiş ama henüz kurulmamış güncelleme.
      if (info.installStatus == InstallStatus.downloaded) {
        onDownloaded();
        return;
      }
      if (info.updateAvailability != UpdateAvailability.updateAvailable ||
          !info.flexibleUpdateAllowed) {
        return;
      }

      // İndirme tamamlanınca (ya da kullanıcı reddedince) döner.
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) onDownloaded();
    } on PlatformException catch (e) {
      debugPrint('AppUpdateService: ${e.code} ${e.message}');
    } catch (e) {
      debugPrint('AppUpdateService: $e');
    }
  }

  /// İndirilen güncellemeyi kurar; uygulama yeniden başlar. Eklenti bu
  /// çağrıyı hiç tamamlamadığı için beklenmez.
  void installDownloadedUpdate() {
    if (!_supported) return;
    InAppUpdate.completeFlexibleUpdate().catchError((Object e) {
      debugPrint('AppUpdateService.install: $e');
    });
  }
}
