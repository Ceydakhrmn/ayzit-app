// =============================================
// widgets/pregnancy/baby_development_card.dart
// Hamile takip modunda "BEBEĞİN GELİŞİMİ" kartı.
//
// Düzen: yatay Row —
//   SOL %42  : bebeğin gelişim çizimi (EmbryoIcon) — haftaya göre
//              aşama değiştiren, süzülen animasyon
//   SAĞ %58  : hafta navigasyonu, trimester etiketi, meyve boyutu
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cycle_provider.dart';
import '../../utils/phase_colors.dart';
import '../../data/pregnancy_data.dart';
import 'baby_stage_image.dart';
import 'fruit_painter.dart';

class BabyDevelopmentCard extends StatefulWidget {
  const BabyDevelopmentCard({super.key});

  @override
  State<BabyDevelopmentCard> createState() => _BabyDevelopmentCardState();
}

class _BabyDevelopmentCardState extends State<BabyDevelopmentCard> {
  int? _viewWeek;
  DateTime? _syncedDay;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lmp = provider.pregnancyStartDate;
    final currentWeek = provider.pregnancyWeek;

    // Takvimde güne tıklanınca kart o haftaya geçer.
    final selected = provider.selectedDay;
    if (selected != null &&
        (_syncedDay == null || !_isSameDay(selected, _syncedDay!))) {
      _syncedDay = selected;
      _viewWeek = pregnancyWeekForDate(selected, lmp) ?? currentWeek;
    }

    final week = (_viewWeek ?? currentWeek).clamp(1, 40).toInt();
    final info = pregnancyWeekInfo(week);
    final trimester = provider.trimesterForWeek(week);
    final progress = (week / 40.0).clamp(0.0, 1.0).toDouble();
    final browsing = _viewWeek != null && _viewWeek != currentWeek;

    final String weekLabel;
    if (week == currentWeek && lmp != null) {
      final dayInWeek = DateTime.now().difference(lmp).inDays % 7;
      weekLabel = '$week Hafta $dayInWeek Gün';
    } else {
      weekLabel = '$week. Hafta';
    }

    final cardBg =
        isDark ? const Color(0xFF2A2440) : const Color(0xFFF3EFFB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık satırı ─────────────────────────────────────────
          Row(
            children: [
              const _DotLabel(
                color: Color(0xFF9333EA),
                text: 'BEBEĞİN GELİŞİMİ',
              ),
              const Spacer(),
              Text(
                '$trimester. trimester',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Kahraman satır: SOL bebek animasyonu · SAĞ bilgi ──────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SOL %42 — bebek gelişim görseli
              Expanded(
                flex: 42,
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    // Resimlerin doğal sıcak arka plan rengiyle uyum
                    color: isDark
                        ? const Color(0xFF3A2828)
                        : const Color(0xFFF5DDD9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: AnimatedBabyStage(
                        key: ValueKey(week),
                        week: week,
                        size: 140,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // SAĞ %58 — hafta nav + trimester etiketi + boyut
              Expanded(
                flex: 58,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hafta navigasyon satırı
                    Row(
                      children: [
                        _NavButton(
                          icon: Icons.chevron_left,
                          enabled: week > 1,
                          onTap: () =>
                              setState(() => _viewWeek = week - 1),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () =>
                                _openWeekPicker(context, currentWeek),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4),
                              child: Text(
                                weekLabel,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _NavButton(
                          icon: Icons.chevron_right,
                          enabled: week < 40,
                          onTap: () =>
                              setState(() => _viewWeek = week + 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Trimester renk etiketi
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _trimColor(trimester, isDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$trimester. Trimester',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: (trimester == 3 && !isDark)
                                ? Colors.white
                                : (isDark
                                    ? const Color(0xFFFFC8D6)
                                    : const Color(0xFF8B1A3A)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Meyve / boyut kutusu
                    if (info.fruit != FruitShape.none &&
                        info.sizeText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              cs.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            FruitIcon(
                              shape: info.fruit,
                              week: week,
                              size: 36,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bebeğin ${info.sizeText}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                  color: cs.onSurface
                                      .withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Boy / kilo satırı
                    if (info.heightText.isNotEmpty ||
                        info.weightText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (info.heightText.isNotEmpty)
                            Expanded(
                              child: _StatChip(
                                icon: '📏',
                                label: info.heightText,
                                color: const Color(0xFF9333EA),
                                isDark: isDark,
                              ),
                            ),
                          if (info.heightText.isNotEmpty &&
                              info.weightText.isNotEmpty)
                            const SizedBox(width: 6),
                          if (info.weightText.isNotEmpty)
                            Expanded(
                              child: _StatChip(
                                icon: '⚖️',
                                label: info.weightText,
                                color: const Color(0xFF9333EA),
                                isDark: isDark,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Gelişim açıklaması ─────────────────────────────────────
          Text(
            info.summary,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
          if (info.motherInfo.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openDetailSheet(context, week, info),
              child: Row(
                children: [
                  const Text('💜', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    'Annedeki değişimler',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9333EA).withValues(
                          alpha: isDark ? 0.9 : 1.0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: const Color(0xFF9333EA).withValues(
                        alpha: isDark ? 0.9 : 1.0),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // ── 40 haftalık ilerleme çubuğu ───────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  cs.onSurface.withValues(alpha: 0.08),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF9333EA)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '40 haftalık yolculuğun %${(progress * 100).round()}\'i',
                style: TextStyle(
                  fontSize: 10.5,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              if (browsing)
                GestureDetector(
                  onTap: () => setState(() => _viewWeek = null),
                  child: const Row(
                    children: [
                      Icon(Icons.today,
                          size: 13, color: Color(0xFF9333EA)),
                      SizedBox(width: 3),
                      Text(
                        'Bugüne dön',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9333EA),
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

  void _openDetailSheet(
      BuildContext context, int week, PregnancyWeekInfo info) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$week. Hafta',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                // ── Bebek gelişimi ─────────────────────────
                _DetailSection(
                  emoji: '👶',
                  title: 'Bebek Gelişimi',
                  text: info.summary,
                  color: const Color(0xFF9333EA),
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                // ── Annedeki değişimler ────────────────────
                _DetailSection(
                  emoji: '💜',
                  title: 'Annedeki Değişimler',
                  text: info.motherInfo,
                  color: const Color(0xFFEC4899),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openWeekPicker(BuildContext context, int currentWeek) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hafta seç',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 40,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, i) {
                  final w = i + 1;
                  final isCurrent = w == currentWeek;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _viewWeek = w);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? const Color(0xFF9333EA)
                            : cs.surfaceContainerHighest,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$w',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? Colors.white
                              : cs.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Trimester rengi ─────────────────────────────────────────────────
Color _trimColor(int trimester, bool isDark) {
  if (isDark) {
    if (trimester == 1) return kTrimester1Dark;
    if (trimester == 2) return kTrimester2Dark;
    return kTrimester3Dark;
  }
  if (trimester == 1) return kTrimester1;
  if (trimester == 2) return kTrimester2;
  return kTrimester3;
}

// ── Navigasyon butonu ────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: enabled ? onTap : null,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(icon),
      iconSize: 24,
      color: const Color(0xFF9333EA),
      disabledColor: cs.onSurface.withValues(alpha: 0.2),
    );
  }
}

// ── Boy / kilo chip ──────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final bool isDark;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nokta + başlık ───────────────────────────────────────────────────
class _DotLabel extends StatelessWidget {
  final Color color;
  final String text;
  const _DotLabel({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Detay sayfası bölüm kartı ────────────────────────────────────────
class _DetailSection extends StatelessWidget {
  final String emoji;
  final String title;
  final String text;
  final Color color;
  final bool isDark;

  const _DetailSection({
    required this.emoji,
    required this.title,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: cs.onSurface.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}
