// =============================================
// widgets/pregnancy/fruit_painter.dart
// Her gebelik haftası için doğru meyve/sebze emojisi.
// Önceki CustomPainter yaklaşımı emoji ile değiştirildi —
// hem daha doğru görünüm hem de platform-native kalite.
// =============================================

import 'package:flutter/material.dart';
import '../../data/pregnancy_data.dart';

/// Her gebelik haftası için doğru meyve/sebze emojisi.
/// 1–3. hafta: sembolik emoji (henüz meyve bilgisi yok).
const Map<int, String> _kWeekEmoji = {
  // ── 1–3. Hafta: sembolik (henüz boyut yok) ──────────────────────
  1:  '🌟',
  2:  '✨',
  3:  '💫',

  // ── 1. Trimester: Tohumlar ve Küçük Orman Meyveleri ─────────────
  4:  '🌱',  // Haşhaş / susam tanesi kadar küçük filiz
  5:  '🌾',  // Pirinç / susam tanesi boyutu
  6:  '🫛',  // Bezelye tanesi
  7:  '🫐',  // Yaban mersini
  8:  '🍒',  // Kiraz (ahududu boyutu)
  9:  '🫒',  // Yeşil zeytin
  10: '🍓',  // Çilek
  11: '🫚',  // Zencefil kökü (şekilsiz, büyüyen kök sebze)
  12: '🍋',  // Limon
  13: '🍏',  // Yeşil elma

  // ── 2. Trimester: Belirgin Meyveler ve Boy Uzaması ──────────────
  14: '🍑',  // Şeftali — tombullaşmaya başlıyor
  15: '🍎',  // Kırmızı elma — biraz daha hacimli
  16: '🥑',  // Avokado
  17: '🍐',  // Armut — aşağıya genişleyen şekil
  18: '🧅',  // Soğan — yuvarlak ve katmanlı
  19: '🥭',  // Mango — egzotik, daha büyük
  20: '🍌',  // Muz — boy uzuyor
  21: '🥕',  // Havuç — boy uzunluğu devam ediyor
  22: '🥔',  // Patates — hacimli ve tombul
  23: '🍅',  // Domates — büyük ve sulu
  24: '🌽',  // Mısır — boy iyice uzadı
  25: '🥦',  // Brokoli
  26: '🥬',  // Marul / yeşillik — katlanan hacim

  // ── 3. Trimester: İyice Ağırlaşan Büyük Meyve ve Sebzeler ───────
  27: '🫑',  // Dolmalık biber — geniş ve içi dolu
  28: '🍆',  // Patlıcan — uzun ve iri
  29: '🥥',  // Hindistan cevizi — sert ve büyük
  30: '🥒',  // Salatalık — uzunluk belirginleşiyor
  31: '🍍',  // Ananas — büyük ve heybetli
  32: '🍊',  // Mandalina / portakal — büyük narenciye
  33: '🍈',  // Kavun — iri ve yuvarlak
  34: '🍇',  // Üzüm salkımı — büyük hacim
  35: '🥔',  // Büyük patates
  36: '🥬',  // Büyük lahana demeti
  37: '🌽',  // Uzun mısır koçanı
  38: '🎃',  // Bal kabağı — büyük ve ağır
  39: '🍉',  // Karpuz dilimi
  40: '🍉',  // Karpuz — doğuma hazır, en büyük
};

/// Verilen gebelik haftasının meyve/sebze emojisini döndürür.
String fruitEmojiForWeek(int week) =>
    _kWeekEmoji[week.clamp(1, 40).toInt()] ?? '🌱';

/// Meyve boyutunu temsil eden emoji widget'ı.
/// [size]: widget boyutu (genişlik = yükseklik).
/// [week]: hafta numarası verilirse per-hafta doğru emoji kullanılır.
class FruitIcon extends StatelessWidget {
  final FruitShape shape; // geriye dönük uyumluluk için korundu
  final double size;
  final int? week; // hafta bazlı doğru emoji için

  const FruitIcon({
    super.key,
    required this.shape,
    this.size = 44,
    this.week,
  });

  @override
  Widget build(BuildContext context) {
    if (shape == FruitShape.none && week == null) {
      return SizedBox(width: size, height: size);
    }
    final emoji =
        week != null ? fruitEmojiForWeek(week!) : _shapeEmoji(shape);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: size * 0.74, height: 1),
        ),
      ),
    );
  }

  static String _shapeEmoji(FruitShape s) {
    switch (s) {
      case FruitShape.none:       return '';
      case FruitShape.tinySeed:   return '🌱';
      case FruitShape.smallRound: return '🫐';
      case FruitShape.raspberry:  return '🍓';
      case FruitShape.strawberry: return '🍓';
      case FruitShape.citrus:     return '🍋';
      case FruitShape.apple:      return '🍎';
      case FruitShape.avocado:    return '🥑';
      case FruitShape.pear:       return '🍐';
      case FruitShape.pepper:     return '🫑';
      case FruitShape.banana:     return '🍌';
      case FruitShape.carrot:     return '🥕';
      case FruitShape.leafy:      return '🥦';
      case FruitShape.longGreen:  return '🥒';
      case FruitShape.corn:       return '🌽';
      case FruitShape.eggplant:   return '🍆';
      case FruitShape.melon:      return '🍈';
      case FruitShape.watermelon: return '🍉';
    }
  }
}
