// =============================================
// widgets/pregnancy/important_days_card.dart
// Hamile takip modunda "ÖNEMLİ GÜNLER" kartları.
// Seçili güne (yoksa bugüne) denk gelen kilometre taşlarını listeler.
// Her kart dokununca açıklamasını gösterir.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/pregnancy_data.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cycle_provider.dart';

class ImportantDaysCard extends StatelessWidget {
  const ImportantDaysCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final lmp = provider.pregnancyStartDate;
    final date = provider.selectedDay ?? DateTime.now();
    final milestones = milestonesForDate(date, lmp);

    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in milestones) ...[
          _MilestoneTile(milestone: m),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final PregnancyMilestone milestone;
  const _MilestoneTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = !l10n.isTurkish;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(context, isEnglish: isEnglish),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importantDaysTitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: milestone.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      milestone.getTitle(isEnglish),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: milestone.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, {bool isEnglish = false}) {
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
                milestone.getTitle(isEnglish),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          milestone.description,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelBtn, style: const TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }
}
