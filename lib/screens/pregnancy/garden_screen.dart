import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// 6 büyüme aşaması — Lottie kare haritasından (ip:38 op:216 → 178 kare)
const List<List<int>> _stages = [
  [38, 56],
  [56, 91],
  [91, 127],
  [127, 158],
  [158, 189],
  [189, 216],
];

double _stageValue(int stage) {
  final s = _stages[stage.clamp(0, _stages.length - 1)];
  final frame = s[1].toDouble();
  return ((frame - 38) / 178).clamp(0.0, 1.0);
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
    final next = (_stage + 1).clamp(0, _stages.length - 1);
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

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Büyüme Bahçem',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ağaca dokun, büyüsün.',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ağaç — ekranın yarısı kadar yükseklik, tıklanabilir
          GestureDetector(
            onTap: _grow,
            child: Container(
              width: double.infinity,
              height: screenH * 0.5,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2A1E)
                    : const Color(0xFFEDF5EC),
                borderRadius: const BorderRadius.all(Radius.circular(24)),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Icon(Icons.park_outlined,
                        size: 80, color: Color(0xFF558B2F)),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Aşama göstergesi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_stages.length, (i) {
                final active = i <= _stage;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: active
                          ? const Color(0xFF558B2F)
                          : const Color(0xFF558B2F).withValues(alpha: 0.2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
