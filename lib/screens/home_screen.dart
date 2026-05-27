import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../widgets/calendar_grid.dart';
import 'symptom_sheet.dart';
import 'settings_screen.dart';
import '../widgets/month_header.dart';
import '../widgets/info_card.dart';
import '../widgets/note_card.dart';
import '../widgets/mood_card.dart';
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

void showMoodDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ruh Hali',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const MoodCard(),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('KAPAT'),
            ),
          ],
        ),
      ),
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

class _ActionChipRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ChipButton(
          icon: Icons.emoji_emotions_outlined,
          label: 'Ruh Halim',
          onTap: () => showMoodDialog(context),
        ),
        const SizedBox(width: 8),
        _ChipButton(
          icon: Icons.info_outline,
          label: 'Takvim Renkleri',
          onTap: () => showLegendDialog(context),
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ChipButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Tam genişlikte "BELİRTİ GİR" butonu (her iki modda kullanılır).
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final isPregnancy = provider.appMode == AppMode.hamileTakip;

    return SafeArea(
      child: Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
          child: Row(
            children: [
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
                // ── Regl / hamile kalma modu ──
                else ...[
                  _ActionChipRow(),
                  const SizedBox(height: 12),
                  const InfoCard(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _symptomButton(context)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
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
                          label: Text(provider.isPeriodActive
                              ? 'REGL BİTİR'
                              : 'REGL BAŞLAT'),
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const NoteCard(),
                  const SizedBox(height: 16),
                  const CycleSummaryCard(),
                  const SizedBox(height: 20),
                  // ── Hamile kalma modu ek bilgi kartları ──
                  if (provider.appMode == AppMode.hamilleKalma) ...[
                    const FertilityPrepCard(),
                    const SizedBox(height: 12),
                    const PregnancySymptomsCard(),
                    const SizedBox(height: 24),
                    // Alternatif tedavi seçenekleri başlığı
                    Row(children: [
                      Expanded(
                        child: Divider(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Doğal Yolla Olmazsa',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7C3AED)
                                .withValues(alpha: 0.6),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                          thickness: 1,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    const IUIInfoCard(),
                    const SizedBox(height: 12),
                    const IVFInfoCard(),
                    const SizedBox(height: 20),
                  ],
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