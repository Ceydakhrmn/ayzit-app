import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../widgets/calendar_grid.dart';
import 'symptom_sheet.dart';
import 'settings_screen.dart';
import '../widgets/month_header.dart';
import '../widgets/info_card.dart';
import '../widgets/note_card.dart';
import '../widgets/cycle_summary_card.dart';
import '../widgets/pregnancy/appointments_card.dart';
import '../widgets/pregnancy/important_days_card.dart';
import '../widgets/pregnancy/pregnancy_calculator_card.dart';
import '../widgets/fertility/fertility_info_cards.dart';

void showLegendDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Sanırım yardıma ihtiyacın var.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Renkler dönemleri gösterir. Ben de sana bu dönemlere göre tavsiyeler veririm ;)',
            style: TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _LegendRow(color: const Color(0xFF7C3AED), label: 'Regl dönemi (yoğun).'),
          _LegendRow(color: const Color(0xFFC084FC), label: 'Regl dönemi (hafif).'),
          _LegendRow(color: const Color(0xFF3B82F6), label: 'Ovulasyon günü.'),
          _LegendRow(color: const Color(0xFFDC2626), label: 'Doğurganlık — en yüksek.'),
          _LegendRow(color: const Color(0xFFF97316), label: 'Doğurganlık — orta.'),
          _LegendRow(color: const Color(0xFFFDE047), label: 'Doğurganlık — düşük.'),
          _LegendRow(isBlend: true, label: 'Soluk renkli olanlar benim tahminimdir.'),
          _LegendRow(color: Colors.grey.shade300, label: 'Takvime bilgi girdiğini gösterir.'),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              side: const BorderSide(color: Colors.black12),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'ANLADIM',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _LegendRow extends StatelessWidget {
  final Color? color;
  final String label;
  final bool isBlend;
  const _LegendRow({
    this.color,
    required this.label,
    this.isBlend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (isBlend)
            SizedBox(
              width: 36, height: 36,
              child: Stack(children: [
                Positioned(left: 0, top: 4, child: Container(width: 20, height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.4)))),
                Positioned(left: 8, top: 4, child: Container(width: 20, height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.4)))),
                Positioned(left: 4, top: 10, child: Container(width: 20, height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: const Color(0xFFDC2626).withValues(alpha: 0.4)))),
              ]),
            )
          else
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// ── Hamile kalma alt-mod seçimi ─────────────────────────────────────────────

enum _ConceptionMode { dogal, asilama, tupBebek }

class _HamilleKalmaContent extends StatefulWidget {
  const _HamilleKalmaContent();

  @override
  State<_HamilleKalmaContent> createState() => _HamilleKalmaContentState();
}

class _HamilleKalmaContentState extends State<_HamilleKalmaContent> {
  _ConceptionMode _mode = _ConceptionMode.dogal;

  static const _accent = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Soru başlığı ─────────────────────────────────────────────────
        Text(
          'Nasıl hamile kalmayı planlıyorsunuz?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        // ── Üç seçenek ───────────────────────────────────────────────────
        Row(
          children: [
            _chip(context, '🌸', 'Doğal', _ConceptionMode.dogal, isDark),
            const SizedBox(width: 8),
            _chip(context, '🔬', 'Aşılama', _ConceptionMode.asilama, isDark),
            const SizedBox(width: 8),
            _chip(context, '🧬', 'Tüp Bebek', _ConceptionMode.tupBebek, isDark),
          ],
        ),
        const SizedBox(height: 20),
        // ── Seçime göre içerik ────────────────────────────────────────────
        if (_mode == _ConceptionMode.dogal) ...[
          const FertilityPrepCard(),
          const SizedBox(height: 12),
          const PregnancySymptomsCard(),
        ] else if (_mode == _ConceptionMode.asilama) ...[
          const IUIInfoCard(),
        ] else ...[
          const IVFInfoCard(),
        ],
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String emoji,
    String label,
    _ConceptionMode mode,
    bool isDark,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? _accent.withValues(alpha: isDark ? 0.28 : 0.1)
                : cs.onSurface.withValues(alpha: isDark ? 0.06 : 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? _accent.withValues(alpha: isDark ? 0.55 : 0.45)
                  : cs.onSurface.withValues(alpha: 0.12),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? _accent
                      : cs.onSurface.withValues(alpha: 0.55),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Tam genişlikte "BELİRTİ GİR" butonu.
  Widget _symptomButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => showSymptomSheet(context),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('BELİRTİ GİR'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA78BFA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Regl başlat / bitir butonu.
  Widget _periodButton(BuildContext context, CycleProvider provider) {
    return ElevatedButton.icon(
      onPressed: () {
        if (provider.isPeriodActive) {
          provider.endPeriod();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Regl bitirildi!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          final selected = provider.selectedDay;
          final startDate = selected ?? DateTime.now();
          provider.startPeriod(startDate);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                selected != null
                    ? '${startDate.day}/${startDate.month} tarihinden regl başlatıldı!'
                    : 'Regl başlatıldı!',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      icon: const Icon(Icons.water_drop, size: 16),
      label: Text(provider.isPeriodActive ? 'REGL BİTİR' : 'REGL BAŞLAT'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final isPregnancy = provider.appMode == AppMode.hamileTakip;

    return SafeArea(
      child: Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.palette_outlined,
                    color: Color(0xFF7C3AED)),
                tooltip: 'Takvim Renkleri',
                onPressed: () => showLegendDialog(context),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Color(0xFF7C3AED)),
                tooltip: 'Ayarlar',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MonthHeader(),
                const SizedBox(height: 8),
                const CalendarGrid(),
                const SizedBox(height: 16),

                // ── Hamile takip modu ──
                if (isPregnancy) ...[
                  const ImportantDaysCard(),
                  const SizedBox(height: 12),
                  const AppointmentsCard(),
                  const SizedBox(height: 12),
                  _symptomButton(context),
                  const SizedBox(height: 16),
                  const PregnancyCalculatorCard(),
                  const SizedBox(height: 20),
                ]
                // ── Hamile kalma modu ──
                else if (provider.appMode == AppMode.hamilleKalma) ...[
                  const _HamilleKalmaContent(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _symptomButton(context)),
                      const SizedBox(width: 10),
                      Expanded(child: _periodButton(context, provider)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const CycleSummaryCard(),
                  const SizedBox(height: 20),
                ]
                // ── Regl takip modu ──
                else ...[
                  const InfoCard(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _symptomButton(context)),
                      const SizedBox(width: 10),
                      Expanded(child: _periodButton(context, provider)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const NoteCard(),
                  const SizedBox(height: 16),
                  const CycleSummaryCard(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}