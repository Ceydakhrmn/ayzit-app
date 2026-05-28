import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';
import '../utils/phase_colors.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final selected = provider.selectedDay;

    String label = l10n.selectDayLabel;
    Color dotColor = Colors.grey.shade300;
    String phaseDescription = '';

    if (selected != null) {
      final phase = provider.phaseOf(selected);
      final style = phaseStyle(phase);
      label = '${selected.day} ${_monthName(selected.month, l10n.isTurkish)}';
      dotColor = style.background;
      phaseDescription = style.label;
    }

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (phaseDescription.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phaseDescription,
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ],
            ),
          ),
          if (selected != null)
            GestureDetector(
              onTap: () => _showPhaseInfo(context, dotColor, phaseDescription, l10n),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                child: const Icon(Icons.info_outline, size: 14, color: Colors.white70),
              ),
            )
          else
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
        ],
      ),
    );
  }

  void _showPhaseInfo(BuildContext context, Color color, String description, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.okBtn, style: const TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }

  String _monthName(int month, bool isTurkish) {
    const tr = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    const en = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return isTurkish ? tr[month] : en[month];
  }
}
