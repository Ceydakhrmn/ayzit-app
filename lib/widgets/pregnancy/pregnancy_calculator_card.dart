// =============================================
// widgets/pregnancy/pregnancy_calculator_card.dart
//
// SAT'a göre gebelik haftası + tahmini doğum tarihi hesaplayıcı.
// Detaylı bilgi butonu → tam kapsamlı bilgi sayfası (bottom sheet).
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cycle_provider.dart';
import '../../data/pregnancy_data.dart';

class PregnancyCalculatorCard extends StatefulWidget {
  const PregnancyCalculatorCard({super.key});

  @override
  State<PregnancyCalculatorCard> createState() =>
      _PregnancyCalculatorCardState();
}

class _PregnancyCalculatorCardState extends State<PregnancyCalculatorCard> {
  DateTime? _sat;
  int _cycleLength = 28;

  bool _calculated = false;
  DateTime? _dueDate;
  int? _week;
  String? _monthLabel;

  static const _purple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lmp = context.read<CycleProvider>().pregnancyStartDate;
      if (lmp != null) {
        setState(() {
          _sat = lmp;
          _calculate();
        });
      }
    });
  }

  void _calculate() {
    if (_sat == null) return;
    final cycleDiff = _cycleLength - 28;
    final due = _sat!.add(Duration(days: 280 + cycleDiff));
    final days = DateTime.now().difference(_sat!).inDays;
    final week = (days ~/ 7) + 1;
    setState(() {
      _dueDate = due;
      _week = week.clamp(1, 42);
      _monthLabel = _weekToMonthLabel(week.clamp(1, 40));
      _calculated = true;
    });
  }

  static String _weekToMonthLabel(int week) {
    final month = week ~/ 4;
    final rem = week % 4;
    if (rem == 0) return '$month aylık hamilesiniz';
    if (month == 0) return '0 ay $rem haftalık hamilesiniz';
    return '$month ay $rem haftalık hamilesiniz';
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sat ?? DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Son Adet Tarihi',
    );
    if (picked != null) setState(() => _sat = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2A2440) : const Color(0xFFF3EFFB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık ─────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: _purple),
              ),
              const SizedBox(width: 6),
              const Text(
                'GEBELİK HESAPLAMA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── SAT seçici ─────────────────────────────────────────────
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _purple.withValues(alpha: 0.22), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: _purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _sat != null
                          ? 'Son Adet Tarihi: ${_formatDate(_sat!)}'
                          : 'Son Adet Tarihi seç',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _sat != null
                            ? cs.onSurface
                            : cs.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down,
                      color: cs.onSurface.withValues(alpha: 0.4)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Döngü uzunluğu ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Döngü uzunluğu: $_cycleLength gün',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
              _CycleButton(
                label: '−',
                enabled: _cycleLength > 20,
                onTap: () => setState(() => _cycleLength--),
              ),
              const SizedBox(width: 8),
              _CycleButton(
                label: '+',
                enabled: _cycleLength < 45,
                onTap: () => setState(() => _cycleLength++),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Daha uzun döngülerde tahmini doğum tarihi birkaç gün öteye kayar.',
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurface.withValues(alpha: 0.45),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 14),

          // ── Hesapla butonu ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _sat != null ? _calculate : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _purple,
                    disabledBackgroundColor:
                        _purple.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Hesapla',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              if (_calculated) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => setState(() {
                    _calculated = false;
                    _sat = null;
                    _cycleLength = 28;
                  }),
                  child: Text(
                    'Sıfırla',
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 13),
                  ),
                ),
              ],
            ],
          ),

          // ── Sonuçlar ───────────────────────────────────────────────
          if (_calculated && _dueDate != null) ...[
            const SizedBox(height: 16),
            Divider(
                height: 1,
                color: cs.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 14),
            _ResultRow(
              icon: Icons.pregnant_woman_outlined,
              label: 'Gebelik Haftası',
              value: '$_week. hafta',
              color: _purple,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              icon: Icons.event_available_outlined,
              label: 'Tahmini Doğum',
              value: _formatDate(_dueDate!),
              color: const Color(0xFF0891B2),
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              icon: Icons.timeline_outlined,
              label: 'Ay Bilgisi',
              value: _monthLabel ?? '',
              color: const Color(0xFF059669),
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            // ── Burç ────────────────────────────────────────────
            Builder(builder: (_) {
              final zodiac = zodiacForDate(_dueDate!);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF2D1B69),
                            const Color(0xFF1E1040)
                          ]
                        : [
                            const Color(0xFFEDE9FE),
                            const Color(0xFFF5F3FF)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          _purple.withValues(alpha: isDark ? 0.35 : 0.2)),
                ),
                child: Row(
                  children: [
                    Text(zodiac.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bebeğinin Burcu',
                            style: TextStyle(
                              fontSize: 11,
                              color: _purple.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            '${zodiac.name} · ${zodiac.dateRange}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 14),
          Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.08)),
          const SizedBox(height: 12),

          // ── Detaylı bilgi butonu ───────────────────────────────────
          GestureDetector(
            onTap: () => _openInfoSheet(context, isDark),
            child: Row(
              children: [
                const Text('📖', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'Gebelik hesaplama hakkında detaylı bilgi',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color:
                        _purple.withValues(alpha: isDark ? 0.9 : 1.0),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right,
                    size: 16,
                    color: _purple.withValues(
                        alpha: isDark ? 0.9 : 1.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openInfoSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.95,
        builder: (_, sc) =>
            _InfoSheetContent(scrollController: sc, isDark: isDark),
      ),
    );
  }
}

// ── Döngü +/− butonu ────────────────────────────────────────────────────
class _CycleButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _CycleButton(
      {required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? const Color(0xFF7C3AED).withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(
            color: enabled
                ? const Color(0xFF7C3AED).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: enabled
                ? const Color(0xFF7C3AED)
                : Colors.grey.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

// ── Sonuç satırı ────────────────────────────────────────────────────────
class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Detaylı Bilgi Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════
class _InfoSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final bool isDark;
  const _InfoSheetContent(
      {required this.scrollController, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          const Text(
            'Gebelik Haftası Hesaplama',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Tıpta gebelik süresi ortalama 40 hafta (280 gün) olarak kabul edilir.',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),

          // ── Hesaplama Yöntemleri ────────────────────────────────────
          _SectionTitle(text: 'Hesaplama Yöntemleri', isDark: isDark),
          const SizedBox(height: 10),
          _InfoCard(
            isDark: isDark,
            color: const Color(0xFF7C3AED),
            title: '1. Son Adet Tarihine (SAT) Göre',
            body:
                'Gebelik, son adet tarihinin ilk günü üzerinden hesaplanır. Döllenme genellikle bu tarihten ~2 hafta sonra gerçekleşir. Tüm dünyada standart başlangıç noktası SAT\'tır.\n\n'
                'Naegele formülü: SAT\'a 7 gün ekle → 3 ay geri git → 1 yıl ekle.\n\n'
                'Örnek: SAT = 10 Ocak 2025 → 17 Ocak → 17 Ekim → 17 Ekim 2025',
          ),
          const SizedBox(height: 8),
          _InfoCard(
            isDark: isDark,
            color: const Color(0xFF0891B2),
            title: '2. Ultrason Ölçümlerine Göre',
            body:
                'İlk 3 ayda yapılan ultrason en doğru yöntemdir. Baş-popo mesafesi (CRL) ile bebeğin yaşı belirlenir.\n\n'
                '• 5–6. hafta: Gebelik kesesi çapı (MSD)\n'
                '• 6–12. hafta: CRL ölçümü (%95 doğruluk, ±0,5 hafta)\n'
                '• 2.–3. trimester: BPD, HC, AC, FL ölçümleri',
          ),
          const SizedBox(height: 8),
          _InfoCard(
            isDark: isDark,
            color: const Color(0xFF059669),
            title: '3. Tüp Bebek / Embriyo Transferi',
            body:
                'Transfer tarihi bilindiğinden gebelik haftası çok net hesaplanır.\n\n'
                '• 3. gün embriyo: Transfer tarihi + 17 gün\n'
                '• 5. gün embriyo: Transfer tarihi + 19 gün',
          ),

          const SizedBox(height: 24),

          // ── Hafta / Ay Tablosu ─────────────────────────────────────
          _SectionTitle(text: 'Kaç Hafta = Kaç Aylık?', isDark: isDark),
          const SizedBox(height: 10),
          _WeekMonthTable(isDark: isDark),

          const SizedBox(height: 24),

          // ── Trimesterlar ───────────────────────────────────────────
          _SectionTitle(text: 'Trimesterlar', isDark: isDark),
          const SizedBox(height: 10),
          _TrimesterRow(
            number: '1',
            range: '0–13. hafta',
            desc: 'Bebeğin organ gelişiminin başladığı dönem.',
            color: const Color(0xFF7C3AED),
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _TrimesterRow(
            number: '2',
            range: '14–27. hafta',
            desc: 'Anne için daha rahat dönem; bebek hareketleri hissedilir.',
            color: const Color(0xFF0891B2),
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _TrimesterRow(
            number: '3',
            range: '28–40. hafta',
            desc: 'Bebeğin büyüme ve doğuma hazırlık dönemi.',
            color: const Color(0xFF059669),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // ── Önemli Testler ─────────────────────────────────────────
          _SectionTitle(text: 'Gebelikte Önemli Testler', isDark: isDark),
          const SizedBox(height: 10),
          _TestsTable(isDark: isDark),

          const SizedBox(height: 24),

          // ── B-HCG ──────────────────────────────────────────────────
          _SectionTitle(text: 'Beta-HCG Değerleri', isDark: isDark),
          const SizedBox(height: 6),
          Text(
            'B-HCG kanda her 48–72 saatte bir ikiye katlanır. 25 mIU/mL ve üzeri pozitif kabul edilir.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          _HcgTable(isDark: isDark),

          const SizedBox(height: 24),

          // ── Doğum Zamanı ───────────────────────────────────────────
          _SectionTitle(text: 'Doğum Zamanı', isDark: isDark),
          const SizedBox(height: 8),
          _InfoCard(
            isDark: isDark,
            color: const Color(0xFFEC4899),
            title: 'Tahmini Doğum Tarihi',
            body:
                'Bebeklerin yalnızca %4–5\'i tam olarak tahmini tarihte doğar. '
                'Çoğu doğum 38–42. haftalar arasında gerçekleşir.\n\n'
                '• Erken doğum: 37. haftadan önce\n'
                '• Zamanında doğum: 37–42. haftalar arası\n'
                '• Geç doğum: 42. haftadan sonra',
          ),

          const SizedBox(height: 24),

          // ── SSS ────────────────────────────────────────────────────
          _SectionTitle(text: 'Sık Sorulan Sorular', isDark: isDark),
          const SizedBox(height: 10),
          ..._faqItems.map((faq) => _FaqTile(
                question: faq[0],
                answer: faq[1],
                isDark: isDark,
              )),

          const SizedBox(height: 16),
          Center(
            child: Text(
              '© 2026 Gebelik Hesaplama · Klinik karar yerine geçmez.',
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.35),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SSS verileri ─────────────────────────────────────────────────────────
const _faqItems = [
  [
    'En doğru hesaplama yöntemi hangisi?',
    'İlk trimester ultrasonu (CRL ölçümü) en güvenilir yöntemdir. ±0,5 hafta doğrulukla sonuç verir.',
  ],
  [
    'Doğum gerçekten tahmini tarihte olur mu?',
    'Hayır; çoğu kadın tahmini doğum tarihinden 1–2 hafta önce veya sonra doğum yapar. Tahmini tarih sadece bir rehberdir.',
  ],
  [
    'Adet düzensizliğimde nasıl hesaplanır?',
    'Ultrason ölçümleri ve embriyo gelişim parametreleri esas alınır. SAT\'a dayalı hesaplama yanıltıcı olabilir.',
  ],
  [
    'Gebelik neden 9 ay değil 40 hafta denir?',
    'Gebelik SAT\'tan hesaplanır ve bu yaklaşık 280 gün (40 hafta) eder. Takvim ayı ise 4 haftadan biraz uzundur.',
  ],
  [
    'Gebelik uygulamaları güvenilir mi?',
    'Pratik fikir verir; ancak kesin tanı ve takip için mutlaka kadın doğum uzmanına danışılmalıdır.',
  ],
];

// ══════════════════════════════════════════════════════════════════════════
// Yardımcı widgetlar
// ══════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionTitle({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final Color color;
  final String title;
  final String body;
  const _InfoCard({
    required this.isDark,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.55,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrimesterRow extends StatelessWidget {
  final String number;
  final String range;
  final String desc;
  final Color color;
  final bool isDark;
  const _TrimesterRow({
    required this.number,
    required this.range,
    required this.desc,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  range,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isDark;
  const _FaqTile(
      {required this.question, required this.answer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconColor: const Color(0xFF7C3AED),
          collapsedIconColor: const Color(0xFF7C3AED),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                color: cs.onSurface.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hafta / Ay tablosu ───────────────────────────────────────────────────
class _WeekMonthTable extends StatelessWidget {
  final bool isDark;
  const _WeekMonthTable({required this.isDark});

  static const _rows = [
    ['1–3. hafta', '0 ay 1–3 haftalık'],
    ['4. hafta', '1 aylık'],
    ['5–7. hafta', '1 ay 1–3 haftalık'],
    ['8. hafta', '2 aylık'],
    ['9–11. hafta', '2 ay 1–3 haftalık'],
    ['12. hafta', '3 aylık'],
    ['13–15. hafta', '3 ay 1–3 haftalık'],
    ['16. hafta', '4 aylık'],
    ['17–19. hafta', '4 ay 1–3 haftalık'],
    ['20. hafta', '5 aylık'],
    ['21–23. hafta', '5 ay 1–3 haftalık'],
    ['24. hafta', '6 aylık'],
    ['25–27. hafta', '6 ay 1–3 haftalık'],
    ['28. hafta', '7 aylık'],
    ['29–31. hafta', '7 ay 1–3 haftalık'],
    ['32. hafta', '8 aylık'],
    ['33–35. hafta', '8 ay 1–3 haftalık'],
    ['36. hafta', '9 aylık'],
    ['37–39. hafta', '9 ay 1–3 haftalık'],
    ['40. hafta', '10 aylık'],
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.6),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
            ),
            children: [
              _TableCell(text: 'Gebelik Haftası', isHeader: true),
              _TableCell(text: 'Kaç Aylık?', isHeader: true),
            ],
          ),
          ..._rows.asMap().entries.map((e) => TableRow(
                decoration: BoxDecoration(
                  color: e.key % 2 == 0
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
                children: [
                  _TableCell(text: e.value[0]),
                  _TableCell(text: e.value[1]),
                ],
              )),
        ],
      ),
    );
  }
}

// ── B-HCG tablosu ─────────────────────────────────────────────────────────
class _HcgTable extends StatelessWidget {
  final bool isDark;
  const _HcgTable({required this.isDark});

  static const _rows = [
    ['3. hafta', '5 – 50'],
    ['4. hafta', '5 – 426'],
    ['5. hafta', '18 – 7.340'],
    ['6. hafta', '1.080 – 56.500'],
    ['7–8. hafta', '7.650 – 229.000'],
    ['9–12. hafta', '25.700 – 288.000'],
    ['13–16. hafta', '13.300 – 254.000'],
    ['17–24. hafta', '4.060 – 165.400'],
    ['25–40. hafta', '3.640 – 117.000'],
    ['Gebe olmayan', '< 5'],
    ['Gebe kadın', '> 25'],
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.4),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withValues(alpha: 0.15),
            ),
            children: [
              _TableCell(text: 'Hamilelik Haftası', isHeader: true),
              _TableCell(text: 'B-HCG (mIU/mL)', isHeader: true),
            ],
          ),
          ..._rows.asMap().entries.map((e) => TableRow(
                decoration: BoxDecoration(
                  color: e.key % 2 == 0
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
                children: [
                  _TableCell(text: e.value[0]),
                  _TableCell(text: e.value[1]),
                ],
              )),
        ],
      ),
    );
  }
}

// ── Testler tablosu ─────────────────────────────────────────────────────
class _TestsTable extends StatelessWidget {
  final bool isDark;
  const _TestsTable({required this.isDark});

  static const _rows = [
    ['6–10. hafta', 'İlk ultrason (canlılık, CRL)'],
    ['6–12. hafta', 'Kan grubu, Rh, CBC, HIV, HBsAg, HCV, VDRL, TSH'],
    ['10–13. hafta', 'NIPT / CVS (gerektiğinde)'],
    ['11–14. hafta', 'İkili tarama (PAPP-A, NT ölçümü)'],
    ['15–18. hafta', 'Üçlü/Dörtlü tarama'],
    ['15–20. hafta', 'Amniyosentez (gerektiğinde)'],
    ['18–22. hafta', 'Detaylı ultrason (anomali taraması)'],
    ['20–24. hafta', 'Fetal eko (gerektiğinde)'],
    ['24–28. hafta', 'OGTT (şeker yükleme), 2. CBC'],
    ['28. hafta', 'Anti-D (Rh(-) annelerde)'],
    ['32–38. hafta', 'Fetal biyometri, 3. trimester USG'],
    ['35–37. hafta', 'GBS kültürü (gerektiğinde)'],
    ['36. haftadan itibaren', 'NST (non-stres test)'],
    ['≥ 37. hafta', 'Pelvik değerlendirme'],
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.15),
            ),
            children: [
              _TableCell(text: 'Hafta', isHeader: true),
              _TableCell(text: 'Test / İşlem', isHeader: true),
            ],
          ),
          ..._rows.asMap().entries.map((e) => TableRow(
                decoration: BoxDecoration(
                  color: e.key % 2 == 0
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
                children: [
                  _TableCell(text: e.value[0]),
                  _TableCell(text: e.value[1]),
                ],
              )),
        ],
      ),
    );
  }
}

// ── Tablo hücresi ─────────────────────────────────────────────────────────
class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _TableCell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.w400,
          color: isHeader ? cs.onSurface : cs.onSurface.withValues(alpha: 0.8),
          height: 1.4,
        ),
      ),
    );
  }
}
