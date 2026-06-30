// =============================================
// widgets/month_header.dart
// Üstteki ay adı + ileri/geri ok butonları
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';

class MonthHeader extends StatelessWidget {
  const MonthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final month = provider.focusedMonth;

    final monthName = _monthName(month.month, l10n.isTurkish).toUpperCase();
    final title = '$monthName ${month.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: provider.previousMonth,
          icon: const Icon(Icons.chevron_left),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: provider.nextMonth,
          icon: const Icon(Icons.chevron_right),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ],
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
