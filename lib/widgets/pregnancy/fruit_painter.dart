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
  1:  '🌟',  // Hazırlık aşaması
  2:  '✨',   // Ovulasyon
  3:  '💫',  // Döllenme / implantasyon
  4:  '🌱',  // Haşhaş tohumu
  5:  '🌱',  // Elma çekirdeği
  6:  '🫛',  // Bezelye
  7:  '🫐',  // Yaban mersini
  8:  '🍓',  // Ahududu
  9:  '🫒',  // Yeşil zeytin
  10: '🍑',  // Erik kurusu
  11: '🍋',  // Misket limonu
  12: '🍑',  // Erik
  13: '🍑',  // Şeftali
  14: '🍋',  // Limon
  15: '🍊',  // Portakal
  16: '🥑',  // Avokado
  17: '🧅',  // Soğan
  18: '🍠',  // Tatlı patates
  19: '🥭',  // Mango
  20: '🍌',  // Muz
  21: '🍎',  // Nar
  22: '🥭',  // Papaya
  23: '🍊',  // Greyfurt
  24: '🍈',  // Kavun
  25: '🥦',  // Karnıbahar
  26: '🥬',  // Lahana
  27: '🥬',  // Şalgam
  28: '🍆',  // Patlıcan
  29: '🎃',  // Bal kabağı
  30: '🥒',  // Salatalık
  31: '🥥',  // Hindistan cevizi
  32: '🥒',  // Kabak
  33: '🍈',  // Durian
  34: '🎃',  // Tatlı kabak
  35: '🥥',  // Kokonat (hindistan cevizi)
  36: '🍈',  // Tatlı kavun
  37: '🍈',  // Kış kavunu
  38: '🎃',  // Kestane kabağı
  39: '🍉',  // Karpuz
  40: '🍉',  // Jack meyvesi
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
