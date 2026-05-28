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
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        if (showSatBanner) _buildSatBanner(context, l10n),
        _buildWeekdayHeader(context),
        const SizedBox(height: 8),
        for (int r = 0; r < rowCount; r++) ...[
          _buildWeekRow(context, provider, appts, firstDay, startOffset,
              daysInMonth, r, isPregnancy, lmp),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  // ── SAT seçim yönlendirme banner'ı ─────────────────────────────────────
  Widget _buildSatBanner(BuildContext context, AppLocalizations l10n) {
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
              l10n.satBanner,
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
    final l10n = AppLocalizations.of(context)!;
    final isEn = l10n.isTurkish == false;
    final months = isEn
        ? ['January','February','March','April','May','June',
           'July','August','September','October','November','December']
        : ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran',
           'Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
    final label = '${date.day} ${months[date.month - 1]} ${date.year}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🌸', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.satDialogTitle,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          '$label ${l10n.satDialogBody}',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelBtn),
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
            child: Text(l10n.satDialogSetBtn),
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

  Widget _buildWeekdayHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = l10n.isTurkish
        ? ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
