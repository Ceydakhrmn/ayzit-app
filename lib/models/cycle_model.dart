// =============================================
// models/cycle_model.dart
// Döngü verisi için model sınıfı
// =============================================

enum DayPhase {
  none,         // Normal gün (renksiz)
  periodLight,  // Regl hafif — açık mor
  periodMid,    // Regl orta — orta mor
  periodPeak,   // Regl yoğun — koyu mor
  fertilelow,   // Düşük doğurganlık — sarı
  fertileMid,   // Orta doğurganlık — turuncu
  fertilePeak,  // En yüksek doğurganlık — kırmızı
  ovulation,    // Ovulasyon — mavi
}

class DayData {
  final DateTime date;
  final DayPhase phase;

  const DayData({
    required this.date,
    required this.phase,
  });
}

class CycleModel {
  /// Döngü başlangıç tarihi
  final DateTime cycleStart;

  /// Ortalama döngü uzunluğu (gün)
  final int cycleLength;

  /// Ortalama regl süresi (gün)
  final int periodLength;

  const CycleModel({
    required this.cycleStart,
    this.cycleLength = 28,
    this.periodLength = 5,
  });

  /// Verilen tarihin döngü içindeki kaçıncı gün olduğunu döner (1'den başlar)
  int dayOfCycle(DateTime date) {
    final diff = date.difference(cycleStart).inDays;
    final mod = diff % cycleLength;
    return (mod < 0 ? mod + cycleLength : mod) + 1;
  }

  /// Verilen tarihin fazını hesaplar
  DayPhase phaseOf(DateTime date) {
    final day = dayOfCycle(date);

    // Regl günleri: 1 → periodLength
    if (day == 1) return DayPhase.periodLight;
    if (day == 2) return DayPhase.periodPeak;
    if (day == 3) return DayPhase.periodMid;
    if (day <= periodLength) return DayPhase.periodLight;

    // Ovulasyon günü: döngü bitişinden 14 gün önce (standart luteal faz)
    final ovulationDay = cycleLength - 14;
    if (day == ovulationDay) return DayPhase.ovulation;

    // Doğurganlık penceresi: ovulasyondan 5 gün önce → 1 gün sonra
    if (day == ovulationDay - 5) return DayPhase.fertilelow;
    if (day == ovulationDay - 4) return DayPhase.fertilelow;
    if (day == ovulationDay - 3) return DayPhase.fertileMid;
    if (day == ovulationDay - 2) return DayPhase.fertileMid;
    if (day == ovulationDay - 1) return DayPhase.fertilePeak;
    if (day == ovulationDay + 1) return DayPhase.fertileMid;

    return DayPhase.none;
  }
}
