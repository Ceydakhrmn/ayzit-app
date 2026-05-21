// =============================================
// widgets/calendar_grid.dart
// Takvim ızgarasını çizen ana widget.
// Hamile takip modunda: faz renkleri yerine kilometre taşı noktaları
// gösterir ve her takvim satırının altına "N. Hafta" etiketi koyar.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/pregnancy_data.dart';
import '../providers/appointment_provider.dart';
import '../providers/cycle_provider.dart';
import '../utils/phase_colors.dart';
import 'day_cell.dart';

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

    return Column(
      children: [
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

    // Hamile takip modunda faz renkleri yerine kilometre taşı noktaları
    // ve randevu işareti gösterilir.
    if (isPregnancy) {
      final dots = milestonesForDate(date, lmp).map((m) => m.color).toList();
      if (appts.hasAppointmentOn(date)) {
        dots.add(_appointmentDot);
      }
      return DayCell(
        label: '${date.day}',
        isToday: isToday,
        isSelected: isSelected,
        dots: dots,
        onTap: () => provider.selectDay(date),
      );
    }

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

  /// Satırın gebelik haftası etiketi ("N. Hafta"). LMP yoksa boş.
  Widget _buildWeekLabel(
    BuildContext context,
    DateTime firstDay,
    int startOffset,
    int row,
    DateTime? lmp,
  ) {
    // Satırın ortasındaki günü (Perşembe) temsilci olarak al.
    final midDate =
        firstDay.add(Duration(days: row * 7 - startOffset + 3));
    final week = pregnancyWeekForDate(midDate, lmp);
    if (week == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$week. Hafta',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.4),
          ),
        ),
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
