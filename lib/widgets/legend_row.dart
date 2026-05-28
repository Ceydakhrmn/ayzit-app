// =============================================
// widgets/legend_row.dart
// Alt kısımdaki renk açıklama (legend) widget'ı
// =============================================

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/phase_colors.dart';

class LegendRow extends StatelessWidget {
  const LegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final items = [
      _LegendItem(color: kPeriodPeak,  label: isEn ? 'Period (heavy)' : 'Regl (yoğun)'),
      _LegendItem(color: kPeriodLight, label: isEn ? 'Period (light)' : 'Regl (hafif)'),
      _LegendItem(color: kFertilePeak, label: isEn ? 'Fertility — peak' : 'Doğurganlık — en yüksek'),
      _LegendItem(color: kFertileMid,  label: isEn ? 'Fertility — mid' : 'Doğurganlık — orta'),
      _LegendItem(color: kFertileLow,  label: isEn ? 'Fertility — low' : 'Doğurganlık — düşük'),
      _LegendItem(color: kOvulation,   label: isEn ? 'Ovulation' : 'Ovulasyon'),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) => _buildItem(item)).toList(),
    );
  }

  Widget _buildItem(_LegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          item.label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
}
