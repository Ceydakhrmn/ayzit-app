import 'package:ayzit_app/models/notification_prefs.dart';
import 'package:ayzit_app/models/period_log.dart';
import 'package:ayzit_app/models/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

List<DateTime> range(DateTime start, int days) => [
      for (var i = 0; i < days; i++)
        DateTime(start.year, start.month, start.day + i),
    ];

const _none = NotificationPrefs(
  periodStart: false,
  periodEnd: false,
  exerciseReminder: false,
  waterReminder: false,
);

List<PlannedReminder> plan({
  NotificationPrefs prefs = _none,
  PeriodLog? log,
  int cycleLength = 28,
  int periodLength = 5,
  DateTime? active,
  required DateTime now,
  bool isTurkish = true,
}) =>
    ReminderPlanner.plan(
      prefs: prefs,
      log: log ?? PeriodLog(const []),
      cycleLength: cycleLength,
      periodLength: periodLength,
      activePeriodStart: active,
      now: now,
      isTurkish: isTurkish,
    );

void main() {
  group('Regl başladı mı', () {
    final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
    const prefs = NotificationPrefs(
      periodEnd: false,
      exerciseReminder: false,
      waterReminder: false,
    );

    test('tahmini regl günlerinin sabahı 09:00, 3 döngü', () {
      final r = plan(prefs: prefs, log: log, now: DateTime(2026, 9, 10, 12));
      expect(r.map((e) => e.when), [
        DateTime(2026, 9, 29, 9),
        DateTime(2026, 10, 27, 9),
        DateTime(2026, 11, 24, 9),
      ]);
      expect(r.first.title, 'Reglin başladı mı? 🌸');
      expect(r.every((e) => e.kind == ReminderKind.periodStart), isTrue);
    });

    test('tarih özetteki tahminle aynı (ayardaki döngüye göre)', () {
      final r = plan(
          prefs: prefs, log: log, cycleLength: 35, now: DateTime(2026, 9, 10));
      final f = forecastCycle(
          log: log, cycleLength: 35, periodLength: 5, today: DateTime(2026, 9, 10))!;
      expect(r.first.when, DateTime(f.nextPeriod.year, f.nextPeriod.month,
          f.nextPeriod.day, 9));
    });

    test('bugünün 09:00\'u geçtiyse o gün atlanır', () {
      final r = plan(prefs: prefs, log: log, now: DateTime(2026, 9, 29, 10));
      expect(r.first.when, DateTime(2026, 10, 27, 9));
      expect(r, hasLength(3));
    });

    test('hiç regl kaydı yoksa hatırlatma kurulmaz', () {
      expect(plan(prefs: prefs, now: DateTime(2026, 9, 10)), isEmpty);
    });

    test('İngilizce metin', () {
      final r = plan(
          prefs: prefs, log: log, now: DateTime(2026, 9, 10), isTurkish: false);
      expect(r.first.title, 'Has your period started? 🌸');
    });
  });

  group('Regl bitti', () {
    const prefs = NotificationPrefs(
      periodStart: false,
      exerciseReminder: false,
      waterReminder: false,
    );

    test('devam eden reglin ayardaki son günü 20:00', () {
      final r = plan(
          prefs: prefs,
          active: DateTime(2026, 10, 1),
          now: DateTime(2026, 10, 2, 8));
      expect(r.single.when, DateTime(2026, 10, 5, 20));
      expect(r.single.kind, ReminderKind.periodEnd);
    });

    test('aktif regl yoksa ya da süre geçtiyse kurulmaz', () {
      expect(plan(prefs: prefs, now: DateTime(2026, 10, 2)), isEmpty);
      expect(
          plan(
              prefs: prefs,
              active: DateTime(2026, 10, 1),
              now: DateTime(2026, 10, 5, 21)),
          isEmpty);
    });
  });

  group('Egzersiz', () {
    const prefs = NotificationPrefs(
      periodStart: false,
      periodEnd: false,
      waterReminder: false,
      exerciseReminderIntervalDays: 3,
    );

    test('her 3 günde bir 18:00, 8 adet', () {
      final r = plan(prefs: prefs, now: DateTime(2026, 10, 3, 10));
      expect(r, hasLength(ReminderPlanner.exerciseCount));
      expect(r.first.when, DateTime(2026, 10, 3, 18));
      expect(r[1].when, DateTime(2026, 10, 6, 18));
    });

    test('18:00 geçtiyse ertesi gün başlar', () {
      final r = plan(prefs: prefs, now: DateTime(2026, 10, 3, 19));
      expect(r.first.when, DateTime(2026, 10, 4, 18));
    });
  });

  group('Su', () {
    const prefs = NotificationPrefs(
      periodStart: false,
      periodEnd: false,
      exerciseReminder: false,
      waterReminder: true,
      waterReminderIntervalMinutes: 120,
    );

    test('yalnızca 09:00–22:00 arası, seçilen aralıkla', () {
      final r = plan(prefs: prefs, now: DateTime(2026, 10, 3, 7));
      final today = r.where((e) => e.when.day == 3).map((e) => e.when.hour);
      expect(today, [9, 11, 13, 15, 17, 19, 21]);
      expect(r.every((e) => e.when.hour >= 9 && e.when.hour <= 22), isTrue);
    });

    test('geçmiş saatler atlanır, 3 gün planlanır', () {
      final r = plan(prefs: prefs, now: DateTime(2026, 10, 3, 16));
      expect(r.first.when, DateTime(2026, 10, 3, 17));
      expect(r.last.when.day, 5);
    });

    test('15 dakikalık aralıkta sınır aşılmaz', () {
      final r = plan(
          prefs: prefs.copyWith(waterReminderIntervalMinutes: 15),
          now: DateTime(2026, 10, 3, 7));
      expect(r.length, lessThanOrEqualTo(ReminderPlanner.waterMax));
    });
  });

  test('kimlikler benzersiz ve randevu aralığının dışında', () {
    final r = plan(
      prefs: const NotificationPrefs(waterReminder: true),
      log: PeriodLog(range(DateTime(2026, 9, 1), 5)),
      active: DateTime(2026, 10, 1),
      now: DateTime(2026, 10, 2, 7),
    );
    final ids = r.map((e) => e.id).toSet();
    expect(ids.length, r.length);
    expect(ids.every((id) => id >= 700000010), isTrue);
    expect(
        ids.every((id) => id < kReminderIdBase + ReminderPlanner.idCount), isTrue);
    expect(r.map((e) => e.kind).toSet(), ReminderKind.values.toSet());
  });

  test('tüm bildirimler kapalıysa hiçbir şey kurulmaz', () {
    final r = plan(
      prefs: const NotificationPrefs(appNotifications: false),
      log: PeriodLog(range(DateTime(2026, 9, 1), 5)),
      now: DateTime(2026, 10, 2),
    );
    expect(r, isEmpty);
  });
}
