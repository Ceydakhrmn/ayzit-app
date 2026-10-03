// =============================================
// services/reminder_notification_service.dart
// Ayarlardaki regl / egzersiz / su hatırlatmalarını telefonda planlar.
// Sunucu gerekmez; randevu bildirimleriyle aynı altyapıyı kullanır.
// Plan her değiştiğinde (tercih, regl kaydı, dil, yeni gün) önceki
// hatırlatmalar iptal edilip yenileri kurulur.
// =============================================

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_plan.dart';
import 'appointment_notification_service.dart';

class ReminderNotificationService {
  ReminderNotificationService._();
  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  String? _lastSignature;

  NotificationDetails _details(ReminderKind kind) {
    final android = switch (kind) {
      ReminderKind.periodStart || ReminderKind.periodEnd =>
        const AndroidNotificationDetails(
          'cycle_reminder_channel',
          'Regl Hatırlatıcıları',
          channelDescription: 'Tahmini regl başlangıcı ve bitişi',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ReminderKind.exercise => const AndroidNotificationDetails(
          'exercise_reminder_channel',
          'Egzersiz Hatırlatıcısı',
          channelDescription: 'Düzenli egzersiz hatırlatmaları',
        ),
      ReminderKind.water => const AndroidNotificationDetails(
          'water_reminder_channel',
          'Su İçme Hatırlatıcısı',
          channelDescription: 'Gün içinde su içme hatırlatmaları',
        ),
    };
    return NotificationDetails(
      android: android,
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Hatırlatmaları [plan]'a göre yeniden kurar. Aynı [signature] ile tekrar
  /// çağrılırsa hiçbir şey yapmaz.
  Future<void> sync(List<PlannedReminder> plan, String signature) async {
    if (kIsWeb || signature == _lastSignature) return;
    _lastSignature = signature;
    try {
      // Saat dilimi ve eklenti kurulumu randevu servisinde yapılır.
      await AppointmentNotificationService.instance.init();
      await _cancelAll();
      for (final r in plan) {
        await _plugin.zonedSchedule(
          r.id,
          r.title,
          r.body,
          tz.TZDateTime.from(r.when, tz.local),
          _details(r.kind),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      _lastSignature = null;
      debugPrint('ReminderNotificationService.sync: $e');
    }
  }

  /// Çıkış yapılınca çağrılır; başka hesap bu cihazda hatırlatma almasın.
  Future<void> cancelAll() async {
    _lastSignature = null;
    if (kIsWeb) return;
    try {
      await _cancelAll();
    } catch (e) {
      debugPrint('ReminderNotificationService.cancelAll: $e');
    }
  }

  /// Yalnızca hatırlatma kimlik aralığındaki bekleyen bildirimleri siler;
  /// randevu bildirimlerine dokunmaz.
  Future<void> _cancelAll() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id >= kReminderIdBase &&
          p.id < kReminderIdBase + ReminderPlanner.idCount) {
        await _plugin.cancel(p.id);
      }
    }
  }
}
