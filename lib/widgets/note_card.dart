import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';

class NoteCard extends StatefulWidget {
  const NoteCard({super.key});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  final TextEditingController _noteController = TextEditingController();
  String? _loadedDayKey;

  String _dayKey(DateTime? d) => d == null
      ? ''
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final selected = provider.selectedDay;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = !AppLocalizations.of(context)!.isTurkish;

    final currentKey = _dayKey(selected);
    if (currentKey != _loadedDayKey) {
      _loadedDayKey = currentKey;
      final existing = selected != null ? provider.noteForDay(selected) : '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _noteController.text = existing;
        _noteController.selection = TextSelection.collapsed(offset: existing.length);
      });
    }

    final cs = Theme.of(context).colorScheme;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.black38;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Not',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            enabled: selected != null,
            maxLines: null,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            style: TextStyle(fontSize: 13, color: textColor),
            decoration: InputDecoration(
              hintText: selected == null
                  ? (isEn ? 'Select a day from the calendar...' : 'Takvimden bir gün seç...')
                  : (isEn ? 'Write your note here...' : 'Notunu buraya yaz...'),
              hintStyle: TextStyle(fontSize: 13, color: hintColor),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (selected != null) {
                provider.saveNote(selected, value);
              }
            },
          ),
        ],
      ),
    );
  }
}
