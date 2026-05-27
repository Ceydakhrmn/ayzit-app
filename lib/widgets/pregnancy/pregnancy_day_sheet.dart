// =============================================
// widgets/pregnancy/pregnancy_day_sheet.dart
//
// Hamile modunda takvimde bir güne tıklanınca
// açılan bottom sheet.
// Gösterir:
//   • Tarih + gebelik haftası
//   • Hafta olayı (milestone emoji + başlık)
//   • Bebek gelişim özeti
//   • TDT ise burç bilgisi
// =============================================

import 'package:flutter/material.dart';

import '../../data/pregnancy_data.dart';

class PregnancyDaySheet extends StatelessWidget {
  final DateTime date;
  final DateTime lmp;
  final DateTime dueDate;

  const PregnancyDaySheet({
    super.key,
    required this.date,
    required this.lmp,
    required this.dueDate,
  });

  static const _purple = Color(0xFF7C3AED);

  static String _fmtDate(DateTime d) {
    const months = [
      'Ocak','Şubat','Mart','Nisan','Mayıs','Haziran',
      'Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık',
    ];
    const days = ['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final week = pregnancyWeekForDate(date, lmp);
    final isSat = _isSameDay(date, lmp);
    final isDue = _isSameDay(date, dueDate);
    final weekEvent = weekEventForDate(date, lmp);
    final info = week != null ? pregnancyWeekInfo(week) : null;
    final zodiac = isDue ? zodiacForDate(dueDate) : null;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tarih başlığı ─────────────────────────────────────
            Text(
              _fmtDate(date),
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 4),

            // ── Hafta / özel etiket ───────────────────────────────
            if (isSat)
              _Badge(
                emoji: '🌸',
                label: 'Son Adet Tarihi (SAT)',
                color: const Color(0xFFE11D48),
                isDark: isDark,
              )
            else if (isDue)
              _Badge(
                emoji: '🎊',
                label: 'Tahmini Doğum Tarihi',
                color: const Color(0xFFDC2626),
                isDark: isDark,
              )
            else if (week != null)
              _Badge(
                emoji: '🤰',
                label: '$week. Hafta',
                color: _purple,
                isDark: isDark,
              ),

            // ── Hafta olayı ───────────────────────────────────────
            if (weekEvent != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: weekEvent.color.withValues(alpha: isDark ? 0.15 : 0.09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: weekEvent.color.withValues(alpha: isDark ? 0.35 : 0.22),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(weekEvent.emoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weekEvent.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: weekEvent.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weekEvent.detail,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: cs.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Bebek gelişim özeti ───────────────────────────────
            if (info != null) ...[
              const SizedBox(height: 14),
              Text(
                '👶 ${info.week}. Hafta — Bebek Gelişimi',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _purple,
                ),
              ),
              const SizedBox(height: 6),
              if (info.heightText.isNotEmpty || info.weightText.isNotEmpty)
                Row(
                  children: [
                    if (info.heightText.isNotEmpty) ...[
                      Text('📏 ${info.heightText}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withValues(alpha: 0.75),
                          )),
                      const SizedBox(width: 14),
                    ],
                    if (info.weightText.isNotEmpty)
                      Text('⚖️ ${info.weightText}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withValues(alpha: 0.75),
                          )),
                  ],
                ),
              const SizedBox(height: 6),
              Text(
                info.summary,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: cs.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],

            // ── Burç (yalnızca TDT günü) ──────────────────────────
            if (zodiac != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2D1B69), const Color(0xFF1E1040)]
                        : [const Color(0xFFEDE9FE), const Color(0xFFF5F3FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _purple.withValues(alpha: isDark ? 0.4 : 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      zodiac.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bebeğinin Burcu',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _purple.withValues(
                                  alpha: isDark ? 0.7 : 0.6),
                            ),
                          ),
                          Text(
                            zodiac.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _purple,
                            ),
                          ),
                          Text(
                            zodiac.dateRange,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── SAT başlangıç notu ────────────────────────────────
            if (isSat) ...[
              const SizedBox(height: 14),
              Text(
                'Bu tarih, gebeliğinizin başlangıç noktası (Son Adet Tarihi) '
                'olarak ayarlanmış. Tüm hafta hesaplamaları bu tarihten itibaren yapılır.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.55,
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool isDark;
  const _Badge({
    required this.emoji,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
