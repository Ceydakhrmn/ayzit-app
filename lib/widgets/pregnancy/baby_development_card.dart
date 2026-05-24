// =============================================
// widgets/pregnancy/baby_development_card.dart
// Hamile takip modunda "BEBEĞİN GELİŞİMİ" kartı.
//
// Düzen: yatay Row —
//   SOL %40  : bebeğin biyolojik gelişim çizimi (döllenme → hücre
//              bölünmesi → embriyo → fetüs → bebek), haftaya göre evre
//              değiştiren, yumuşakça hareket eden animasyon.
//   SAĞ %60  : seçilen haftanın "X Hafta Y Gün" bilgisi + meyve boyutu.
//
// Takvimde bir güne tıklamak, ‹ › okları ve hafta seçici kartı o
// haftaya taşır.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/pregnancy_data.dart';
import '../../providers/cycle_provider.dart';
import 'embryo_painter.dart';
import 'fruit_painter.dart';

class BabyDevelopmentCard extends StatefulWidget {
  const BabyDevelopmentCard({super.key});

  @override
  State<BabyDevelopmentCard> createState() => _BabyDevelopmentCardState();
}

class _BabyDevelopmentCardState extends State<BabyDevelopmentCard> {
  // Kullanıcının gözden geçirdiği hafta. null ise bugünkü hafta gösterilir.
  int? _viewWeek;
  // Takvim seçimini izlemek için en son senkronlanan gün.
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

    // Takvimde bir güne tıklanınca kart o günün haftasına geçer.
    final selected = provider.selectedDay;
    if (selected != null &&
        (_syncedDay == null || !_isSameDay(selected, _syncedDay!))) {
      _syncedDay = selected;
      _viewWeek = pregnancyWeekForDate(selected, lmp) ?? currentWeek;
    }

    final week = (_viewWeek ?? currentWeek).clamp(1, 40).toInt();
    final info = pregnancyWeekInfo(week);
    final stage = embryoStageForWeek(week);
    final trimester = provider.trimesterForWeek(week);
    final progress = (week / 40.0).clamp(0.0, 1.0).toDouble();
    final browsing = _viewWeek != null && _viewWeek != currentWeek;

    // Hafta + gün başlığı ("13 Hafta 3 Gün"). Gün yalnızca bugünkü haftada.
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
          // Başlık satırı
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
          const SizedBox(height: 8),

          // ── Kahraman satır: SOL biyolojik gelişim · SAĞ metin ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SOL %40 — biyolojik gelişim çizimi
              Expanded(
                flex: 40,
                child: SizedBox(
                  height: 140,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: FittedBox(
                      key: ValueKey(stage),
                      fit: BoxFit.contain,
                      child: EmbryoIcon(stage: stage, size: 130),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // SAĞ %60 — hafta/gün + meyve boyutu
              Expanded(
                flex: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hafta gezinme satırı
                    Row(
                      children: [
                        _NavButton(
                          icon: Icons.chevron_left,
                          enabled: week > 1,
                          onTap: () => setState(() => _viewWeek = week - 1),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () =>
                                _openWeekPicker(context, currentWeek),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                weekLabel,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
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
                          onTap: () => setState(() => _viewWeek = week + 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Meyve / boyut satırı
                    if (info.fruit != FruitShape.none &&
                        info.sizeText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            FruitIcon(shape: info.fruit, size: 46),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bebeğiniz ${info.sizeText.toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                  color:
                                      cs.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          // Gelişim açıklaması
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
          const SizedBox(height: 12),

          // 40 haftalık ilerleme
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.onSurface.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF9333EA)),
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
                      Icon(Icons.today, size: 13, color: Color(0xFF9333EA)),
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
              const Text(
                'Hafta seç',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
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
                          color: isCurrent ? Colors.white : cs.onSurface,
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


class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

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
