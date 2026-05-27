// =============================================
// widgets/calendar_grid.dart
// Takvim ızgarasını çizen ana widget.
//
// Normal mod  : faz renkleri (regl/ovulasyon/doğurganlık).
// Hamile mod  :
//   • SAT yoksa → güne dokununca SAT seç dialogu
//   • SAT varsa  → trimester arka planları, SAT 🌸 rozeti, TDT ⭐ rozeti,
//                  hafta olayı emoji rozeti, gün bilgi sheet'i
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/pregnancy_data.dart';
import '../providers/appointment_provider.dart';
import '../providers/cycle_provider.dart';
import '../utils/phase_colors.dart';
import 'day_cell.dart';
import 'pregnancy/pregnancy_day_sheet.dart';

/// Takvimde randevu içeren günlerin nokta rengi.
const Color _appointmentDot = Color(0xFF3F51B5);

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final appts = context.watch<AppointmentProvider>();
    final month = provider.focusedMonth;
    final isPregnancy = provider.appMode == AppMode.hamileTakip;
    final lmp = provider.pregnancyStartDate;

    // Ayın ilk günü hangi haftanın günü? (Pazartesi=0 ... Pazar=6)
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday - 1; // weekday: 1=Pzt, 7=Pzr
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final trailing = _trailingDays(startOffset, daysInMonth);
    final rowCount = (startOffset + daysInMonth + trailing) ~/ 7;

    // Hamile mod + SAT yok → yönlendirme banner'ı
    final showSatBanner = isPregnancy && lmp == null;

    return Column(
      children: [
        if (showSatBanner) _buildSatBanner(context),
        _buildWeekdayHeader(context),
        const SizedBox(height: 8),
        for (int r = 0; r < rowCount; r++) ...[
          _buildWeekRow(context, provider, appts, firstDay, startOffset,
              daysInMonth, r, isPregnancy, lmp),
          if (isPregnancy)
            _buildWeekLabel(context, firstDay, startOffset, r, lmp),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  // ── SAT seçim yönlendirme banner'ı ─────────────────────────────────────
  Widget _buildSatBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Son adet tarihinizi seçmek için takvimde bir güne dokunun.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekRow(
    BuildContext context,
    CycleProvider provider,
    AppointmentProvider appts,
    DateTime firstDay,
    int startOffset,
    int daysInMonth,
    int row,
    bool isPregnancy,
    DateTime? lmp,
  ) {
    return Row(
      children: [
        for (int c = 0; c < 7; c++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AspectRatio(
                aspectRatio: 1,
                child: _cell(context, provider, appts, firstDay, startOffset,
                    daysInMonth, row * 7 + c, isPregnancy, lmp),
              ),
            ),
          ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    CycleProvider provider,
    AppointmentProvider appts,
    DateTime firstDay,
    int startOffset,
    int daysInMonth,
    int index,
    bool isPregnancy,
    DateTime? lmp,
  ) {
    final prevMonthLastDay =
        DateTime(firstDay.year, firstDay.month, 0).day;

    // Önceki ay
    if (index < startOffset) {
      final day = prevMonthLastDay - startOffset + index + 1;
      return DayCell(label: '$day', isOtherMonth: true);
    }
    // Sonraki ay
    final dayIndex = index - startOffset;
    if (dayIndex >= daysInMonth) {
      final day = dayIndex - daysInMonth + 1;
      return DayCell(label: '$day', isOtherMonth: true);
    }

    // Bu ayın günleri
    final date = DateTime(firstDay.year, firstDay.month, dayIndex + 1);
    final isToday = _isToday(date);
    final isSelected = provider.selectedDay != null &&
        _isSameDay(provider.selectedDay!, date);

    // ── Hamile mod ───────────────────────────────────────────────────
    if (isPregnancy) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // SAT seçilmemişse: herhangi geçmiş/bugün güne dokununca SAT dialog
      if (lmp == null) {
        final isFuture = date.isAfter(DateTime.now());
        return DayCell(
          label: '${date.day}',
          isToday: isToday,
          isSelected: isSelected,
          onTap: isFuture
              ? null
              : () => _showSetSatDialog(context, date, provider),
        );
      }

      // SAT var — tam hamilelik görünümü
      final isSat = _isSameDay(date, lmp);
      final dueDate = lmp.add(const Duration(days: 280));
      final isDue = _isSameDay(date, dueDate);
      final week = pregnancyWeekForDate(date, lmp);
      final tStyle = trimesterStyle(week, isDark: isDark);

      // Renkler
      Color? bg = tStyle?.background;
      Color? fg = tStyle?.textColor;
      if (isSat) {
        bg = const Color(0xFFE11D48).withValues(alpha: isDark ? 0.55 : 0.75);
        fg = Colors.white;
      } else if (isDue) {
        bg = const Color(0xFFDC2626).withValues(alpha: isDark ? 0.6 : 0.8);
        fg = Colors.white;
      }

      // Rozet
      String? badge;
      if (isSat) {
        badge = '🌸';
      } else if (isDue) {
        badge = '⭐';
      } else {
        final ev = weekEventForDate(date, lmp);
        if (ev != null) badge = ev.emoji;
      }

      // Noktalar
      final dots = milestonesForDate(date, lmp).map((m) => m.color).toList();
      if (appts.hasAppointmentOn(date)) dots.add(_appointmentDot);

      return DayCell(
        label: '${date.day}',
        isToday: isToday,
        isSelected: isSelected,
        backgroundColor: bg,
        textColor: fg,
        dots: dots,
        badge: badge,
        onTap: () => _handlePregnancyTap(context, date, lmp, dueDate, provider),
      );
    }

    // ── Normal mod ───────────────────────────────────────────────────
    final style = phaseStyle(provider.phaseOf(date));
    return DayCell(
      label: '${date.day}',
      backgroundColor: style.background,
      textColor: style.textColor,
      isToday: isToday,
      isSelected: isSelected,
      onTap: () => provider.selectDay(date),
    );
  }

  // ── SAT seç onay dialogu ────────────────────────────────────────────────
  void _showSetSatDialog(
      BuildContext context, DateTime date, CycleProvider provider) {
    const months = [
      'Ocak','Şubat','Mart','Nisan','Mayıs','Haziran',
      'Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık',
    ];
    final label = '${date.day} ${months[date.month - 1]} ${date.year}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🌸', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Son Adet Tarihi',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          '$label tarihini gebelik başlangıcı (SAT) olarak ayarlamak istiyor musunuz?\n\n'
          'Tahmini doğum tarihi otomatik hesaplanacak.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.updatePregnancyStartDate(date);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ayarla'),
          ),
        ],
      ),
    );
  }

  // ── Gün detay sheet (SAT seçiliyse) ────────────────────────────────────
  void _handlePregnancyTap(
    BuildContext context,
    DateTime date,
    DateTime lmp,
    DateTime dueDate,
    CycleProvider provider,
  ) {
    provider.selectDay(date);
    // Tarih SAT öncesiyse sheet açma
    final d0 = DateTime(lmp.year, lmp.month, lmp.day);
    final d1 = DateTime(date.year, date.month, date.day);
    if (d1.isBefore(d0)) return;
    // 40. haftadan fazla da gösterme
    final days = d1.difference(d0).inDays;
    if (days > 280) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.65,
        child: PregnancyDaySheet(
          date: date,
          lmp: lmp,
          dueDate: dueDate,
        ),
      ),
    );
  }

  /// Satırın hafta etiketi + varsa önemli olay bantları.
  Widget _buildWeekLabel(
    BuildContext context,
    DateTime firstDay,
    int startOffset,
    int row,
    DateTime? lmp,
  ) {
    final firstDateOfRow =
        firstDay.add(Duration(days: row * 7 - startOffset));
    final midDate = firstDateOfRow.add(const Duration(days: 3));
    final week = pregnancyWeekForDate(midDate, lmp);
    if (week == null) return const SizedBox.shrink();

    // WeekEvent'ler (hafta-bazlı)
    WeekEvent? rowWeekEvent;
    for (int d = 0; d < 7; d++) {
      final ev = weekEventForDate(
          firstDateOfRow.add(Duration(days: d)), lmp);
      if (ev != null) { rowWeekEvent = ev; break; }
    }

    // Bu satırda başlayan kMilestones
    final startingMilestones =
        milestonesStartingInRow(firstDateOfRow, lmp);

    // İkisi de yoksa satır boş
    if (rowWeekEvent == null && startingMilestones.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tüm bantları listele
    final bands = <Widget>[];

    if (rowWeekEvent != null) {
      bands.add(_eventBand(
        rowWeekEvent.emoji,
        '$week. Hafta · ${rowWeekEvent.title}',
        rowWeekEvent.color,
        isDark,
      ));
    }

    for (final m in startingMilestones) {
      // WeekEvent ile başlığı aynıysa tekrar gösterme
      if (rowWeekEvent != null &&
          m.title.toLowerCase() ==
              rowWeekEvent.title.toLowerCase()) { continue; }
      bands.add(_eventBand(
        m.category.emoji,
        m.title,
        m.color,
        isDark,
      ));
    }

    if (bands.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bands
            .map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: b,
                ))
            .toList(),
      ),
    );
  }

  Widget _eventBand(
      String emoji, String label, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr'];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  int _trailingDays(int startOffset, int daysInMonth) {
    final remainder = (startOffset + daysInMonth) % 7;
    return remainder == 0 ? 0 : 7 - remainder;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
