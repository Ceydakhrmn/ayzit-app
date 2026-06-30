// =============================================
// widgets/pregnancy/growth_garden_card.dart
// "BÜYÜME BAHÇEM" — gebelik haftasıyla birlikte büyüyen ağaç kartı.
//
// Ağaç Lottie'si (tree_transparent.json) Senaryo 1 ile yönetilir:
// kullanıcının gebelik haftasına karşılık gelen karede durur, hafta
// ilerledikçe yumuşakça yeni kareye büyür. Loop yok.
//
// Lottie kare haritası (ip:38 op:216 → 178 kare):
//   1-4. hf → 38-56  | 5-12 → 56-91  | 13-20 → 91-127
//   21-27  → 127-158 | 28-34 → 158-189 | 35-40 → 189-216
// =============================================

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/cycle_provider.dart';

const Color _gardenGreen = Color(0xFF558B2F);

// [haftaBaşı, haftaSonu, kareBaşı, kareSonu]
const List<List<int>> _frameStages = [
  [1, 4, 38, 56],
  [5, 12, 56, 91],
  [13, 20, 91, 127],
  [21, 27, 127, 158],
  [28, 34, 158, 189],
  [35, 40, 189, 216],
];

class GrowthGardenCard extends StatefulWidget {
  const GrowthGardenCard({super.key});

  @override
  State<GrowthGardenCard> createState() => _GrowthGardenCardState();
}

class _GrowthGardenCardState extends State<GrowthGardenCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tree;
  bool _ready = false;
  int? _animatedWeek;

  @override
  void initState() {
    super.initState();
    _tree = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _tree.dispose();
    super.dispose();
  }

  /// Verilen hafta için Lottie kontrolcü değeri (0..1).
  double _valueForWeek(int week) {
    final w = week.clamp(1, 40);
    for (final s in _frameStages) {
      if (w >= s[0] && w <= s[1]) {
        final frac = s[1] == s[0] ? 0.0 : (w - s[0]) / (s[1] - s[0]);
        final frame = s[2] + frac * (s[3] - s[2]);
        return ((frame - 38) / 178).clamp(0.0, 1.0);
      }
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final week = context.select<CycleProvider, int>((p) => p.pregnancyWeek);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = !AppLocalizations.of(context)!.isTurkish;

    // Hafta ilerlediyse ağacı yumuşakça yeni kareye büyüt.
    if (_ready && week != _animatedWeek) {
      final from = _animatedWeek ?? week;
      _animatedWeek = week;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final diff = (week - from).abs();
        _tree.animateTo(
          _valueForWeek(week),
          duration: Duration(milliseconds: (diff * 650).clamp(450, 1600)),
          curve: Curves.easeInOut,
        );
      });
    }

    final cardBg =
        isDark ? const Color(0xFF26302A) : const Color(0xFFEDF5EC);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, size: 15, color: _gardenGreen),
              const SizedBox(width: 6),
              Text(
                isEn ? 'GROWTH GARDEN' : 'BÜYÜME BAHÇEM',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _gardenGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ağaç animasyonu
              Expanded(
                flex: 42,
                child: RepaintBoundary(
                  child: SizedBox(
                    height: 130,
                    child: Lottie.asset(
                      'assets/animations/tree_transparent.json',
                      controller: _tree,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        _tree.duration = composition.duration;
                        _animatedWeek = week;
                        _tree.value = _valueForWeek(week);
                        _ready = true;
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.park_outlined,
                            size: 44, color: _gardenGreen),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Açıklama
              Expanded(
                flex: 58,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Week $week' : '$week. haftadasın',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn
                          ? 'As you grow, so does your garden — your tree blooms a little more each week.'
                          : 'Sen büyüdükçe bahçen de büyüyor — ağacın her hafta biraz daha serpiliyor.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
