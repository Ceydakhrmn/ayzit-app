// =============================================
// models/period_log.dart
// Kullanıcının işaretlediği regl günlerinden dönemleri ve gerçek döngü
// uzunluklarını çıkaran saf (Firebase'siz) mantık. Düzensiz döngüleri
// desteklemek için geçmiş dönemler gerçek kayıtlarla gösterilir; son kayıttan
// sonrası ayarlardaki sürelerle tahmin edilir.
// =============================================

import 'dart:math' as math;

import 'cycle_model.dart';

/// Bir takvim gününün rengini (fazını) hesaplar.
///
/// 1. [log]'da işaretli gün → regl rengi (dönemin kaçıncı günü olduğuna göre)
/// 2. Devam eden reglin ([activePeriodStart]) henüz gelmemiş günleri →
///    tahmini [periodLength] boyunca regl rengi
/// 3. Diğer günler → bu günden önceki son döneme göre ovulasyon/doğurganlık.
///    İki kayıtlı dönem arasındaysa gerçek döngü uzunluğu, son dönemden
///    sonrasıysa ayarlardaki [cycleLength] ile ileriye doğru tahmin.
/// 4. Son dönemden sonraki döngülerin ilk [periodLength] günü →
///    [DayPhase.periodPredicted] (soluk). [today]'den önceki tahmini günler
///    boyanmaz: işaretlenmediyse o günlerde regl olunmamıştır.
///
/// Hiç kayıt yoksa tüm günler boş kalır; uygulama kimseye varsayılan bir
/// regl tarihi atamaz.
DayPhase phaseForDay({
  required DateTime date,
  required PeriodLog log,
  required int cycleLength,
  required int periodLength,
  DateTime? activePeriodStart,
  DateTime? today,
}) {
  final d = PeriodLog.dateOnly(date);

  if (log.contains(d)) {
    final span = log.spanCovering(d)!;
    return CycleModel.periodPhaseFor(PeriodLog.daysBetween(span.start, d) + 1);
  }

  if (activePeriodStart != null) {
    final dayOfPeriod = PeriodLog.daysBetween(activePeriodStart, d) + 1;
    if (dayOfPeriod >= 1 && dayOfPeriod <= periodLength) {
      return CycleModel.periodPhaseFor(dayOfPeriod);
    }
  }

  final anchor = log.lastSpanStartingOnOrBefore(d);
  if (anchor == null) return DayPhase.none; // ilk kayıttan önce
  final next = log.firstSpanStartingAfter(anchor.start);
  final sinceAnchor = PeriodLog.daysBetween(anchor.start, d);
  final int cycleLen;
  final int dayInCycle;
  if (next != null) {
    cycleLen = PeriodLog.daysBetween(anchor.start, next.start);
    dayInCycle = sinceAnchor + 1;
  } else {
    cycleLen = cycleLength;
    dayInCycle = sinceAnchor % cycleLen + 1;
  }
  if (dayInCycle <= periodLength) {
    final isPredicted = next == null &&
        sinceAnchor >= cycleLen &&
        (today == null || !d.isBefore(PeriodLog.dateOnly(today)));
    return isPredicted ? DayPhase.periodPredicted : DayPhase.none;
  }
  return CycleModel.fertilePhaseFor(dayInCycle, cycleLen);
}

/// Son kayıtlı regle ve ayarlardaki sürelere göre yaklaşan tarihler.
class CycleForecast {
  /// Takvimde soluk gösterilen sıradaki tahmini reglin ilk günü. Regl
  /// gecikmişse (tahmini günler sürerken) bugünden önce olabilir.
  final DateTime nextPeriod;

  /// Bugünü kapsayan ya da sıradaki doğurganlık penceresi ve ovulasyon günü.
  /// Döngü, regl süresine göre çok kısaysa (pencere regle denk gelir) null.
  final DateTime? ovulation;
  final DateTime? fertileStart;
  final DateTime? fertileEnd;

  const CycleForecast({
    required this.nextPeriod,
    this.ovulation,
    this.fertileStart,
    this.fertileEnd,
  });
}

/// [phaseForDay] ile aynı kurallarla, son kayıtlı dönemden [cycleLength]
/// günlük döngüler varsayarak yaklaşan regl / ovulasyon / doğurganlık
/// tarihlerini hesaplar. Hiç kayıt yoksa null.
CycleForecast? forecastCycle({
  required PeriodLog log,
  required int cycleLength,
  required int periodLength,
  required DateTime today,
}) {
  if (log.isEmpty || cycleLength < 1) return null;
  final anchor = log.spans.last.start;
  final t = PeriodLog.dateOnly(today);
  DateTime at(int offset) =>
      DateTime(anchor.year, anchor.month, anchor.day + offset);

  // Sonraki regl: son günü bugünden önce olmayan ilk tahmini dönem (kayıtlı
  // dönemin kendisi sayılmaz); takvimdeki soluk günlerle aynı.
  var k = 1;
  while (at(k * cycleLength + math.max<int>(periodLength, 1) - 1).isBefore(t)) {
    k++;
  }
  final nextPeriod = at(k * cycleLength);

  // Döngünün kaçıncı günleri (1'den başlar); takvimde regl günlerinin
  // üstüne boyanmayan kısımlar pencereye katılmaz.
  final ovDay = cycleLength - 14;
  if (ovDay <= periodLength) {
    return CycleForecast(nextPeriod: nextPeriod);
  }
  final firstDay = math.max(ovDay - 5, periodLength + 1);
  final lastDay = ovDay + 1;

  // Bitiş günü bugünden önce olmayan ve ovulasyon günü regl olarak
  // işaretlenmemiş ilk pencere. İşaretli regl günleri takvimde regl rengi
  // aldığından pencerenin başından kırpılır.
  for (var c = 0;; c++) {
    final base = c * cycleLength;
    final end = at(base + lastDay - 1);
    final ovulation = at(base + ovDay - 1);
    if (end.isBefore(t) || log.contains(ovulation)) continue;
    var start = at(base + firstDay - 1);
    while (log.contains(start)) {
      start = DateTime(start.year, start.month, start.day + 1);
    }
    return CycleForecast(
      nextPeriod: nextPeriod,
      ovulation: ovulation,
      fertileStart: start,
      fertileEnd: end,
    );
  }
}

/// Art arda işaretlenmiş regl günlerinden oluşan tek bir dönem.
class PeriodSpan {
  final DateTime start;
  final DateTime end;

  const PeriodSpan(this.start, this.end);

  int get length => end.difference(start).inDays + 1;

  bool covers(DateTime day) => !day.isBefore(start) && !day.isAfter(end);
}

class PeriodLog {
  /// Aynı döneme sayılacak iki kayıtlı gün arasındaki en büyük fark.
  /// 2 → arada tek bir işaretlenmemiş gün olsa da dönem bölünmez.
  static const int maxGapWithinPeriod = 2;

  /// Tahmin ortalamasına katılan döngü uzunluğu aralığı. Bunun dışındaki
  /// değerler (ör. bir ayı işaretlemeyi unutmak) tahmini bozmasın diye
  /// ortalamaya alınmaz; istatistiklerde yine gösterilir.
  static const int minPlausibleCycle = 15;
  static const int maxPlausibleCycle = 60;

  /// Sıralı, tekrarsız, saatsiz regl günleri.
  final List<DateTime> days;
  final Set<String> _keys;

  late final List<PeriodSpan> spans = _groupIntoSpans(days);

  PeriodLog(Iterable<DateTime> input)
      : days = (input.map(dateOnly).toSet().toList()..sort()),
        _keys = input.map(keyOf).toSet();

  factory PeriodLog.fromKeys(Iterable<String> keys) =>
      PeriodLog(keys.map(parseKey).whereType<DateTime>());

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String keyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? parseKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// Takvim gününden gün sayısı farkı (yaz saati değişimlerinden etkilenmez).
  static int daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays;

  bool get isEmpty => days.isEmpty;

  List<String> get sortedKeys => days.map(keyOf).toList();

  bool contains(DateTime day) => _keys.contains(keyOf(day));

  PeriodSpan? spanCovering(DateTime day) {
    final d = dateOnly(day);
    for (final s in spans) {
      if (s.covers(d)) return s;
    }
    return null;
  }

  PeriodSpan? lastSpanStartingOnOrBefore(DateTime day) {
    final d = dateOnly(day);
    PeriodSpan? result;
    for (final s in spans) {
      if (s.start.isAfter(d)) break;
      result = s;
    }
    return result;
  }

  PeriodSpan? firstSpanStartingAfter(DateTime day) {
    final d = dateOnly(day);
    for (final s in spans) {
      if (s.start.isAfter(d)) return s;
    }
    return null;
  }

  /// Tamamlanmış döngülerin gerçek uzunlukları (ardışık dönem başlangıçları
  /// arasındaki gün sayısı), eskiden yeniye.
  List<int> cycleLengths() => [
        for (var i = 0; i + 1 < spans.length; i++)
          daysBetween(spans[i].start, spans[i + 1].start),
      ];

  /// Son [lastN] makul döngünün ortalaması; yeterli veri yoksa null.
  int? averageCycleLength({int lastN = 6}) {
    final plausible = cycleLengths()
        .where((c) => c >= minPlausibleCycle && c <= maxPlausibleCycle)
        .toList();
    return _roundedAverage(_takeLast(plausible, lastN));
  }

  /// Son [lastN] dönemin ortalama uzunluğu. [excludeOngoingFrom] verilirse o
  /// tarihte başlayan (henüz bitmemiş) dönem hesaba katılmaz.
  int? averagePeriodLength({int lastN = 6, DateTime? excludeOngoingFrom}) {
    final lengths = [
      for (final s in spans)
        if (excludeOngoingFrom == null ||
            daysBetween(s.start, excludeOngoingFrom) != 0)
          s.length,
    ];
    return _roundedAverage(_takeLast(lengths, lastN));
  }

  /// Bir regl döneminin en fazla kaç gün olarak işaretlenebileceği.
  static const int maxPeriodDays = 15;

  /// [start]'ta başlayan reglin [end]'de bittiğini [keys]'e işler: aradaki
  /// günleri ekler, bitişten hemen sonra gelen (aynı döneme bitişik) günleri
  /// kaldırır. Dönem [maxPeriodDays] günle sınırlıdır. Gerçek bitiş gününü
  /// döndürür.
  static DateTime applyPeriodEnd(
      Set<String> keys, DateTime start, DateTime end) {
    final s = dateOnly(start);
    final days = (daysBetween(s, end) + 1).clamp(1, maxPeriodDays);
    for (var i = 0; i < days; i++) {
      keys.add(keyOf(DateTime(s.year, s.month, s.day + i)));
    }
    final last = DateTime(s.year, s.month, s.day + days - 1);
    var next = DateTime(last.year, last.month, last.day + 1);
    while (keys.remove(keyOf(next))) {
      next = DateTime(next.year, next.month, next.day + 1);
    }
    return last;
  }

  static List<int> _takeLast(List<int> list, int n) =>
      list.length <= n ? list : list.sublist(list.length - n);

  static int? _roundedAverage(List<int> list) {
    if (list.isEmpty) return null;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }

  static List<PeriodSpan> _groupIntoSpans(List<DateTime> sortedDays) {
    final result = <PeriodSpan>[];
    if (sortedDays.isEmpty) return result;
    var start = sortedDays.first;
    var end = start;
    for (final day in sortedDays.skip(1)) {
      if (daysBetween(end, day) <= maxGapWithinPeriod) {
        end = day;
      } else {
        result.add(PeriodSpan(start, end));
        start = day;
        end = day;
      }
    }
    result.add(PeriodSpan(start, end));
    return result;
  }
}
