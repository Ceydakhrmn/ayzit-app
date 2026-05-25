// =============================================
// services/appointment_notification_service.dart
// Randevular için yerel bildirim planlar.
// Her randevuya 4 hatırlatma: 1 gün önce, randevu sabahı (09:00),
// 1 saat önce, ve randevu saatinde. Geçmişte kalan zamanlar atlanır.
// Randevu eklenince anında bir onay bildirimi gösterilir.
// =============================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment.dart';

class AppointmentNotificationService {
  AppointmentNotificationService._();
  static final AppointmentNotificationService instance =
      AppointmentNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tzdata.initializeTimeZones();
    // Uygulama Türkçe — varsayılan olarak Türkiye saat dilimi kullanılır.
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Android 13+ bildirim izni iste.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      'appointment_channel',
      'Randevu Hatırlatıcıları',
      channelDescription:
          'Doktor randevuları ve önemli tarihler için hatırlatmalar',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  /// Randevu eklenir eklenmez gösterilen anında onay bildirimi.
  /// Kullanıcıya bildirimlerin çalıştığını ve hatırlatmaların kurulduğunu gösterir.
  Future<void> showAddedConfirmation(Appointment a) async {
    await init();
    await _plugin.show(
      a.notificationBaseId + 9,
      'Randevu eklendi',
      '${a.title} — hatırlatmalar kuruldu.',
      _details(),
    );
  }

  /// Bir randevu için hatırlatmaları planlar. Önce eski bildirimlerini iptal eder.
  Future<void> scheduleForAppointment(Appointment a) async {
    await init();
    await cancelForAppointment(a);

    final dt = a.dateTime;
    final now = DateTime.now();
    final clock = _clock(dt);

    // Sıra önemli: cancel ile aynı slot kimliklerini korur.
    final reminders = <DateTime, String>{
      dt.subtract(const Duration(days: 1)): 'Yarın: ${a.title} ($clock)',
      DateTime(dt.year, dt.month, dt.day, 9, 0): 'Bugün: ${a.title} ($clock)',
      dt.subtract(const Duration(hours: 1)): '1 saat sonra: ${a.title}',
      dt: 'Randevu saati geldi: ${a.title}',
    };

    var slot = 0;
    for (final entry in reminders.entries) {
      final when = entry.key;
      if (when.isAfter(now)) {
        await _plugin.zonedSchedule(
          a.notificationBaseId + slot,
          'Randevu hatırlatması',
          entry.value,
          tz.TZDateTime.from(when, tz.local),
          _details(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      slot++;
    }
  }

  /// Bir randevuya ait tüm bildirimleri iptal eder.
  Future<void> cancelForAppointment(Appointment a) async {
    for (var i = 0; i < 4; i++) {
      await _plugin.cancel(a.notificationBaseId + i);
    }
  }

  String _clock(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
