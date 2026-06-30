// =============================================
// widgets/pregnancy/pregnancy_week_events_card.dart
//
// Hamile takip modunda takvimin altında gösterilen
// hafta gelişim olayları + kilometre taşları kartı.
// Takvim ızgarasından taşınan bantların temiz liste hali.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/pregnancy_data.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cycle_provider.dart';

class PregnancyWeekEventsCard extends StatelessWidget {
  const PregnancyWeekEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final lmp = provider.pregnancyStartDate;
    if (lmp == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isEn = !l10n.isTurkish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Seçili gün yoksa bugünü kullan ───────────────────────────────────
    final refDate = provider.selectedDay ?? DateTime.now();
    final currentWeek = pregnancyWeekForDate(refDate, lmp);

    // Gebelik aralığı dışındaysa (SAT öncesi veya 40+ hafta) gösterme
    if (currentWeek == null) return const SizedBox.shrink();

    // ── Sadece bu haftanın WeekEvent'ini al ──────────────────────────────
    final ev = weekEventForDate(refDate, lmp);
    if (ev == null) return const SizedBox.shrink();

    return _EventRow(
      emoji: ev.emoji,
      label: isEn
          ? 'Week $currentWeek · ${ev.getTitle(isEn)}'
          : '$currentWeek. Hafta · ${ev.getTitle(isEn)}',
      color: ev.color,
      isDark: isDark,
      onTap: () => _showWeekDetail(context, currentWeek, ev, isEn),
    );
  }

  // ── Hafta olayı detayı ─────────────────────────────────────────────────
  void _showWeekDetail(
      BuildContext context, int week, WeekEvent event, bool isEn) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(event.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEn
                    ? 'Week $week · ${event.getTitle(isEn)}'
                    : '$week. Hafta · ${event.getTitle(isEn)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          event.getDetail(isEn),
          style: const TextStyle(fontSize: 13.5, height: 1.55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.okBtn,
                style: const TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }

}

// ── Tek satır widget'ı ────────────────────────────────────────────────────
class _EventRow extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _EventRow({
    required this.emoji,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.32 : 0.22),
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: color.withValues(alpha: isDark ? 0.5 : 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
