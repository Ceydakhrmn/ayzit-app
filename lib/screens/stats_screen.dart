import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_background.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const Color kPurple      = Color(0xFF7C3AED);
  static const Color kPurpleLight = Color(0xFFC084FC);
  static const Color kBlue        = Color(0xFF3B82F6);
  static const Color kBg          = Color(0xFFF5F0FF);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final cycleLens  = provider.lastCycleLengths(n: 6);
    final periodLens = provider.lastPeriodLengths(n: 6);
    final history    = provider.cycleHistory;
    final isEn = !AppLocalizations.of(context)!.isTurkish;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEn ? 'Statistics' : 'İstatistikler',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Özet kartları ──
            Row(children: [
              _StatChip(
                label: isEn ? 'Avg. Cycle' : 'Ort. Süre',
                value: isEn ? '${_avg(cycleLens)} days' : '${_avg(cycleLens)} gün',
                icon: Icons.loop,
                color: kPurple,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: isEn ? 'Avg. Period' : 'Ort. Regl',
                value: isEn ? '${_avg(periodLens)} days' : '${_avg(periodLens)} gün',
                icon: Icons.water_drop,
                color: kBlue,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: isEn ? 'Records' : 'Kayıt',
                value: isEn ? '${history.length}' : '${history.length} kayıt',
                icon: Icons.calendar_today,
                color: kPurpleLight,
              ),
            ]),

            const SizedBox(height: 20),

            // ── Döngü uzunluğu grafiği ──
            _SectionTitle(title: isEn ? 'Last 6 Cycle Lengths' : 'Son 6 Adet Süresi'),
            const SizedBox(height: 10),
            _ChartCard(
              child: SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (_maxVal(cycleLens) + 5).toDouble(),
                    minY: 0,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => kPurple,
                        getTooltipItem: (group, gI, rod, rI) => BarTooltipItem(
                          isEn ? '${rod.toY.round()} d' : '${rod.toY.round()} gün',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) => Text(
                            '${val.toInt() + 1}.',
                            style: const TextStyle(fontSize: 11, color: Colors.black45),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) => Text(
                            val.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.black38),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: cycleLens.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble(),
                          color: kPurple,
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (_maxVal(cycleLens) + 5).toDouble(),
                            color: const Color(0xFFF3EEFF),
                          ),
                        ),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Regl süresi grafiği ──
            _SectionTitle(title: isEn ? 'Last 6 Period Lengths' : 'Son 6 Regl Süresi'),
            const SizedBox(height: 10),
            _ChartCard(
              child: SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: (_maxVal(periodLens) + 3).toDouble(),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => kBlue,
                        getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                          isEn ? '${s.y.round()} d' : '${s.y.round()} gün',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        )).toList(),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) => Text(
                            '${val.toInt() + 1}.',
                            style: const TextStyle(fontSize: 11, color: Colors.black45),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (val, meta) => Text(
                            val.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.black38),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: periodLens.asMap().entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                            .toList(),
                        isCurved: true,
                        color: kBlue,
                        barWidth: 3,
                        dotData: FlDotData(
                          getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                            radius: 4,
                            color: kBlue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: kBlue.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Döngü geçmişi tablosu ──
            _SectionTitle(title: isEn ? 'History' : 'Geçmiş'),
            const SizedBox(height: 10),
            if (history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isEn
                      ? 'No records yet.\nStart and end a period to see your history.'
                      : 'Henüz kayıt yok.\nRegl başlatıp bitirince buraya işlenir.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black38, fontSize: 13),
                ),
              )
            else
              _ChartCard(
                child: Column(
                  children: [
                    // Tablo başlığı
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                      child: Row(children: [
                        Expanded(child: Text(isEn ? 'Start' : 'Başlangıç', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black45))),
                        const SizedBox(width: 8),
                        SizedBox(width: 70, child: Text(isEn ? 'Period' : 'Regl', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black45))),
                        SizedBox(width: 70, child: Text(isEn ? 'Cycle' : 'Süre', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black45))),
                      ]),
                    ),
                    const Divider(height: 1),
                    ...history.reversed.take(8).map((r) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: Row(children: [
                            Expanded(child: Text(
                              _fmtDate(r.start, isEn: isEn),
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            )),
                            SizedBox(width: 70, child: _PillBadge(
                              value: isEn ? '${r.periodDays}d' : '${r.periodDays} gün',
                              color: kBlue,
                            )),
                            SizedBox(width: 70, child: _PillBadge(
                              value: isEn ? '${r.cycleDays}d' : '${r.cycleDays} gün',
                              color: kPurple,
                            )),
                          ]),
                        ),
                        const Divider(height: 1),
                      ],
                    )),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }

  int _avg(List<int> list) {
    if (list.isEmpty) return 0;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }

  int _maxVal(List<int> list) {
    if (list.isEmpty) return 35;
    return list.reduce((a, b) => a > b ? a : b);
  }

  String _fmtDate(DateTime d, {bool isEn = false}) {
    const monthsTr = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
                      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    const monthsEn = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final months = isEn ? monthsEn : monthsTr;
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
  );
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: child,
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _PillBadge extends StatelessWidget {
  final String value;
  final Color color;
  const _PillBadge({required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(value, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ),
  );
}
