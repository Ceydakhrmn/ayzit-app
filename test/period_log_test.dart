import 'package:ayzit_app/models/cycle_model.dart';
import 'package:ayzit_app/models/period_log.dart';
import 'package:flutter_test/flutter_test.dart';

List<DateTime> range(DateTime start, int days) => [
      for (var i = 0; i < days; i++)
        DateTime(start.year, start.month, start.day + i),
    ];

void main() {
  group('PeriodLog.spans', () {
    test('art arda günler tek döneme gruplanır', () {
      final log = PeriodLog(range(DateTime(2026, 9, 12), 8));
      expect(log.spans, hasLength(1));
      expect(log.spans.single.start, DateTime(2026, 9, 12));
      expect(log.spans.single.end, DateTime(2026, 9, 19));
      expect(log.spans.single.length, 8);
    });

    test('arada tek işaretsiz gün dönemi bölmez, daha uzun boşluk böler', () {
      final oneGap = PeriodLog([
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 4),
      ]);
      expect(oneGap.spans, hasLength(1));

      final twoGap = PeriodLog([
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 5),
      ]);
      expect(twoGap.spans, hasLength(2));
    });

    test('sırasız ve tekrarlı girdi normalize edilir', () {
      final log = PeriodLog([
        DateTime(2026, 9, 3, 14, 30),
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 1, 8),
      ]);
      expect(log.days, [
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 3),
      ]);
    });
  });

  group('Sinem senaryosu: 12–19 Eylül ve 28 Eylül–5 Ekim', () {
    final log = PeriodLog([
      ...range(DateTime(2026, 9, 12), 8),
      ...range(DateTime(2026, 9, 28), 8),
    ]);

    test('iki ayrı dönem olarak görünür', () {
      expect(log.spans, hasLength(2));
      expect(log.spans[0].length, 8);
      expect(log.spans[1].start, DateTime(2026, 9, 28));
      expect(log.spans[1].end, DateTime(2026, 10, 5));
    });

    test('gerçek döngü uzunluğu hesaplanır', () {
      expect(log.cycleLengths(), [16]);
      expect(log.averageCycleLength(), 16);
    });

    test('ikinci dönem ilk dönemi silmez', () {
      expect(log.contains(DateTime(2026, 9, 15)), isTrue);
      expect(log.contains(DateTime(2026, 10, 1)), isTrue);
      expect(log.contains(DateTime(2026, 9, 22)), isFalse);
    });
  });

  group('düzensiz döngü ortalaması', () {
    test('28 / 40 / 28 günlük döngülerin ortalaması alınır', () {
      final log = PeriodLog([
        ...range(DateTime(2026, 1, 1), 5),
        ...range(DateTime(2026, 1, 29), 10), // 28 gün sonra, 10 gün
        ...range(DateTime(2026, 3, 10), 5), // 40 gün sonra
        ...range(DateTime(2026, 4, 7), 5), // 28 gün sonra
      ]);
      expect(log.cycleLengths(), [28, 40, 28]);
      expect(log.averageCycleLength(), 32);
      expect(log.averagePeriodLength(), 6); // (5+10+5+5)/4 = 6.25
    });

    test('60 güne kadar döngüler ortalamaya girer, çok uzunlar girmez', () {
      final log = PeriodLog([
        ...range(DateTime(2026, 1, 1), 5),
        ...range(DateTime(2026, 1, 31), 5), // 30 gün
        ...range(DateTime(2026, 4, 1), 5), // tam 60 gün → sınır dahil
      ]);
      expect(log.cycleLengths(), [30, 60]);
      expect(log.averageCycleLength(lastN: 6), 45);

      final withOutlier = PeriodLog([
        ...range(DateTime(2026, 1, 1), 5),
        ...range(DateTime(2026, 1, 31), 5), // 30 gün
        ...range(DateTime(2026, 5, 1), 5), // 90 gün (bir ay unutulmuş) → dışarıda
      ]);
      expect(withOutlier.averageCycleLength(), 30);
    });

    test('tek dönem varsa döngü ortalaması yoktur', () {
      final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
      expect(log.averageCycleLength(), isNull);
      expect(PeriodLog(const []).averagePeriodLength(), isNull);
    });

    test('devam eden regl süre ortalamasına katılmaz', () {
      final log = PeriodLog([
        ...range(DateTime(2026, 8, 1), 7),
        ...range(DateTime(2026, 9, 1), 2), // henüz 2. günde
      ]);
      expect(log.averagePeriodLength(), 5); // (7+2)/2 = 4.5 → 5
      expect(
        log.averagePeriodLength(excludeOngoingFrom: DateTime(2026, 9, 1)),
        7,
      );
    });
  });

  group('arama yardımcıları', () {
    final log = PeriodLog([
      ...range(DateTime(2026, 8, 1), 5),
      ...range(DateTime(2026, 9, 1), 5),
    ]);

    test('spanCovering', () {
      expect(log.spanCovering(DateTime(2026, 8, 3))!.start, DateTime(2026, 8, 1));
      expect(log.spanCovering(DateTime(2026, 8, 20)), isNull);
    });

    test('lastSpanStartingOnOrBefore / firstSpanStartingAfter', () {
      expect(log.lastSpanStartingOnOrBefore(DateTime(2026, 7, 1)), isNull);
      expect(log.lastSpanStartingOnOrBefore(DateTime(2026, 8, 20))!.start,
          DateTime(2026, 8, 1));
      expect(log.lastSpanStartingOnOrBefore(DateTime(2026, 9, 1))!.start,
          DateTime(2026, 9, 1));
      expect(log.firstSpanStartingAfter(DateTime(2026, 8, 1))!.start,
          DateTime(2026, 9, 1));
      expect(log.firstSpanStartingAfter(DateTime(2026, 9, 1)), isNull);
    });
  });

  group('anahtar / tarih', () {
    test('keyOf ve parseKey birbirinin tersidir', () {
      final d = DateTime(2026, 3, 7);
      expect(PeriodLog.keyOf(d), '2026-03-07');
      expect(PeriodLog.parseKey('2026-03-07'), d);
      expect(PeriodLog.parseKey('bozuk'), isNull);
    });

    test('fromKeys geçersiz anahtarları atlar', () {
      final log = PeriodLog.fromKeys(['2026-09-01', 'x', '2026-09-02']);
      expect(log.days, [DateTime(2026, 9, 1), DateTime(2026, 9, 2)]);
    });

    test('daysBetween yaz saati geçişinden etkilenmez', () {
      expect(PeriodLog.daysBetween(DateTime(2026, 3, 28), DateTime(2026, 4, 2)), 5);
      expect(PeriodLog.daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 27)), 3);
    });
  });

  group('phaseForDay (takvim renkleri)', () {
    // cycleLength / periodLength: kullanıcının ayarlardaki değerleri.
    DayPhase phase(
      PeriodLog log,
      DateTime date, {
      DateTime? active,
      int cycleLength = 28,
      int periodLength = 5,
    }) =>
        phaseForDay(
          date: date,
          log: log,
          cycleLength: cycleLength,
          periodLength: periodLength,
          activePeriodStart: active,
        );

    test('Sinem: iki dönemin de günleri regl rengi alır', () {
      final log = PeriodLog([
        ...range(DateTime(2026, 9, 12), 8),
        ...range(DateTime(2026, 9, 28), 8),
      ]);
      expect(phase(log, DateTime(2026, 9, 12)), DayPhase.periodPeak);
      expect(phase(log, DateTime(2026, 9, 19)), DayPhase.periodLight);
      expect(phase(log, DateTime(2026, 9, 28)), DayPhase.periodPeak);
      expect(phase(log, DateTime(2026, 10, 5)), DayPhase.periodLight);
      // Arada işaretsiz günler regl olarak boyanmaz.
      expect(phase(log, DateTime(2026, 9, 22)), DayPhase.none);
    });

    test('iki kayıt arasında gerçek döngü uzunluğuyla ovulasyon', () {
      // 1 Ocak ve 10 Şubat: 40 günlük döngü → ovulasyon 26. gün (26 Ocak)
      final log = PeriodLog([
        ...range(DateTime(2026, 1, 1), 5),
        ...range(DateTime(2026, 2, 10), 5),
      ]);
      expect(phase(log, DateTime(2026, 1, 26)), DayPhase.ovulation);
      // Sabit 28 gün varsayılsaydı 14 Ocak ovulasyon olurdu; artık değil.
      expect(phase(log, DateTime(2026, 1, 14)), DayPhase.none);
    });

    test('son kayıttan sonrası ayarlardaki döngüyle tahmin edilir', () {
      // 28 günlük düzenli döngü: 1 Ocak, 29 Ocak
      final log = PeriodLog([
        ...range(DateTime(2026, 1, 1), 5),
        ...range(DateTime(2026, 1, 29), 5),
      ]);
      expect(phase(log, DateTime(2026, 2, 11)), DayPhase.ovulation); // 14. gün
      // Tahmini sonraki regl (26 Şubat – 2 Mart) soluk gösterilir.
      expect(phase(log, DateTime(2026, 2, 26)), DayPhase.periodPredicted);
      expect(phase(log, DateTime(2026, 3, 2)), DayPhase.periodPredicted);
      expect(phase(log, DateTime(2026, 3, 3)), DayPhase.none);
      // Bir sonraki tahmini döngünün ovulasyonu da gösterilir.
      expect(phase(log, DateTime(2026, 3, 11)), DayPhase.ovulation);
    });

    test('tahmini regl: kayıtlı dönem ve bugünden önceki günler soluk olmaz', () {
      // 1 Eylül'de 3 gün işaretli, ayar 5 gün: 4–5 Eylül tahmin değil.
      final log = PeriodLog(range(DateTime(2026, 9, 1), 3));
      DayPhase p(DateTime d) => phaseForDay(
          date: d,
          log: log,
          cycleLength: 28,
          periodLength: 5,
          today: DateTime(2026, 9, 30));
      expect(p(DateTime(2026, 9, 4)), DayPhase.none);
      // Tahmini regl 29 Eylül – 3 Ekim; bugün 30 Eylül → 29'u geçmişte kaldı.
      expect(p(DateTime(2026, 9, 29)), DayPhase.none);
      expect(p(DateTime(2026, 9, 30)), DayPhase.periodPredicted);
      expect(p(DateTime(2026, 10, 3)), DayPhase.periodPredicted);
      expect(p(DateTime(2026, 10, 27)), DayPhase.periodPredicted);
    });

    test('ayarlardaki döngü uzunluğu değişince tahmin de değişir', () {
      // Tek kayıt: 1 Ocak. Ayar 32 gün → ovulasyon 18. gün (18 Ocak).
      final log = PeriodLog(range(DateTime(2026, 1, 1), 5));
      expect(phase(log, DateTime(2026, 1, 18), cycleLength: 32),
          DayPhase.ovulation);
      expect(phase(log, DateTime(2026, 1, 14), cycleLength: 32),
          isNot(DayPhase.ovulation));
    });

    test('devam eden reglin gelecek günleri ayardaki süre kadar boyanır', () {
      // Yeni regl 1 Ekim'de başladı; ayarda regl süresi 6 gün.
      final log = PeriodLog([
        ...range(DateTime(2026, 9, 1), 4),
        DateTime(2026, 10, 1),
      ]);
      final active = DateTime(2026, 10, 1);
      expect(phase(log, DateTime(2026, 10, 3), active: active, periodLength: 6),
          DayPhase.periodMid);
      expect(phase(log, DateTime(2026, 10, 6), active: active, periodLength: 6),
          DayPhase.periodLight);
      expect(phase(log, DateTime(2026, 10, 7), active: active, periodLength: 6),
          DayPhase.none);
      // Ayar 5 gün olsaydı 6 Ekim boyanmazdı.
      expect(phase(log, DateTime(2026, 10, 6), active: active), DayPhase.none);
    });

    test('ilk kayıttan önceki günler boş kalır', () {
      final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
      expect(phase(log, DateTime(2026, 8, 20)), DayPhase.none);
    });

    test('hiç kaydı olmayan (yeni) kullanıcıya hiçbir gün atanmaz', () {
      final log = PeriodLog(const []);
      for (final d in range(DateTime(2026, 8, 1), 90)) {
        expect(phase(log, d), DayPhase.none, reason: '$d');
      }
    });
  });

  group('forecastCycle (sonraki regl / ovulasyon / doğurganlık)', () {
    CycleForecast? fc(PeriodLog log, DateTime today,
            {int cycleLength = 28, int periodLength = 5}) =>
        forecastCycle(
          log: log,
          cycleLength: cycleLength,
          periodLength: periodLength,
          today: today,
        );

    test('kayıt yoksa tahmin yok', () {
      expect(fc(PeriodLog(const []), DateTime(2026, 9, 30)), isNull);
    });

    test('28 günlük döngü: 1 Eylül regl → 14 Eylül ovulasyon', () {
      final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
      final f = fc(log, DateTime(2026, 9, 3))!;
      expect(f.nextPeriod, DateTime(2026, 9, 29));
      expect(f.ovulation, DateTime(2026, 9, 14));
      expect(f.fertileStart, DateTime(2026, 9, 9));
      expect(f.fertileEnd, DateTime(2026, 9, 15));
    });

    test('pencere geçtiyse bir sonraki döngünün penceresi gösterilir', () {
      final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
      final f = fc(log, DateTime(2026, 9, 20))!;
      expect(f.nextPeriod, DateTime(2026, 9, 29));
      expect(f.ovulation, DateTime(2026, 10, 12));
      // Pencerenin içindeyken aynı pencere kalır.
      expect(fc(log, DateTime(2026, 9, 15))!.ovulation, DateTime(2026, 9, 14));
    });

    test('gecikmiş regl: tahmini günler sürerken sonraki regl o dönemdir', () {
      final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
      // Tahmini regl 29 Eylül – 3 Ekim; bugün 1 Ekim, henüz işaretlenmedi.
      expect(fc(log, DateTime(2026, 10, 1))!.nextPeriod, DateTime(2026, 9, 29));
      // Tahmini dönem bitince bir sonraki döngüye geçer.
      expect(fc(log, DateTime(2026, 10, 4))!.nextPeriod, DateTime(2026, 10, 27));
    });

    test('regl olarak işaretli günler doğurganlık penceresine girmez', () {
      // 18–30 Eylül işaretli (uzun regl). Ovulasyon 1 Ekim.
      final log = PeriodLog(range(DateTime(2026, 9, 18), 13));
      final f = fc(log, DateTime(2026, 9, 30))!;
      expect(f.ovulation, DateTime(2026, 10, 1));
      expect(f.fertileStart, DateTime(2026, 10, 1));
      expect(f.fertileEnd, DateTime(2026, 10, 2));

      // Ovulasyon günü de işaretliyse sonraki döngünün penceresi gösterilir.
      final longer = PeriodLog(range(DateTime(2026, 9, 18), 15));
      expect(fc(longer, DateTime(2026, 9, 30))!.ovulation,
          DateTime(2026, 10, 29));
    });

    test('ayardaki döngü uzunluğuna göre kayar', () {
      final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
      final f = fc(log, DateTime(2026, 9, 3), cycleLength: 35)!;
      expect(f.nextPeriod, DateTime(2026, 10, 6));
      expect(f.ovulation, DateTime(2026, 9, 21));
    });

    test('regl süresine çok yakın kısa döngüde ovulasyon hesaplanmaz', () {
      final log = PeriodLog(range(DateTime(2026, 9, 1), 5));
      final f = fc(log, DateTime(2026, 9, 3), cycleLength: 21, periodLength: 8)!;
      expect(f.ovulation, isNull);
      expect(f.nextPeriod, DateTime(2026, 9, 22));
    });

    test('tahmin takvim renkleriyle birebir aynı', () {
      final log = PeriodLog([
        ...range(DateTime(2026, 8, 3), 6),
        ...range(DateTime(2026, 9, 1), 5),
      ]);
      for (final len in [24, 28, 32, 40]) {
        final f = fc(log, DateTime(2026, 9, 2), cycleLength: len)!;
        DayPhase p(DateTime d) => phaseForDay(
            date: d, log: log, cycleLength: len, periodLength: 5);
        const fertile = {
          DayPhase.fertilelow,
          DayPhase.fertileMid,
          DayPhase.fertilePeak,
          DayPhase.ovulation,
        };
        expect(p(f.ovulation!), DayPhase.ovulation, reason: 'döngü $len');
        for (var d = f.fertileStart!;
            !d.isAfter(f.fertileEnd!);
            d = DateTime(d.year, d.month, d.day + 1)) {
          expect(fertile, contains(p(d)), reason: 'döngü $len, $d');
        }
        // Pencerenin hemen dışı doğurganlık rengi almaz (regl günü olabilir).
        final before = DateTime(f.fertileStart!.year, f.fertileStart!.month,
            f.fertileStart!.day - 1);
        final after = DateTime(
            f.fertileEnd!.year, f.fertileEnd!.month, f.fertileEnd!.day + 1);
        expect(fertile, isNot(contains(p(before))), reason: 'döngü $len');
        expect(fertile, isNot(contains(p(after))), reason: 'döngü $len');
      }
    });
  });

  group('applyPeriodEnd (Regl bitir)', () {
    Set<String> keysOf(List<DateTime> days) =>
        days.map(PeriodLog.keyOf).toSet();

    test('Sinem: 17–23 biter, 26 başlar → 24 ve 25 alınmaz', () {
      final keys = keysOf([DateTime(2026, 9, 17)]); // 17'de başlatıldı
      final last = PeriodLog.applyPeriodEnd(
          keys, DateTime(2026, 9, 17), DateTime(2026, 9, 23));
      expect(last, DateTime(2026, 9, 23));

      keys.add(PeriodLog.keyOf(DateTime(2026, 9, 26))); // 26'da yeniden başladı
      PeriodLog.applyPeriodEnd(
          keys, DateTime(2026, 9, 26), DateTime(2026, 9, 29));

      final log = PeriodLog.fromKeys(keys);
      expect(log.contains(DateTime(2026, 9, 24)), isFalse);
      expect(log.contains(DateTime(2026, 9, 25)), isFalse);
      expect(log.spans, hasLength(2));
      expect(log.spans[0].end, DateTime(2026, 9, 23));
      expect(log.spans[1].start, DateTime(2026, 9, 26));
      expect(log.spans[1].end, DateTime(2026, 9, 29));
    });

    test('bitişten sonra yanlışlıkla doldurulmuş bitişik günler temizlenir', () {
      // Eski sürüm "Bitir"de bugüne (30) kadar doldurmuştu.
      final keys = keysOf(range(DateTime(2026, 9, 17), 14)); // 17–30
      PeriodLog.applyPeriodEnd(
          keys, DateTime(2026, 9, 17), DateTime(2026, 9, 23));
      expect(PeriodLog.fromKeys(keys).days, range(DateTime(2026, 9, 17), 7));
    });

    test('bitişik olmayan sonraki dönemlere dokunulmaz', () {
      final keys = keysOf([
        DateTime(2026, 8, 1),
        ...range(DateTime(2026, 8, 29), 3), // ayrı bir sonraki dönem
      ]);
      PeriodLog.applyPeriodEnd(keys, DateTime(2026, 8, 1), DateTime(2026, 8, 5));
      final log = PeriodLog.fromKeys(keys);
      expect(log.spans, hasLength(2));
      expect(log.contains(DateTime(2026, 8, 30)), isTrue);
    });

    test('çok uzun unutulmuş regl 15 günle sınırlanır', () {
      final keys = keysOf([DateTime(2026, 7, 1)]);
      final last = PeriodLog.applyPeriodEnd(
          keys, DateTime(2026, 7, 1), DateTime(2026, 9, 1));
      expect(last, DateTime(2026, 7, 15));
      expect(keys, hasLength(15));
    });
  });

  group('CycleModel yardımcıları (eski davranış korunur)', () {
    test('periodPhaseFor', () {
      expect(CycleModel.periodPhaseFor(1), DayPhase.periodPeak);
      expect(CycleModel.periodPhaseFor(2), DayPhase.periodPeak);
      expect(CycleModel.periodPhaseFor(3), DayPhase.periodMid);
      expect(CycleModel.periodPhaseFor(6), DayPhase.periodLight);
    });

    test('28 günlük döngüde ovulasyon 14. gün', () {
      expect(CycleModel.fertilePhaseFor(14, 28), DayPhase.ovulation);
      expect(CycleModel.fertilePhaseFor(13, 28), DayPhase.fertilePeak);
      expect(CycleModel.fertilePhaseFor(20, 28), DayPhase.none);
    });

    test('40 günlük düzensiz döngüde ovulasyon 26. gün', () {
      expect(CycleModel.fertilePhaseFor(26, 40), DayPhase.ovulation);
      expect(CycleModel.fertilePhaseFor(14, 40), DayPhase.none);
    });

    test('phaseOf eskisi gibi çalışır', () {
      final model = CycleModel(cycleStart: DateTime(2026, 9, 1));
      expect(model.phaseOf(DateTime(2026, 9, 1)), DayPhase.periodLight);
      expect(model.phaseOf(DateTime(2026, 9, 2)), DayPhase.periodPeak);
      expect(model.phaseOf(DateTime(2026, 9, 14)), DayPhase.ovulation);
    });
  });
}
