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
    final month = provider.focusedMonth;

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // ── Hafta olaylarını topla (ayda bir kez göster) ──────────────────────
    final seenWeeks = <int>{};
    final weekItems = <({int week, WeekEvent event})>[];

    for (int d = 0; d < daysInMonth; d++) {
      final date = firstDay.add(Duration(days: d));
      final week = pregnancyWeekForDate(date, lmp);
      if (week == null) continue;
      if (seenWeeks.contains(week)) continue;
      seenWeeks.add(week);
      final ev = weekEventForDate(date, lmp);
      if (ev != null) weekItems.add((week: week, event: ev));
    }

    // ── Kilometre taşlarını topla (bu ayda başlayanlar) ───────────────────
    final milestoneItems = <({DateTime date, PregnancyMilestone milestone})>[];
    final seenMilestones = <String>{};

    for (int d = 0; d < daysInMonth; d++) {
      final date = firstDay.add(Duration(days: d));
      for (final m in milestonesForDate(date, lmp)) {
        final key = m.getTitle(false); // Türkçe key olarak kullan
        if (seenMilestones.contains(key)) continue;
        // Hafta olayıyla aynı başlıksa atla
        final alreadyInWeekItems = weekItems.any(
          (w) => w.event.getTitle(isEn).toLowerCase() == m.getTitle(isEn).toLowerCase(),
        );
        if (alreadyInWeekItems) continue;
        seenMilestones.add(key);
        milestoneItems.add((date: date, milestone: m));
      }
    }

    if (weekItems.isEmpty && milestoneItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Hafta gelişim olayları
        for (final item in weekItems)
          _EventRow(
            emoji: item.event.emoji,
            label: isEn
                ? 'Week ${item.week} · ${item.event.getTitle(isEn)}'
                : '${item.week}. Hafta · ${item.event.getTitle(isEn)}',
            color: item.event.color,
            isDark: isDark,
            onTap: () => _showWeekDetail(context, item.week, item.event, isEn),
          ),

        // Kilometre taşları
        for (final item in milestoneItems)
          _EventRow(
            emoji: item.milestone.category.emoji,
            label: item.milestone.getTitle(isEn),
            color: item.milestone.color,
            isDark: isDark,
            onTap: () => _showMilestoneDetail(context, item.milestone, isEn),
          ),
      ],
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

  // ── Kilometre taşı detayı ─────────────────────────────────────────────
  void _showMilestoneDetail(
      BuildContext context, PregnancyMilestone milestone, bool isEn) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: milestone.color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                milestone.getTitle(isEn),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          milestone.description,
          style: const TextStyle(fontSize: 13.5, height: 1.5),
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
