import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// 6 büyüme aşaması — Lottie kare haritasından (ip:38 op:216 → 178 kare)
const List<List<int>> _stageFrames = [
  [38, 56],
  [56, 91],
  [91, 127],
  [127, 158],
  [158, 189],
  [189, 216],
];

const List<String> _stageWeeks = [
  '1–4. hafta',
  '5–12. hafta',
  '13–20. hafta',
  '21–27. hafta',
  '28–34. hafta',
  '35–40. hafta',
];

const List<String> _stageTrimester = [
  '1. Trimester',
  '1. Trimester',
  '2. Trimester',
  '2. Trimester',
  '3. Trimester',
  '3. Trimester',
];

double _stageValue(int stage) {
  final s = _stageFrames[stage.clamp(0, _stageFrames.length - 1)];
  return ((s[1].toDouble() - 38) / 178).clamp(0.0, 1.0);
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
  int _stage = 0;

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
    final next = (_stage + 1).clamp(0, _stageFrames.length - 1);
    if (next == _stage) return;
    setState(() => _stage = next);
    _tree.animateTo(
      _stageValue(next),
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
                  _stageWeeks[_stage],
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
                  _stageTrimester[_stage],
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
                    _tree.value = _stageValue(0);
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
