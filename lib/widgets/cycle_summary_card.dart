import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';
import '../screens/stats_screen.dart';

class CycleSummaryCard extends StatelessWidget {
  const CycleSummaryCard({super.key});

  static const Color kPurple      = Color(0xFF7C3AED);
  static const Color kPurpleLight = Color(0xFFC084FC);
  static const Color kBlue        = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CycleProvider>();
    final l10n     = AppLocalizations.of(context)!;
    final isEn     = !l10n.isTurkish;
    final now      = DateTime.now();
    final start    = provider.cycle.cycleStart;
    final cLen     = provider.cycleLength;
    final pLen     = provider.periodLength;

    final List<DateTime> pastStarts = [];
    DateTime s = start;
    while (pastStarts.length < 3) {
      pastStarts.add(s);
      s = s.subtract(Duration(days: cLen));
    }

    final daysAgo = now.difference(start).inDays;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3D2A5E) : const Color(0xFFE9D5FF),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: kPurple.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık ──
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text(
                    l10n.cycleSummaryTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: kPurple, size: 20),
                ],
              ),
            ),
          ),

          // ── Geçmiş başlığı ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Text(
                  l10n.historyLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: cs.primary, size: 16),
              ],
            ),
          ),

          // ── Döngü listesi ──
          ...pastStarts.asMap().entries.map((e) {
            final idx            = e.key;
            final cycleStart     = e.value;
            final cycleEnd       = cycleStart.add(Duration(days: cLen - 1));
            final isCurrentCycle = idx == 0;
            final actualLen      = isCurrentCycle
                ? now.difference(cycleStart).inDays + 1
                : cLen;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      children: [
                        TextSpan(
                          text: isCurrentCycle
                              ? '${l10n.currentPeriodLabel}: '
                              : '$actualLen ${l10n.daysUnit}: ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: isCurrentCycle
                              ? '${l10n.periodStartPrefix} ${_fmt(cycleStart, isEn)} ($cLen ${l10n.daysUnit})'
                              : '${_fmt(cycleStart, isEn)} - ${_fmt(cycleEnd, isEn)}',
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 2),
                  child: Text(
                    '$pLen ${l10n.periodDurationSuffix}',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: _CycleBar(
                    cycleLength: cLen,
                    periodLength: pLen,
                    filled: isCurrentCycle ? (now.difference(cycleStart).inDays + 1) : cLen,
                    isDark: isDark,
                  ),
                ),
                if (idx < pastStarts.length - 1)
                  Divider(height: 1, indent: 16, endIndent: 16,
                      color: cs.onSurface.withValues(alpha: 0.1)),
              ],
            );
          }),

          Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.1)),

          // ── Özet başlığı ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Text(
                  l10n.yourSummaryLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: cs.primary, size: 16),
              ],
            ),
          ),

          // ── Özet satırları ──
          _SummaryRow(
            label: l10n.lastPeriodLabel,
            value: '${l10n.periodStartPrefix}: ${_fmtFull(start, isEn)}',
            sub: '${daysAgo > 0 ? daysAgo : 0} ${l10n.daysAgoSuffix}',
          ),
          Divider(height: 1, indent: 16, endIndent: 16,
              color: cs.onSurface.withValues(alpha: 0.1)),
          _SummaryRow(
            label: l10n.normalPeriodDurationLabel,
            value: '$pLen ${l10n.daysUnit}',
          ),
          Divider(height: 1, indent: 16, endIndent: 16,
              color: cs.onSurface.withValues(alpha: 0.1)),
          _SummaryRow(
            label: l10n.normalCycleLengthLabel,
            value: '$cLen ${l10n.daysUnit}',
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _fmt(DateTime d, bool isEn) {
    const trMonths = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
                      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    const enMonths = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final months = isEn ? enMonths : trMonths;
    return '${d.day} ${months[d.month]}';
  }

  String _fmtFull(DateTime d, bool isEn) {
    const trMonths = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    const enMonths = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
    final months = isEn ? enMonths : trMonths;
    return '${d.day} ${months[d.month]}';
  }
}

// ── Döngü bar widget'ı ──
class _CycleBar extends StatelessWidget {
  final int cycleLength;
  final int periodLength;
  final int filled;
  final bool isDark;

  const _CycleBar({
    required this.cycleLength,
    required this.periodLength,
    required this.filled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ovDay    = cycleLength - 14;
    final fertStart = ovDay - 5;
    final fertEnd   = ovDay + 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(cycleLength, (i) {
          final day = i + 1;
          Color col;

          if (day <= periodLength) {
            col = day <= 2
                ? const Color(0xFF7C3AED)
                : const Color(0xFFC084FC);
          } else if (day >= fertStart && day <= fertEnd) {
            col = const Color(0xFF3B82F6);
          } else {
            col = isDark ? const Color(0xFF3D3650) : const Color(0xFFE5E7EB);
          }

          final opacity = day <= filled ? 1.0 : 0.45;

          return Container(
            width: 10,
            height: 16,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: col.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      ),
    );
  }
}

// ── Özet satırı widget'ı ──
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;

  const _SummaryRow({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
