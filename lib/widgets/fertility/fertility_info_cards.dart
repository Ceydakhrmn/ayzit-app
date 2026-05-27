// =============================================
// widgets/fertility/fertility_info_cards.dart
//
// Hamile kalma modunda takvim ekranında gösterilen
// iki bilgi kartı:
//   1. FertilityPrepCard  → "Gebeliğe Hazırlık Nedir?"
//   2. PregnancySymptomsCard → "Hamilelik Belirtileri"
//
// Her kart: özet metin + "Detaylı Bilgi" butonu
// Buton → DraggableScrollableSheet ile tam makale
// =============================================

import 'package:flutter/material.dart';

const _purple = Color(0xFF7C3AED);
const _green  = Color(0xFF059669);
const _rose   = Color(0xFFE11D48);

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC API
// ─────────────────────────────────────────────────────────────────────────────

class FertilityPrepCard extends StatelessWidget {
  const FertilityPrepCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      emoji: '🌱',
      title: 'Gebeliğe Hazırlık',
      subtitle: 'Sağlıklı gebelik için 3 ay önceden başlayın',
      summary: 'Folik asit takviyesi, sağlık kontrolü, beslenme ve yaşam tarzı '
          'değişiklikleri ile sağlıklı bir gebeliğe hazırlanın.',
      accentColor: _green,
      onDetail: () => _openSheet(context, const _FertilityPrepSheet()),
    );
  }
}

class PregnancySymptomsCard extends StatelessWidget {
  const PregnancySymptomsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      emoji: '🤰',
      title: 'Hamilelik Belirtileri',
      subtitle: 'Erken belirtiler ve tanı yöntemleri',
      summary: 'Adet gecikmesi, meme hassasiyeti, bulantı ve daha fazlası. '
          'Ne zaman test yapmalı, ne zaman doktora gidilmeli?',
      accentColor: _rose,
      onDetail: () => _openSheet(context, const _PregnancySymptomsSheet()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ortak kart iskeleti
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String summary;
  final Color accentColor;
  final VoidCallback onDetail;

  const _InfoCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.accentColor,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.07 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık satırı ─────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor.withValues(alpha: isDark ? 0.8 : 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Özet metin ────────────────────────────────────────────────
          Text(
            summary,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          // ── Detaylı Bilgi butonu ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDetail,
              icon: const Icon(Icons.menu_book_outlined, size: 15),
              label: const Text('Detaylı Bilgi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.45)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet: Gebeliğe Hazırlık Nedir?
// ─────────────────────────────────────────────────────────────────────────────

class _FertilityPrepSheet extends StatelessWidget {
  const _FertilityPrepSheet();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      children: [
        _dragHandle(context),
        // Başlık
        Row(children: [
          const Text('🌱', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Gebeliğe Hazırlık Nedir?',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _green),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _para(context,
            'Gebeliğe hazırlık, anne ve baba adayları için heyecan verici bir süreçtir. '
            'Dünya Sağlık Örgütü (DSÖ) ve Amerikan Kadın Doğum Derneği (ACOG), '
            'gebelik planlayan çiftlerin en az 3 ay önceden hazırlıklara başlamasını '
            'önermektedir. Bu hazırlık süreci, anne adayının hem bedensel hem de ruhsal '
            'sağlığını güçlendirmeyi ve bebeğin sağlıklı gelişimini desteklemeyi amaçlar.'),

        _secTitle('🏥 Sağlık Kontrolü', _green),
        _bullet(context, 'Kan testleri: Kan sayımı, kan şekeri, tiroid fonksiyonları, vitamin düzeyleri (özellikle D vitamini, B12, folik asit).'),
        _bullet(context, 'Bulaşıcı hastalık taraması: Hepatit B, C, HIV, sifiliz, kızamıkçık bağışıklığı.'),
        _bullet(context, 'Smear testi: Rahim ağzı sağlığı için.'),
        _bullet(context, 'Aşılar: Kızamıkçık, suçiçeği, hepatit B — eksikse gebelikten önce tamamlanmalı.'),

        _secTitle('💊 Folik Asit ve Vitamin Takviyeleri', _green),
        _bullet(context, 'Folik asit: Gebelikten en az 1 ay önce başlanmalı. Günde 400–800 mcg önerilir. Nöral tüp defekti riskini %70\'e kadar azaltır.'),
        _bullet(context, 'D vitamini: Eksikse takviye edilmelidir.'),
        _bullet(context, 'Demir: Kansızlık varsa tedavi edilmeli.'),
        _bullet(context, 'Omega-3 (DHA): Bebeğin beyin ve göz gelişimini destekler.'),

        _secTitle('🩺 Kronik Hastalıkların Kontrolü', _green),
        _bullet(context, 'Diyabet: Kan şekeri normal sınırlara çekilmeli (HbA1c <%6,5 önerilir).'),
        _bullet(context, 'Tansiyon: İyi kontrol altında olmalı. Gebelikte güvenli ilaçlara geçilmeli.'),
        _bullet(context, 'Tiroid hastalıkları: TSH değerleri gebelik için uygun aralıkta olmalı.'),
        _bullet(context, 'Epilepsi, romatizmal hastalıklar: Kullanılan ilaçların gebelikte güvenli olup olmadığı kontrol edilmeli.'),

        _secTitle('💊 İlaç Kullanımı', _green),
        _para(context,
            'Gebelik planlayan kadınlar mutlaka mevcut ilaçlarını doktoruna söylemelidir. '
            'Bazı ilaçlar doğumsal anomali riskini artırabilir ve gebelikten önce '
            'değiştirilmesi gerekebilir.'),

        _secTitle('🥗 Beslenme', _green),
        _bullet(context, 'Sebze, meyve, tam tahıl, sağlıklı yağlar tercih edilmeli.'),
        _bullet(context, 'Fast food, aşırı şeker ve işlenmiş gıdalardan uzak durulmalı.'),
        _bullet(context, 'Kafein: Günde 1–2 fincan kahve (200 mg) ile sınırlandırılmalı.'),
        _bullet(context, 'Alkol ve sigara: Kesinlikle bırakılmalı.'),

        _secTitle('⚖️ Kilo Kontrolü', _green),
        _bullet(context, 'BMI 18,5–24,9: Normal'),
        _bullet(context, 'BMI >30 (Obezite): Gebelik diyabeti, hipertansiyon ve sezaryen riski artar.'),
        _bullet(context, 'BMI <18,5 (Düşük kilo): Düşük doğum ağırlığı riski.'),

        _secTitle('🏃 Yaşam Tarzı', _green),
        _bullet(context, 'Sigara: Düşük, erken doğum ve bebekte gelişme geriliği riskini artırır. Bırakılmalıdır.'),
        _bullet(context, 'Alkol: Güvenli bir miktarı yoktur, tamamen bırakılmalıdır.'),
        _bullet(context, 'Egzersiz: Haftada en az 150 dakika yürüyüş veya hafif egzersiz önerilir.'),
        _bullet(context, 'Uyku düzeni: Günde 7–8 saat uyumak bağışıklık ve hormon dengesi için önemlidir.'),

        _secTitle('🧠 Ruhsal Sağlık', _green),
        _para(context,
            'Gebelik sadece bedensel değil, ruhsal olarak da hazırlık gerektirir. '
            'Depresyon, anksiyete gibi durumlar gebelik öncesinde tedavi edilmelidir. '
            'Destekleyici bir sosyal çevre ve stres yönetimi çok önemlidir.'),

        _secTitle('👨 Baba Adayı İçin Hazırlık', _green),
        _bullet(context, 'Sigara ve alkolü bırakmalı.'),
        _bullet(context, 'Düzenli egzersiz yapmalı.'),
        _bullet(context, 'Sağlıklı beslenmeli (özellikle çinko, selenyum ve vitaminlerden zengin).'),
        _bullet(context, 'Gerekirse sperm analizi yaptırmalı.'),

        _secTitle('🧪 Gebelik Öncesi Testler ve Aşılar', _green),
        _bullet(context, 'Kan grubu ve Rh faktörü'),
        _bullet(context, 'Rubella (kızamıkçık) bağışıklığı'),
        _bullet(context, 'Hepatit B yüzey antijeni'),
        _bullet(context, 'Tam idrar tetkiki & Tam kan sayımı'),
        _bullet(context, 'Eksikse: kızamıkçık, suçiçeği, hepatit B aşıları'),

        _secTitle('❓ Sık Sorulan Sorular', _green),
        _qa(context,
            'Gebelik öncesi hangi vitaminler şarttır?',
            'En önemlisi folik asittir. D vitamini ve demir eksikliği varsa takviye yapılır.'),
        _qa(context,
            'Gebelikten önce sigara bırakılmazsa ne olur?',
            'Düşük, erken doğum ve bebekte gelişim sorunları riski artar.'),
        _qa(context,
            'Baba adayının sigara içmesi gebeliği etkiler mi?',
            'Evet. Sigara spermlerin kalitesini bozar ve döllenme şansını azaltır.'),
        _qa(context,
            'Gebelik öncesi ideal kilo neden önemli?',
            'Hem düşük hem de yüksek kilo, gebelikte komplikasyon riskini artırır.'),
        _qa(context,
            'Kaç ay önceden hazırlık yapılmalı?',
            'En az 3 ay önceden folik asit başlanmalı ve sağlık kontrolleri yapılmalıdır.'),

        const SizedBox(height: 8),
        _para(context,
            'Gebeliğe hazırlık, sağlıklı bir anne ve bebek için kritik öneme sahiptir. '
            'Düzenli sağlık kontrolü, beslenme düzeni, yaşam tarzı değişiklikleri ve vitamin '
            'desteği bu sürecin temel taşlarıdır.'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet: Hamilelik Belirtileri
// ─────────────────────────────────────────────────────────────────────────────

class _PregnancySymptomsSheet extends StatelessWidget {
  const _PregnancySymptomsSheet();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      children: [
        _dragHandle(context),
        // Başlık
        Row(children: [
          const Text('🤰', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hamilelik Belirtileri',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _rose),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _para(context,
            '"Acaba hamile miyim?" sorusu akla ilk düştüğünde genellikle bazı işaretler '
            'aranır. Hem erken dönemde görülen belirtileri hem de doktor kontrolünde '
            'ultrasonla saptanan bulguları aşağıda bulabilirsiniz.'),

        _secTitle('📋 Erken Hamilelik Belirtileri', _rose),
        _symptomItem(context, '📅', 'Adet Gecikmesi',
            'Hamileliğin en sık fark edilen ilk belirtisidir. Ancak stres, ani kilo '
            'değişimi ya da hormonal dengesizlikler de adet gecikmesine yol açabilir. '
            'Tek başına yeterli değildir, test yapmak gerekir.'),
        _symptomItem(context, '🤱', 'Meme Hassasiyeti ve Dolgunluk',
            'Göğüslerde şişlik, dolgunluk, meme uçlarında hassasiyet ve koyulaşma '
            'görülebilir. Bu durum hormonların artışından kaynaklanır.'),
        _symptomItem(context, '🤢', 'Bulantı ve Kusma (Sabah Bulantısı)',
            'Genellikle gebeliğin 6. haftasından sonra başlar. Çoğunlukla sabahları '
            'belirgindir ama günün her saatinde olabilir. Şiddetli, sürekli kusma varsa '
            'mutlaka doktora başvurmak gerekir.'),
        _symptomItem(context, '😴', 'Yorgunluk ve Uyku Hali',
            'Gebelik hormonlarının etkisiyle anne adayları kendilerini sık sık yorgun '
            'hissedebilir. Özellikle ilk üç ayda çok yaygındır.'),
        _symptomItem(context, '🚽', 'Sık İdrara Çıkma',
            'Hem hormonların etkisi hem de büyüyen rahmin idrar torbasına baskı yapması '
            'nedeniyle idrara çıkma sıklığı artabilir.'),
        _symptomItem(context, '👃', 'Koku ve Tat Değişiklikleri',
            'Bazı anne adayları eskiden sevdiği yemekleri tolere edemeyebilir. Bazı '
            'kokulara aşırı hassasiyet gösterebilir. Bu durum da tamamen normaldir.'),
        _symptomItem(context, '💧', 'Akıntı Artışı',
            'Hormonlara bağlı olarak vajinal akıntı artışı görülebilir. Kötü kokulu, '
            'renkli veya kaşıntılı akıntılar enfeksiyon belirtisi olabilir, mutlaka '
            'doktora danışılmalıdır.'),

        _secTitle('🔍 Daha Az Bilinen Belirtiler', _rose),
        _bullet(context,
            'Duygu Durum Değişiklikleri: Hormonlardaki dalgalanma nedeniyle ani sinirlilik, ağlama isteği ya da huzursuzluk olabilir.'),
        _bullet(context,
            'İmplantasyon Kanaması: Döllenmiş yumurta rahme tutunurken hafif lekelenme tarzında kanama görülebilir. Genellikle pembe ya da kahverengi, kısa süreli olur.'),

        _secTitle('🧪 Gebelik Testleri', _rose),
        _bullet(context,
            'Evde İdrar Testi: İdrarda hCG hormonunu ölçer. En güvenilir sonuç adet gecikmesinin ilk gününden itibaren alınır. Çok erken yapılırsa negatif çıkabilir.'),
        _bullet(context,
            'Kanda Gebelik Testi: Daha duyarlı ve kesin sonuç verir. İdrar testi negatif çıksa bile şüphe varsa doktor kan testiyle netlik sağlar.'),

        _secTitle('🔬 Ultrasonda Hamilelik İşaretleri', _rose),
        _bullet(context,
            'Gestasyonel kese (gebelik kesesi): Genellikle 5. haftadan itibaren vajinal ultrasonla rahim içinde görülür.'),
        _bullet(context,
            'Yolk kesesi: 5.–6. haftalarda, gebeliğin normal seyrettiğini gösteren küçük halka şeklinde yapıdır.'),
        _bullet(context,
            'Embriyo ve kalp atımı: 6.–7. haftalarda görülebilir. Kalp atışı duyulması gebeliğin sağlıklı ilerlediğinin en güçlü işaretidir.'),
        _bullet(context,
            'İlerleyen haftalarda: Bebeğin baş-popo uzunluğu (CRL), hareketleri ve organ gelişimi takip edilir.'),

        _secTitle('⚠️ Hamilelik Belirtileriyle Karışabilen Durumlar', _rose),
        _bullet(context,
            'Adet öncesi sendromu: Meme hassasiyeti, karın şişliği ve duygu değişiklikleri gebeliğe çok benzer.'),
        _bullet(context,
            'Stres, beslenme bozuklukları, hormonal dengesizlikler: Adet gecikmesi yapabilir.'),
        _bullet(context,
            'Mide-bağırsak sorunları: Bulantı ve kusma yapabilir.'),

        _secTitle('🚨 Ne Zaman Doktora Başvurmalı?', _rose),
        _bullet(context, 'Şiddetli karın ağrısı'),
        _bullet(context, 'Yoğun ya da artan vajinal kanama'),
        _bullet(context, 'Bayılma, baş dönmesi'),
        _bullet(context, 'Aşırı kusma, kilo kaybı, idrar yapamama'),
        _bullet(context, 'Ateş ve kötü kokulu akıntı'),
        const SizedBox(height: 8),
        _para(context,
            'Bu durumlar acil değerlendirme gerektirir. Özellikle dış gebelik veya düşük '
            'riski olabilir.'),
        const SizedBox(height: 8),
        _para(context,
            'Hamilelik belirtileri anne adayına ilk ipuçlarını verse de, kesin tanı için '
            '"test" ve "ultrason" gereklidir. Belirtiler kadından kadına değişebilir; hatta '
            'bazı gebeliklerde hiçbir belirti olmayabilir. En güvenilir yaklaşım, adet '
            'geciktiğinde test yapmak ve sonucunu doktorla değerlendirmektir.'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Yardımcı widget builder'lar (private)
// ─────────────────────────────────────────────────────────────────────────────

void _openSheet(BuildContext context, Widget sheet) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: sheet,
      ),
    ),
  );
}

Widget _dragHandle(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Widget _secTitle(String title, Color color) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
      ),
    );

Widget _para(BuildContext context, String text) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.6,
        color: cs.onSurface.withValues(alpha: 0.8),
      ),
    ),
  );
}

Widget _bullet(BuildContext context, String text) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _purple,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _qa(BuildContext context, String q, String a) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '❓ $q',
          style: const TextStyle(
              fontSize: 13.5, fontWeight: FontWeight.w700, color: _green),
        ),
        const SizedBox(height: 3),
        Text(
          a,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: cs.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ],
    ),
  );
}

Widget _symptomItem(
    BuildContext context, String emoji, String title, String desc) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
