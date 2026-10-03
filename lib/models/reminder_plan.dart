// =============================================
// models/reminder_plan.dart
// Ayarlardaki bildirim tercihlerinden telefonda planlanacak hatırlatmaları
// çıkaran saf (eklentisiz) mantık. Planlama [ReminderNotificationService]
// tarafından yapılır; burada yalnızca "ne, ne zaman" hesaplanır.
//
//   • Regl başladı → tahmini regl gününün sabahı (takvimle aynı tahmin)
//   • Regl bitti   → devam eden reglin ayardaki süresinin son günü akşamı
//   • Egzersiz     → her N günde bir, akşam
//   • Su           → seçilen aralıkla, yalnızca gündüz saatlerinde
// =============================================

import 'notification_prefs.dart';
import 'period_log.dart';

/// Randevu bildirimlerinin kimlikleri 700.000.000'in altında kalır;
/// hatırlatmalar bu aralığın üstünü kullanır.
const int kReminderIdBase = 800000000;

enum ReminderKind { periodStart, periodEnd, exercise, water }

class PlannedReminder {
  final int id;
  final ReminderKind kind;
  final DateTime when;
  final String title;
  final String body;

  const PlannedReminder({
    required this.id,
    required this.kind,
    required this.when,
    required this.title,
    required this.body,
  });
}

class ReminderPlanner {
  /// Kaç tahmini regl başlangıcı için hatırlatma kurulur.
  static const int periodStartCount = 3;

  /// Kaç egzersiz hatırlatması önceden kurulur.
  static const int exerciseCount = 8;

  /// Su hatırlatmaları kaç gün için ve en fazla kaç adet kurulur.
  static const int waterDays = 3;
  static const int waterMax = 120;

  static const int periodStartHour = 9;
  static const int periodEndHour = 20;
  static const int exerciseHour = 18;
  static const int waterFromHour = 9;
  static const int waterUntilHour = 22;

  // Her tür kendi kimlik aralığını kullanır; iptal ederken tümü silinir.
  static const int _periodStartSlot = 0;
  static const int _periodEndSlot = 50;
  static const int _exerciseSlot = 100;
  static const int _waterSlot = 200;
  static const int idCount = _waterSlot + waterMax;

  static List<PlannedReminder> plan({
    required NotificationPrefs prefs,
    required PeriodLog log,
    required int cycleLength,
    required int periodLength,
    required DateTime? activePeriodStart,
    required DateTime now,
    required bool isTurkish,
  }) {
    if (!prefs.appNotifications) return const [];
    return [
      if (prefs.periodStart)
        ..._periodStart(log, cycleLength, periodLength, now, isTurkish),
      if (prefs.periodEnd)
        ..._periodEnd(activePeriodStart, periodLength, now, isTurkish),
      if (prefs.exerciseReminder)
        ..._exercise(prefs.exerciseReminderIntervalDays, now, isTurkish),
      if (prefs.waterReminder)
        ..._water(prefs.waterReminderIntervalMinutes, now, isTurkish),
    ];
  }

  static List<PlannedReminder> _periodStart(PeriodLog log, int cycleLength,
      int periodLength, DateTime now, bool isTurkish) {
    final forecast = forecastCycle(
      log: log,
      cycleLength: cycleLength,
      periodLength: periodLength,
      today: now,
    );
    if (forecast == null) return const [];
    // Regl gecikmişse ilk tahmin bugünden önce olabilir; o atlanır.
    final day = forecast.nextPeriod;
    final result = <PlannedReminder>[];
    for (var k = 0;
        k <= periodStartCount && result.length < periodStartCount;
        k++) {
      final when = DateTime(
          day.year, day.month, day.day + k * cycleLength, periodStartHour);
      if (!when.isAfter(now)) continue;
      result.add(PlannedReminder(
        id: kReminderIdBase + _periodStartSlot + result.length,
        kind: ReminderKind.periodStart,
        when: when,
        title: isTurkish ? 'Reglin başladı mı? 🌸' : 'Has your period started? 🌸',
        body: isTurkish
            ? 'Bugün tahmini regl günün. Başladıysa takvimden "Regl başlat"a dokun.'
            : 'Today is your estimated period day. If it started, tap "Start period".',
      ));
    }
    return result;
  }

  static List<PlannedReminder> _periodEnd(DateTime? activeStart,
      int periodLength, DateTime now, bool isTurkish) {
    if (activeStart == null || periodLength < 1) return const [];
    final when = DateTime(activeStart.year, activeStart.month,
        activeStart.day + periodLength - 1, periodEndHour);
    if (!when.isAfter(now)) return const [];
    return [
      PlannedReminder(
        id: kReminderIdBase + _periodEndSlot,
        kind: ReminderKind.periodEnd,
        when: when,
        title: isTurkish
            ? 'Reglin bugün bitiyor olabilir'
            : 'Your period may end today',
        body: isTurkish
            ? 'Bittiyse "Regl bitir"e dokunarak kaydedebilirsin.'
            : 'If it has ended, tap "End period" to log it.',
      ),
    ];
  }

  static List<PlannedReminder> _exercise(
      int intervalDays, DateTime now, bool isTurkish) {
    final every = intervalDays < 1 ? 1 : intervalDays;
    var first = DateTime(now.year, now.month, now.day, exerciseHour);
    if (!first.isAfter(now)) {
      first = DateTime(now.year, now.month, now.day + 1, exerciseHour);
    }
    return [
      for (var i = 0; i < exerciseCount; i++)
        PlannedReminder(
          id: kReminderIdBase + _exerciseSlot + i,
          kind: ReminderKind.exercise,
          when: DateTime(
              first.year, first.month, first.day + i * every, exerciseHour),
          title: isTurkish ? 'Biraz hareket zamanı 🧘‍♀️' : 'Time to move a little 🧘‍♀️',
          body: isTurkish
              ? 'Kısa bir egzersizle kendine iyi gel.'
              : 'A short exercise can make you feel good.',
        ),
    ];
  }

  static List<PlannedReminder> _water(
      int intervalMinutes, DateTime now, bool isTurkish) {
    final step = intervalMinutes < 15 ? 15 : intervalMinutes;
    final result = <PlannedReminder>[];
    for (var d = 0; d < waterDays && result.length < waterMax; d++) {
      var t = DateTime(now.year, now.month, now.day + d, waterFromHour);
      final until = DateTime(now.year, now.month, now.day + d, waterUntilHour);
      while (!t.isAfter(until) && result.length < waterMax) {
        if (t.isAfter(now)) {
          result.add(PlannedReminder(
            id: kReminderIdBase + _waterSlot + result.length,
            kind: ReminderKind.water,
            when: t,
            title: isTurkish ? 'Su içme zamanı 💧' : 'Time for some water 💧',
            body: isTurkish
                ? 'Bir bardak su içmeye ne dersin?'
                : 'How about a glass of water?',
          ));
        }
        t = t.add(Duration(minutes: step));
      }
    }
    return result;
  }
}
