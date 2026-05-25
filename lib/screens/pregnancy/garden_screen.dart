import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Hafta → Lottie kare aralığı  [haftaStart, haftaEnd, frameStart, frameEnd]
const List<List<int>> _weekStages = [
  [1,  4,  38,  56],
  [5,  12, 56,  91],
  [13, 20, 91,  127],
  [21, 27, 127, 158],
  [28, 34, 158, 189],
  [35, 40, 189, 216],
];

String _trimester(int week) {
  if (week <= 12) return '1. Trimester';
  if (week <= 27) return '2. Trimester';
  return '3. Trimester';
}

double _valueForWeek(int week) {
  final w = week.clamp(1, 40);
  for (final s in _weekStages) {
    if (w >= s[0] && w <= s[1]) {
      final frac = s[1] == s[0] ? 0.0 : (w - s[0]) / (s[1] - s[0]);
      final frame = s[2] + frac * (s[3] - s[2]);
      return ((frame - 38) / 178).clamp(0.0, 1.0);
    }
  }
  return 1.0;
}

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tree;
  bool _ready = false;
  int _week = 1;

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

  void _grow() {
    if (!_ready) return;
    final next = (_week + 1).clamp(1, 40);
    if (next == _week) return;
    setState(() => _week = next);
    _tree.animateTo(
      _valueForWeek(next),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenH = MediaQuery.of(context).size.height;

    const green = Color(0xFF558B2F);
    final bgColor = isDark ? const Color(0xFF2D2040) : const Color(0xFFF3EFFB);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Text(
              'Büyüme Bahçem',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Hafta + trimester bilgisi (yeşil, üstte)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.eco, size: 14, color: green),
                const SizedBox(width: 6),
                Text(
                  '$_week. hafta',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: green,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 12,
                  color: green.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 10),
                Text(
                  _trimester(_week),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: green.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ağaç — ekranın yarısı kadar, tıklanabilir
          GestureDetector(
            onTap: _grow,
            child: Container(
              width: double.infinity,
              height: screenH * 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: RepaintBoundary(
                child: Lottie.asset(
                  'assets/animations/tree_transparent.json',
                  controller: _tree,
                  fit: BoxFit.contain,
                  onLoaded: (comp) {
                    _tree.duration = comp.duration;
                    _tree.value = _valueForWeek(1);
                    setState(() => _ready = true);
                  },
                  errorBuilder: (ctx, err, st) => const Center(
                    child: Icon(Icons.park_outlined, size: 80, color: green),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
