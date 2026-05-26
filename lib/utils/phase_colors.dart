// =============================================
// utils/phase_colors.dart
// Her faza karşılık gelen renk ve metin bilgileri
// Renk değiştirmek istersen buradan yap
// =============================================

import 'package:flutter/material.dart';
import '../models/cycle_model.dart';

class PhaseStyle {
  final Color background;
  final Color textColor;
  final String label;

  const PhaseStyle({
    required this.background,
    required this.textColor,
    required this.label,
  });
}

// ---- Renk sabitleri ----
// Mor tonları — Regl günleri
const Color kPeriodLight = Color(0xFFC084FC); // açık mor
const Color kPeriodMid   = Color(0xFFA855F7); // orta mor
const Color kPeriodPeak  = Color(0xFF7C3AED); // koyu mor/lacivert

// Isı skalası — Doğurganlık
const Color kFertileLow  = Color(0xFFFDE047); // sarı
const Color kFertileMid  = Color(0xFFF97316); // turuncu
const Color kFertilePeak = Color(0xFFDC2626); // kırmızı

// Ovulasyon
const Color kOvulation   = Color(0xFF3B82F6); // mavi

// Karanlık metin renkleri
const Color kDarkText    = Color(0xFF1a1a1a);

// ── Trimester renkleri — Hamile takip modu ──────────────────────────────
// Mor/sarı/mavi kullanılmayan yeni palet: gül / şeftali / kırmızı gül
// 1. Trimester (1–12. Hafta): çok açık gül kurusu
const Color kTrimester1     = Color(0xFFFFE4E8);
const Color kTrimester1Dark = Color(0xFF5C1F2E);

// 2. Trimester (13–26. Hafta): orta şeftali-gül
const Color kTrimester2     = Color(0xFFFBB6C8);
const Color kTrimester2Dark = Color(0xFF7A1A35);

// 3. Trimester (27–40. Hafta): derin gül kırmızısı
const Color kTrimester3     = Color(0xFFEF607F);
const Color kTrimester3Dark = Color(0xFF9B1030);

/// Verilen hamilelik haftasına ve tema moduna göre trimester stilini döndürür.
/// LMP öncesi veya geçersiz hafta için null döner.
PhaseStyle? trimesterStyle(int? week, {required bool isDark}) {
  if (week == null) return null;
  if (week <= 12) {
    return PhaseStyle(
      background: isDark ? kTrimester1Dark : kTrimester1,
      textColor: isDark ? const Color(0xFFFFC8D6) : const Color(0xFF8B1A3A),
      label: '1. Trimester',
    );
  }
  if (week <= 26) {
    return PhaseStyle(
      background: isDark ? kTrimester2Dark : kTrimester2,
      textColor: isDark ? const Color(0xFFFFC8D6) : const Color(0xFF8B1A3A),
      label: '2. Trimester',
    );
  }
  return PhaseStyle(
    background: isDark ? kTrimester3Dark : kTrimester3,
    textColor: isDark ? const Color(0xFFFFD6E2) : Colors.white,
    label: '3. Trimester',
  );
}

PhaseStyle phaseStyle(DayPhase phase) {
  switch (phase) {
    case DayPhase.periodLight:
      return const PhaseStyle(
        background: kPeriodLight,
        textColor: Color(0xFF3b0764),
        label: 'Regl — hafif',
      );
    case DayPhase.periodMid:
      return const PhaseStyle(
        background: kPeriodMid,
        textColor: Colors.white,
        label: 'Regl — orta yoğunluk',
      );
    case DayPhase.periodPeak:
      return const PhaseStyle(
        background: kPeriodPeak,
        textColor: Colors.white,
        label: 'Regl — yoğun',
      );
    case DayPhase.fertilelow:
      return const PhaseStyle(
        background: kFertileLow,
        textColor: Color(0xFF713f12),
        label: 'Doğurganlık — düşük',
      );
    case DayPhase.fertileMid:
      return const PhaseStyle(
        background: kFertileMid,
        textColor: Colors.white,
        label: 'Doğurganlık — orta',
      );
    case DayPhase.fertilePeak:
      return const PhaseStyle(
        background: kFertilePeak,
        textColor: Colors.white,
        label: 'Doğurganlık — en yüksek',
      );
    case DayPhase.ovulation:
      return const PhaseStyle(
        background: kOvulation,
        textColor: Colors.white,
        label: 'Ovulasyon günü',
      );
    case DayPhase.none:
      return const PhaseStyle(
        background: Color(0xFFF1F1F1),
        textColor: Color(0xFF555555),
        label: 'Normal gün',
      );
  }
}
