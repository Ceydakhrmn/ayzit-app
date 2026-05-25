// =============================================
// screens/pregnancy/garden_screen.dart
// Büyüme Bahçem — hamile takip moduna özel sayfa.
//
// • Ağaç gerçek gebelik haftasından başlar (provider.gardenWeek).
// • Haftada 1 kez dokunulabilir (7 günlük kilit).
// • Kilitliyse "X gün kaldı" dialogu gösterilir.
// • 42. hafta aşılınca "Doğum gerçekleşti mi?" uyarısı çıkar.
// =============================================

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../providers/cycle_provider.dart';

// Lottie kare haritası: [haftaStart, haftaEnd, frameStart, frameEnd]
const List<List<int>> _weekStages = [
  [1,  4,  38,  56],
  [5,  12, 56,  91],
  [13, 20, 91,  127],
  [21, 27, 127, 158],
  [28, 34, 158, 189],
  [35, 40, 189, 216],
];

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

String _trimesterLabel(int week) {
  if (week <= 12) return '1. Trimester';
  if (week <= 26) return '2. Trimester';
  return '3. Trimester';
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
  int? _displayedWeek; // null = henüz senkronlanmadı

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

  /// Provider'dan gelen haftayı animasyona yansıt (ilk açılış veya değişim).
  void _syncWeek(int week) {
    if (_displayedWeek == week) return;
    _displayedWeek = week;
    if (!_ready) return;
    _tree.animateTo(
      _valueForWeek(week),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onTap(BuildContext context, CycleProvider provider) async {
    // 42+ hafta — doğum uyarısı
    if (provider.isPostTerm) {
      _showPostTermDialog(context);
      return;
    }

    // Kilitli — kaç gün kaldığını göster
    if (!provider.canTapGarden) {
      _showLockedDialog(context, provider.gardenCooldownDays);
      return;
    }

    // Serbest — haftayı ilerlet
    await provider.advanceGardenWeek();
  }

  void _showLockedDialog(BuildContext context, int daysLeft) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: Color(0xFF7C3AED)),
            SizedBox(width: 8),
            Text('Bu haftayı tamamladın!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Bahçen bu hafta büyüdü 🌱\n\nYeni hafta için $daysLeft gün kaldı.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tamam'),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostTermDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Doğum gerçekleşti mi?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
          '42. haftayı geçtin. Bebeğini kucağına aldıysan tebrikler! 🎉\n\n'
          'Ayarlar\'dan modu güncelleyebilirsin.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tamam'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final week = provider.gardenWeek;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenH = MediaQuery.of(context).size.height;

    // Provider değişince animasyonu güncelle.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWeek(week));

    const green = Color(0xFF558B2F);
    final bgColor =
        isDark ? const Color(0xFF2D2040) : const Color(0xFFF3EFFB);
    final locked = !provider.canTapGarden;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık ────────────────────────────────────────────────────
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

          // ── Hafta + trimester (yeşil) ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.eco, size: 14, color: green),
                const SizedBox(width: 6),
                Text(
                  '$week. hafta',
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
                    color: green.withValues(alpha: 0.35)),
                const SizedBox(width: 10),
                Text(
                  _trimesterLabel(week),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: green.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(),
                // Kilit durumu
                if (locked)
                  Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 13, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.gardenCooldownDays}g kaldı',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Ağaç — ekranın yarısı, dokunulabilir ──────────────────
          GestureDetector(
            onTap: () => _onTap(context, provider),
            child: Stack(
              children: [
                Container(
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
                        _tree.value = _valueForWeek(week);
                        _displayedWeek = week;
                        setState(() => _ready = true);
                      },
                      errorBuilder: (ctx, err, st) => const Center(
                        child: Icon(Icons.park_outlined,
                            size: 80, color: green),
                      ),
                    ),
                  ),
                ),
                // Kilit ikonu overlay
                if (locked)
                  Positioned(
                    right: 28,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline,
                          size: 16, color: Color(0xFF7C3AED)),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Dokunma ipucu ──────────────────────────────────────────
          Center(
            child: Text(
              locked
                  ? '${provider.gardenCooldownDays} gün sonra tekrar büyütebilirsin'
                  : 'Ağaca dokun, büyüsün 🌱',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.45),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
