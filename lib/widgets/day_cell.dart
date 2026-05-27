// =============================================
// widgets/day_cell.dart
// Takvimdeki tek bir gün kutusu.
// Hamile takip modunda gün altında kilometre taşı noktaları gösterir.
// =============================================

import 'package:flutter/material.dart';

class DayCell extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOtherMonth;
  final bool isToday;
  final bool isSelected;
  final VoidCallback? onTap;

  /// Hamile modunda gün altında gösterilen kilometre taşı noktaları (en fazla 3).
  final List<Color> dots;

  /// Sağ üst köşede küçük emoji rozeti (SAT, TDT, milestone için).
  final String? badge;

  const DayCell({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.isOtherMonth = false,
    this.isToday = false,
    this.isSelected = false,
    this.onTap,
    this.dots = const [],
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? const Color(0xFF2D2840) : const Color(0xFFF1F1F1));
    final fg = textColor ?? (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF555555));
    final hasDots = dots.isNotEmpty && !isOtherMonth;

    return GestureDetector(
      onTap: isOtherMonth ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Diğer aylara ait günler renksiz ve şeffaf
          color: isOtherMonth ? Colors.transparent : bg,
          // Bugün için dış çizgi (outline)
          border: isToday && !isSelected
              ? Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 2)
              : isSelected
                  ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5)
                  : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gün numarası — nokta varsa biraz yukarı kayar.
            Padding(
              padding: EdgeInsets.only(bottom: hasDots ? 8 : 0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isOtherMonth
                      ? (isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.4))
                      : fg,
                ),
              ),
            ),
            if (hasDots)
              Positioned(
                bottom: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final c in dots.take(3))
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c),
                      ),
                  ],
                ),
              ),
            // Sağ üst rozet (SAT / TDT / milestone emoji) — kontrast kabarcık
            if (badge != null && !isOtherMonth)
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.80),
                    shape: BoxShape.circle,
                  ),
                  child: Text(badge!, style: const TextStyle(fontSize: 11)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
