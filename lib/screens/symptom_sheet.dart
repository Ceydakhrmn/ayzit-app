import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';

Future<void> showSymptomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: const _SymptomSheet(),
    ),
  );
}

class _SymptomSheet extends StatefulWidget {
  const _SymptomSheet();

  @override
  State<_SymptomSheet> createState() => _SymptomSheetState();
}

class _SymptomSheetState extends State<_SymptomSheet> {
  final Set<String> _selectedSymptoms = {};

  void _save() {
    if (_selectedSymptoms.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<CycleProvider>();
    final selected = provider.selectedDay ?? DateTime.now();
    final existing = provider.noteForDay(selected);
    final symptomText = _selectedSymptoms.join(', ');
    final newNote = existing.isEmpty ? symptomText : '$existing\n$symptomText';
    provider.saveNote(selected, newNote);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.symptomsSavedSnack),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final l10n = AppLocalizations.of(context)!;
    final isEn = !l10n.isTurkish;

    final physicalSymptoms = isEn
        ? const [
            'Abdominal Pain', 'Headache', 'Back Pain', 'Bloating',
            'Cramps', 'Nausea', 'Breast Tenderness', 'Acne',
            'Fatigue', 'Increased Appetite',
          ]
        : const [
            'Karın Ağrısı', 'Baş Ağrısı', 'Bel Ağrısı', 'Şişkinlik',
            'Kramp', 'Bulantı', 'Göğüs Hassasiyeti', 'Sivilce',
            'Yorgunluk', 'İştah Artışı',
          ];

    final emotionalSymptoms = isEn
        ? const [
            'Irritability', 'Anxiety', 'Sadness',
            'Mood Swings', 'Difficulty Concentrating', 'Lack of Motivation',
          ]
        : const [
            'Sinirlilik', 'Kaygı', 'Üzüntü',
            'Duygusal Dalgalanma', 'Konsantrasyon Güçlüğü', 'Motivasyon Eksikliği',
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                l10n.symptomSheetTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: subTextColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.symptomSheetHint,
            style: TextStyle(fontSize: 13, color: subTextColor),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.physicalLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: physicalSymptoms.map((s) => _SymptomChip(
              label: s,
              selected: _selectedSymptoms.contains(s),
              onTap: () => setState(() {
                if (_selectedSymptoms.contains(s)) {
                  _selectedSymptoms.remove(s);
                } else {
                  _selectedSymptoms.add(s);
                }
              }),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emotionalLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotionalSymptoms.map((s) => _SymptomChip(
              label: s,
              selected: _selectedSymptoms.contains(s),
              onTap: () => setState(() {
                if (_selectedSymptoms.contains(s)) {
                  _selectedSymptoms.remove(s);
                } else {
                  _selectedSymptoms.add(s);
                }
              }),
            )).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: Text(l10n.saveBtn),
          ),
        ],
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  const _SymptomChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
