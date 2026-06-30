// =============================================
// widgets/fertility/fertility_info_cards.dart
//
// Hamile kalma modunda takvim ekranında gösterilen
// dört bilgi kartı:
//   1. FertilityPrepCard      → "Gebeliğe Hazırlık Nedir?"
//   2. PregnancySymptomsCard  → "Hamilelik Belirtileri"
//   3. IUIInfoCard            → "Aşılama Tedavisi (IUI)"
//   4. IVFInfoCard            → "Tüp Bebek Tedavisi (IVF)"
//
// Her kart: özet metin + "Detaylı Bilgi" butonu
// Buton → DraggableScrollableSheet ile tam makale
// =============================================

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

const _purple = Color(0xFF7C3AED);
const _green  = Color(0xFF059669);
const _rose   = Color(0xFFE11D48);
const _blue   = Color(0xFF0369A1);

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC API
// ─────────────────────────────────────────────────────────────────────────────

class FertilityPrepCard extends StatelessWidget {
  const FertilityPrepCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InfoCard(
      emoji: '🌱',
      title: l10n.fertilityPrepTitle,
      subtitle: l10n.fertilityPrepSubtitle,
      summary: l10n.fertilityPrepSummary,
      accentColor: _green,
      onDetail: () => _openSheet(context, _FertilityPrepSheet(isEn: !l10n.isTurkish)),
    );
  }
}

class PregnancySymptomsCard extends StatelessWidget {
  const PregnancySymptomsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InfoCard(
      emoji: '🤰',
      title: l10n.pregnancySymptomsTitle,
      subtitle: l10n.pregnancySymptomsSubtitle,
      summary: l10n.pregnancySymptomsSummary,
      accentColor: _rose,
      onDetail: () => _openSheet(context, _PregnancySymptomsSheet(isEn: !l10n.isTurkish)),
    );
  }
}

class IUIInfoCard extends StatelessWidget {
  const IUIInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InfoCard(
      emoji: '🔬',
      title: l10n.iuiCardTitle,
      subtitle: l10n.iuiCardSubtitle,
      summary: l10n.iuiCardSummary,
      accentColor: _blue,
      onDetail: () => _openSheet(context, _IUISheet(isEn: !l10n.isTurkish)),
    );
  }
}

class IVFInfoCard extends StatelessWidget {
  const IVFInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _InfoCard(
      emoji: '🧬',
      title: l10n.ivfCardTitle,
      subtitle: l10n.ivfCardSubtitle,
      summary: l10n.ivfCardSummary,
      accentColor: _purple,
      onDetail: () => _openSheet(context, _IVFSheet(isEn: !l10n.isTurkish)),
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
              label: Text(AppLocalizations.of(context)?.detailInfoBtn2 ?? 'Detaylı Bilgi'),
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
// Sheet: Gebeliğe Hazırlık / Conception Preparation
// ─────────────────────────────────────────────────────────────────────────────

class _FertilityPrepSheet extends StatelessWidget {
  final bool isEn;
  const _FertilityPrepSheet({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      children: [
        _dragHandle(context),
        Row(children: [
          const Text('🌱', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEn ? 'What Is Conception Preparation?' : 'Gebeliğe Hazırlık Nedir?',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _green),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _para(context, isEn
            ? 'Preparing for pregnancy is an exciting journey for both partners. '
              'The WHO and ACOG recommend that couples planning a pregnancy start '
              'preparing at least 3 months in advance. This preparation aims to '
              'strengthen the mother-to-be physically and emotionally, and to '
              'support healthy fetal development.'
            : 'Gebeliğe hazırlık, anne ve baba adayları için heyecan verici bir süreçtir. '
              'Dünya Sağlık Örgütü (DSÖ) ve Amerikan Kadın Doğum Derneği (ACOG), '
              'gebelik planlayan çiftlerin en az 3 ay önceden hazırlıklara başlamasını '
              'önermektedir. Bu hazırlık süreci, anne adayının hem bedensel hem de ruhsal '
              'sağlığını güçlendirmeyi ve bebeğin sağlıklı gelişimini desteklemeyi amaçlar.'),

        _secTitle(isEn ? '🏥 Health Check' : '🏥 Sağlık Kontrolü', _green),
        _bullet(context, isEn
            ? 'Blood tests: Blood count, blood sugar, thyroid function, vitamin levels (especially vitamin D, B12, folic acid).'
            : 'Kan testleri: Kan sayımı, kan şekeri, tiroid fonksiyonları, vitamin düzeyleri (özellikle D vitamini, B12, folik asit).'),
        _bullet(context, isEn
            ? 'Infectious disease screening: Hepatitis B, C, HIV, syphilis, rubella immunity.'
            : 'Bulaşıcı hastalık taraması: Hepatit B, C, HIV, sifiliz, kızamıkçık bağışıklığı.'),
        _bullet(context, isEn
            ? 'Pap smear: For cervical health.'
            : 'Smear testi: Rahim ağzı sağlığı için.'),
        _bullet(context, isEn
            ? 'Vaccinations: Rubella, chickenpox, hepatitis B — complete before pregnancy if missing.'
            : 'Aşılar: Kızamıkçık, suçiçeği, hepatit B — eksikse gebelikten önce tamamlanmalı.'),

        _secTitle(isEn ? '💊 Folic Acid & Vitamin Supplements' : '💊 Folik Asit ve Vitamin Takviyeleri', _green),
        _bullet(context, isEn
            ? 'Folic acid: Start at least 1 month before pregnancy. 400–800 mcg daily recommended. Reduces neural tube defect risk by up to 70%.'
            : 'Folik asit: Gebelikten en az 1 ay önce başlanmalı. Günde 400–800 mcg önerilir. Nöral tüp defekti riskini %70\'e kadar azaltır.'),
        _bullet(context, isEn ? 'Vitamin D: Supplement if deficient.' : 'D vitamini: Eksikse takviye edilmelidir.'),
        _bullet(context, isEn ? 'Iron: Treat anemia if present.' : 'Demir: Kansızlık varsa tedavi edilmeli.'),
        _bullet(context, isEn
            ? 'Omega-3 (DHA): Supports baby\'s brain and eye development.'
            : 'Omega-3 (DHA): Bebeğin beyin ve göz gelişimini destekler.'),

        _secTitle(isEn ? '🩺 Managing Chronic Conditions' : '🩺 Kronik Hastalıkların Kontrolü', _green),
        _bullet(context, isEn
            ? 'Diabetes: Blood sugar should be normalized (HbA1c <6.5% recommended).'
            : 'Diyabet: Kan şekeri normal sınırlara çekilmeli (HbA1c <%6,5 önerilir).'),
        _bullet(context, isEn
            ? 'Blood pressure: Should be well-controlled. Switch to pregnancy-safe medications.'
            : 'Tansiyon: İyi kontrol altında olmalı. Gebelikte güvenli ilaçlara geçilmeli.'),
        _bullet(context, isEn
            ? 'Thyroid disorders: TSH levels should be in the range suitable for pregnancy.'
            : 'Tiroid hastalıkları: TSH değerleri gebelik için uygun aralıkta olmalı.'),
        _bullet(context, isEn
            ? 'Epilepsy, rheumatic diseases: Check whether current medications are safe during pregnancy.'
            : 'Epilepsi, romatizmal hastalıklar: Kullanılan ilaçların gebelikte güvenli olup olmadığı kontrol edilmeli.'),

        _secTitle(isEn ? '💊 Medication Use' : '💊 İlaç Kullanımı', _green),
        _para(context, isEn
            ? 'Women planning a pregnancy must inform their doctor about all current medications. '
              'Some drugs may increase the risk of birth defects and may need to be changed before pregnancy.'
            : 'Gebelik planlayan kadınlar mutlaka mevcut ilaçlarını doktoruna söylemelidir. '
              'Bazı ilaçlar doğumsal anomali riskini artırabilir ve gebelikten önce değiştirilmesi gerekebilir.'),

        _secTitle(isEn ? '🥗 Nutrition' : '🥗 Beslenme', _green),
        _bullet(context, isEn
            ? 'Prefer vegetables, fruits, whole grains, and healthy fats.'
            : 'Sebze, meyve, tam tahıl, sağlıklı yağlar tercih edilmeli.'),
        _bullet(context, isEn
            ? 'Avoid fast food, excess sugar, and processed foods.'
            : 'Fast food, aşırı şeker ve işlenmiş gıdalardan uzak durulmalı.'),
        _bullet(context, isEn
            ? 'Caffeine: Limit to 1–2 cups of coffee (200 mg) per day.'
            : 'Kafein: Günde 1–2 fincan kahve (200 mg) ile sınırlandırılmalı.'),
        _bullet(context, isEn
            ? 'Alcohol and smoking: Quit completely.'
            : 'Alkol ve sigara: Kesinlikle bırakılmalı.'),

        _secTitle(isEn ? '⚖️ Weight Management' : '⚖️ Kilo Kontrolü', _green),
        _bullet(context, isEn ? 'BMI 18.5–24.9: Normal' : 'BMI 18,5–24,9: Normal'),
        _bullet(context, isEn
            ? 'BMI >30 (Obesity): Increases risk of gestational diabetes, hypertension, and cesarean delivery.'
            : 'BMI >30 (Obezite): Gebelik diyabeti, hipertansiyon ve sezaryen riski artar.'),
        _bullet(context, isEn
            ? 'BMI <18.5 (Underweight): Risk of low birth weight.'
            : 'BMI <18,5 (Düşük kilo): Düşük doğum ağırlığı riski.'),

        _secTitle(isEn ? '🏃 Lifestyle' : '🏃 Yaşam Tarzı', _green),
        _bullet(context, isEn
            ? 'Smoking: Increases risk of miscarriage, preterm birth, and fetal growth restriction. Must quit.'
            : 'Sigara: Düşük, erken doğum ve bebekte gelişme geriliği riskini artırır. Bırakılmalıdır.'),
        _bullet(context, isEn
            ? 'Alcohol: No safe amount exists; quit completely.'
            : 'Alkol: Güvenli bir miktarı yoktur, tamamen bırakılmalıdır.'),
        _bullet(context, isEn
            ? 'Exercise: At least 150 minutes of walking or light exercise per week recommended.'
            : 'Egzersiz: Haftada en az 150 dakika yürüyüş veya hafif egzersiz önerilir.'),
        _bullet(context, isEn
            ? 'Sleep: 7–8 hours per day is important for immune function and hormonal balance.'
            : 'Uyku düzeni: Günde 7–8 saat uyumak bağışıklık ve hormon dengesi için önemlidir.'),

        _secTitle(isEn ? '🧠 Mental Health' : '🧠 Ruhsal Sağlık', _green),
        _para(context, isEn
            ? 'Pregnancy requires not only physical but also emotional preparation. '
              'Conditions like depression and anxiety should be treated before pregnancy. '
              'A supportive social network and stress management are very important.'
            : 'Gebelik sadece bedensel değil, ruhsal olarak da hazırlık gerektirir. '
              'Depresyon, anksiyete gibi durumlar gebelik öncesinde tedavi edilmelidir. '
              'Destekleyici bir sosyal çevre ve stres yönetimi çok önemlidir.'),

        _secTitle(isEn ? '👨 Preparation for the Father-to-Be' : '👨 Baba Adayı İçin Hazırlık', _green),
        _bullet(context, isEn ? 'Quit smoking and alcohol.' : 'Sigara ve alkolü bırakmalı.'),
        _bullet(context, isEn ? 'Exercise regularly.' : 'Düzenli egzersiz yapmalı.'),
        _bullet(context, isEn
            ? 'Eat healthily (especially foods rich in zinc, selenium, and vitamins).'
            : 'Sağlıklı beslenmeli (özellikle çinko, selenyum ve vitaminlerden zengin).'),
        _bullet(context, isEn ? 'Get a sperm analysis if needed.' : 'Gerekirse sperm analizi yaptırmalı.'),

        _secTitle(isEn ? '🧪 Pre-Conception Tests & Vaccines' : '🧪 Gebelik Öncesi Testler ve Aşılar', _green),
        _bullet(context, isEn ? 'Blood type and Rh factor' : 'Kan grubu ve Rh faktörü'),
        _bullet(context, isEn ? 'Rubella immunity' : 'Rubella (kızamıkçık) bağışıklığı'),
        _bullet(context, isEn ? 'Hepatitis B surface antigen' : 'Hepatit B yüzey antijeni'),
        _bullet(context, isEn ? 'Urinalysis & Complete blood count' : 'Tam idrar tetkiki & Tam kan sayımı'),
        _bullet(context, isEn
            ? 'If missing: rubella, chickenpox, hepatitis B vaccines'
            : 'Eksikse: kızamıkçık, suçiçeği, hepatit B aşıları'),

        _secTitle(isEn ? '❓ Frequently Asked Questions' : '❓ Sık Sorulan Sorular', _green),
        _qa(context,
            isEn ? 'Which vitamins are essential before pregnancy?' : 'Gebelik öncesi hangi vitaminler şarttır?',
            isEn ? 'The most important is folic acid. Supplement vitamin D and iron if deficient.'
                 : 'En önemlisi folik asittir. D vitamini ve demir eksikliği varsa takviye yapılır.'),
        _qa(context,
            isEn ? 'What happens if you don\'t quit smoking before pregnancy?' : 'Gebelikten önce sigara bırakılmazsa ne olur?',
            isEn ? 'Risk of miscarriage, preterm birth, and fetal growth problems increases.'
                 : 'Düşük, erken doğum ve bebekte gelişim sorunları riski artar.'),
        _qa(context,
            isEn ? 'Does the father-to-be smoking affect pregnancy?' : 'Baba adayının sigara içmesi gebeliği etkiler mi?',
            isEn ? 'Yes. Smoking impairs sperm quality and reduces the chance of fertilization.'
                 : 'Evet. Sigara spermlerin kalitesini bozar ve döllenme şansını azaltır.'),
        _qa(context,
            isEn ? 'Why is ideal weight important before pregnancy?' : 'Gebelik öncesi ideal kilo neden önemli?',
            isEn ? 'Both low and high weight increase the risk of complications during pregnancy.'
                 : 'Hem düşük hem de yüksek kilo, gebelikte komplikasyon riskini artırır.'),
        _qa(context,
            isEn ? 'How many months in advance should you prepare?' : 'Kaç ay önceden hazırlık yapılmalı?',
            isEn ? 'Folic acid should be started at least 3 months in advance and health checks should be done.'
                 : 'En az 3 ay önceden folik asit başlanmalı ve sağlık kontrolleri yapılmalıdır.'),

        const SizedBox(height: 8),
        _para(context, isEn
            ? 'Preparation for pregnancy is critically important for a healthy mother and baby. '
              'Regular health checks, balanced nutrition, lifestyle changes, and vitamin support '
              'are the cornerstones of this process.'
            : 'Gebeliğe hazırlık, sağlıklı bir anne ve bebek için kritik öneme sahiptir. '
              'Düzenli sağlık kontrolü, beslenme düzeni, yaşam tarzı değişiklikleri ve vitamin '
              'desteği bu sürecin temel taşlarıdır.'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet: Hamilelik Belirtileri / Pregnancy Symptoms
// ─────────────────────────────────────────────────────────────────────────────

class _PregnancySymptomsSheet extends StatelessWidget {
  final bool isEn;
  const _PregnancySymptomsSheet({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      children: [
        _dragHandle(context),
        Row(children: [
          const Text('🤰', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEn ? 'Pregnancy Symptoms' : 'Hamilelik Belirtileri',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _rose),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _para(context, isEn
            ? 'When the question "Am I pregnant?" first comes to mind, you often start looking '
              'for signs. Below you can find both symptoms seen early on and findings detected '
              'by ultrasound with a doctor\'s consultation.'
            : '"Acaba hamile miyim?" sorusu akla ilk düştüğünde genellikle bazı işaretler '
              'aranır. Hem erken dönemde görülen belirtileri hem de doktor kontrolünde '
              'ultrasonla saptanan bulguları aşağıda bulabilirsiniz.'),

        _secTitle(isEn ? '📋 Early Pregnancy Symptoms' : '📋 Erken Hamilelik Belirtileri', _rose),
        _symptomItem(context, '📅',
            isEn ? 'Missed Period' : 'Adet Gecikmesi',
            isEn ? 'The most commonly noticed first sign of pregnancy. However, stress, sudden '
                   'weight changes, or hormonal imbalances can also cause missed periods. '
                   'A test is still needed for confirmation.'
                 : 'Hamileliğin en sık fark edilen ilk belirtisidir. Ancak stres, ani kilo '
                   'değişimi ya da hormonal dengesizlikler de adet gecikmesine yol açabilir. '
                   'Tek başına yeterli değildir, test yapmak gerekir.'),
        _symptomItem(context, '🤱',
            isEn ? 'Breast Tenderness & Fullness' : 'Meme Hassasiyeti ve Dolgunluk',
            isEn ? 'Swelling, fullness, nipple tenderness, and darkening can occur. '
                   'This is caused by rising hormone levels.'
                 : 'Göğüslerde şişlik, dolgunluk, meme uçlarında hassasiyet ve koyulaşma '
                   'görülebilir. Bu durum hormonların artışından kaynaklanır.'),
        _symptomItem(context, '🤢',
            isEn ? 'Nausea & Vomiting (Morning Sickness)' : 'Bulantı ve Kusma (Sabah Bulantısı)',
            isEn ? 'Usually begins after week 6 of pregnancy. Most pronounced in the morning '
                   'but can occur at any time of day. If severe or persistent vomiting occurs, '
                   'see a doctor immediately.'
                 : 'Genellikle gebeliğin 6. haftasından sonra başlar. Çoğunlukla sabahları '
                   'belirgindir ama günün her saatinde olabilir. Şiddetli, sürekli kusma varsa '
                   'mutlaka doktora başvurmak gerekir.'),
        _symptomItem(context, '😴',
            isEn ? 'Fatigue & Drowsiness' : 'Yorgunluk ve Uyku Hali',
            isEn ? 'Due to pregnancy hormones, expectant mothers may frequently feel tired. '
                   'Very common especially in the first trimester.'
                 : 'Gebelik hormonlarının etkisiyle anne adayları kendilerini sık sık yorgun '
                   'hissedebilir. Özellikle ilk üç ayda çok yaygındır.'),
        _symptomItem(context, '🚽',
            isEn ? 'Frequent Urination' : 'Sık İdrara Çıkma',
            isEn ? 'Both hormonal effects and the growing uterus pressing on the bladder '
                   'can increase urination frequency.'
                 : 'Hem hormonların etkisi hem de büyüyen rahmin idrar torbasına baskı yapması '
                   'nedeniyle idrara çıkma sıklığı artabilir.'),
        _symptomItem(context, '👃',
            isEn ? 'Changes in Taste & Smell' : 'Koku ve Tat Değişiklikleri',
            isEn ? 'Some expectant mothers may no longer tolerate foods they previously enjoyed. '
                   'Hypersensitivity to certain smells is also completely normal.'
                 : 'Bazı anne adayları eskiden sevdiği yemekleri tolere edemeyebilir. Bazı '
                   'kokulara aşırı hassasiyet gösterebilir. Bu durum da tamamen normaldir.'),
        _symptomItem(context, '💧',
            isEn ? 'Increased Vaginal Discharge' : 'Akıntı Artışı',
            isEn ? 'Hormone-related increase in vaginal discharge may occur. Discharge with a '
                   'bad smell, unusual color, or itching may indicate infection — consult a doctor.'
                 : 'Hormonlara bağlı olarak vajinal akıntı artışı görülebilir. Kötü kokulu, '
                   'renkli veya kaşıntılı akıntılar enfeksiyon belirtisi olabilir, mutlaka '
                   'doktora danışılmalıdır.'),

        _secTitle(isEn ? '🔍 Lesser-Known Symptoms' : '🔍 Daha Az Bilinen Belirtiler', _rose),
        _bullet(context, isEn
            ? 'Mood Changes: Sudden irritability, crying, or restlessness can occur due to hormonal fluctuations.'
            : 'Duygu Durum Değişiklikleri: Hormonlardaki dalgalanma nedeniyle ani sinirlilik, ağlama isteği ya da huzursuzluk olabilir.'),
        _bullet(context, isEn
            ? 'Implantation Bleeding: Light spotting may occur when the fertilized egg implants in the uterus. Usually pink or brown, and brief.'
            : 'İmplantasyon Kanaması: Döllenmiş yumurta rahme tutunurken hafif lekelenme tarzında kanama görülebilir. Genellikle pembe ya da kahverengi, kısa süreli olur.'),

        _secTitle(isEn ? '🧪 Pregnancy Tests' : '🧪 Gebelik Testleri', _rose),
        _bullet(context, isEn
            ? 'Home Urine Test: Measures hCG hormone in urine. Most reliable from the first day of a missed period. May come out negative if done too early.'
            : 'Evde İdrar Testi: İdrarda hCG hormonunu ölçer. En güvenilir sonuç adet gecikmesinin ilk gününden itibaren alınır. Çok erken yapılırsa negatif çıkabilir.'),
        _bullet(context, isEn
            ? 'Blood Pregnancy Test: More sensitive and definitive. If the urine test is negative but you\'re still suspicious, a doctor can confirm with a blood test.'
            : 'Kanda Gebelik Testi: Daha duyarlı ve kesin sonuç verir. İdrar testi negatif çıksa bile şüphe varsa doktor kan testiyle netlik sağlar.'),

        _secTitle(isEn ? '🔬 Signs of Pregnancy on Ultrasound' : '🔬 Ultrasonda Hamilelik İşaretleri', _rose),
        _bullet(context, isEn
            ? 'Gestational sac: Usually visible inside the uterus by transvaginal ultrasound from around week 5.'
            : 'Gestasyonel kese (gebelik kesesi): Genellikle 5. haftadan itibaren vajinal ultrasonla rahim içinde görülür.'),
        _bullet(context, isEn
            ? 'Yolk sac: Visible at weeks 5–6, a small ring-shaped structure indicating normal pregnancy progression.'
            : 'Yolk kesesi: 5.–6. haftalarda, gebeliğin normal seyrettiğini gösteren küçük halka şeklinde yapıdır.'),
        _bullet(context, isEn
            ? 'Embryo and heartbeat: Visible at weeks 6–7. Hearing the heartbeat is the strongest indicator of a healthy pregnancy.'
            : 'Embriyo ve kalp atımı: 6.–7. haftalarda görülebilir. Kalp atışı duyulması gebeliğin sağlıklı ilerlediğinin en güçlü işaretidir.'),
        _bullet(context, isEn
            ? 'In later weeks: Baby\'s crown-rump length (CRL), movements, and organ development are monitored.'
            : 'İlerleyen haftalarda: Bebeğin baş-popo uzunluğu (CRL), hareketleri ve organ gelişimi takip edilir.'),

        _secTitle(isEn ? '⚠️ Conditions That Can Be Confused With Pregnancy' : '⚠️ Hamilelik Belirtileriyle Karışabilen Durumlar', _rose),
        _bullet(context, isEn
            ? 'Premenstrual syndrome: Breast tenderness, bloating, and mood changes are very similar to pregnancy.'
            : 'Adet öncesi sendromu: Meme hassasiyeti, karın şişliği ve duygu değişiklikleri gebeliğe çok benzer.'),
        _bullet(context, isEn
            ? 'Stress, nutritional disorders, hormonal imbalances: Can cause missed periods.'
            : 'Stres, beslenme bozuklukları, hormonal dengesizlikler: Adet gecikmesi yapabilir.'),
        _bullet(context, isEn
            ? 'Gastrointestinal issues: Can cause nausea and vomiting.'
            : 'Mide-bağırsak sorunları: Bulantı ve kusma yapabilir.'),

        _secTitle(isEn ? '🚨 When to See a Doctor?' : '🚨 Ne Zaman Doktora Başvurmalı?', _rose),
        _bullet(context, isEn ? 'Severe abdominal pain' : 'Şiddetli karın ağrısı'),
        _bullet(context, isEn ? 'Heavy or increasing vaginal bleeding' : 'Yoğun ya da artan vajinal kanama'),
        _bullet(context, isEn ? 'Fainting or severe dizziness' : 'Bayılma, baş dönmesi'),
        _bullet(context, isEn ? 'Excessive vomiting, weight loss, inability to urinate' : 'Aşırı kusma, kilo kaybı, idrar yapamama'),
        _bullet(context, isEn ? 'Fever and foul-smelling discharge' : 'Ateş ve kötü kokulu akıntı'),
        const SizedBox(height: 8),
        _para(context, isEn
            ? 'These conditions require urgent evaluation. Ectopic pregnancy or miscarriage risk may be present.'
            : 'Bu durumlar acil değerlendirme gerektirir. Özellikle dış gebelik veya düşük riski olabilir.'),
        const SizedBox(height: 8),
        _para(context, isEn
            ? 'While pregnancy symptoms give early clues, definitive diagnosis requires a test and ultrasound. '
              'Symptoms can vary from woman to woman; some pregnancies may have no symptoms at all. '
              'The most reliable approach is to test when a period is late and evaluate the result with a doctor.'
            : 'Hamilelik belirtileri anne adayına ilk ipuçlarını verse de, kesin tanı için "test" ve '
              '"ultrason" gereklidir. Belirtiler kadından kadına değişebilir; hatta bazı gebeliklerde '
              'hiçbir belirti olmayabilir. En güvenilir yaklaşım, adet geciktiğinde test yapmak ve '
              'sonucunu doktorla değerlendirmektir.'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet: Aşılama Tedavisi (IUI) / IUI Treatment
// ─────────────────────────────────────────────────────────────────────────────

class _IUISheet extends StatelessWidget {
  final bool isEn;
  const _IUISheet({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      children: [
        _dragHandle(context),
        Row(children: [
          const Text('🔬', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEn ? 'What Is IUI (Intrauterine Insemination)?' : 'Aşılama Tedavisi (IUI) Nedir?',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _blue),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _para(context, isEn
            ? 'IUI (intrauterine insemination) is a procedure where specially prepared sperm, '
              'processed in a laboratory, is placed directly into the uterus during the woman\'s '
              'ovulation period. The aim is to increase the chance of sperm reaching the egg, thus '
              'raising the chance of fertilization. The procedure is brief, requires no anesthesia, '
              'and is generally painless.'
            : 'Aşılama (intrauterin inseminasyon – IUI); laboratuvar ortamında özel olarak '
              'hazırlanmış spermin, kadının yumurtlama döneminde doğrudan rahim içine '
              'verilmesi işlemidir. Amaç, spermin yumurtaya ulaşma olasılığını artırarak '
              'döllenme şansını yükseltmektir. İşlem kısa sürer, anestezi gerektirmez ve '
              'genellikle ağrısızdır.'),

        _secTitle(isEn ? '👥 Who Is It Suitable For?' : '👥 Kimler İçin Uygundur?', _blue),
        _bullet(context, isEn
            ? 'Women with irregular ovulation or ovulation that can be stimulated with medication.'
            : 'Yumurtlaması düzensiz veya ilaçla uyarılabilir olan kadınlarda.'),
        _bullet(context, isEn
            ? 'Mild male factor infertility (low sperm count or motility).'
            : 'Hafif erkek faktörlü infertilitede (sperm sayısı ya da hareketliliği azlığı).'),
        _bullet(context, isEn
            ? 'Cervical mucus problems (when sperm has difficulty reaching the uterus).'
            : 'Servikal mukus problemlerinde (spermin rahme ulaşmasının zor olduğu durumlar).'),
        _bullet(context, isEn
            ? 'Unexplained infertility (no identifiable cause).'
            : 'Açıklanamayan infertilitede (sebebi belirlenemeyen kısırlık).'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _blue.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'Important Requirement: For IUI to be performed, at least one of the woman\'s '
                        'fallopian tubes must be open. This is evaluated before treatment with a '
                        'hysterosalpingography (HSG).'
                      : 'Önemli Şart: Aşılama yapılabilmesi için kadının en az bir tüpünün açık olması gerekir. '
                        'Bu durum tedavi öncesinde Rahim Filmi (HSG) ile mutlaka değerlendirilir.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        _secTitle(isEn ? '🔢 How Is the Treatment Done? (5 Steps)' : '🔢 Tedavi Nasıl Yapılır? (5 Aşama)', _blue),
        _step(context, '1',
            isEn ? 'Ovulation Stimulation' : 'Yumurtlamanın Uyarılması',
            isEn ? 'Egg-stimulating medications are started on day 2 or 3 of the menstrual cycle. '
                   'The goal is to obtain one or two mature eggs.'
                 : 'Adet döneminin 2. veya 3. gününde yumurta büyütücü ilaçlar başlanır. '
                   'Amaç bir veya iki olgun yumurta elde etmektir.'),
        _step(context, '2',
            isEn ? 'Follicle Monitoring' : 'Folikül Takibi',
            isEn ? 'Egg development is monitored by ultrasound. When the follicle reaches 18–20 mm, '
                   'a trigger injection (hCG) is administered.'
                 : 'Ultrasonla yumurtaların gelişimi takip edilir. Folikül 18–20 mm boyutuna '
                   'ulaştığında çatlatma iğnesi (hCG) yapılır.'),
        _step(context, '3',
            isEn ? 'Sperm Preparation' : 'Sperm Hazırlığı',
            isEn ? 'On the day of ovulation, the sperm sample provided by the partner is processed '
                   'in the laboratory using sperm washing and concentration techniques.'
                 : 'Yumurtlama gününde eşten alınan sperm örneği laboratuvarda "sperm yıkama '
                   've yoğunlaştırma" yöntemiyle özel işlemlerden geçirilir.'),
        _step(context, '4',
            isEn ? 'Insemination Procedure' : 'Aşılama İşlemi',
            isEn ? 'The prepared high-quality sperm is placed into the uterus via a thin catheter. '
                   'The procedure takes 10–15 minutes and requires no anesthesia.'
                 : 'Hazırlanan kaliteli spermler ince bir kateter yardımıyla rahim içine bırakılır. '
                   'İşlem 10–15 dakika sürer ve anestezi gerektirmez.'),
        _step(context, '5',
            isEn ? 'Pregnancy Test' : 'Gebelik Testi',
            isEn ? 'Approximately 12–14 days after the procedure, a blood test (Beta-hCG) is done '
                   'to evaluate the result. Progesterone supplements are given to support the uterus.'
                 : 'İşlemden yaklaşık 12–14 gün sonra kan testi (Beta-hCG) yapılarak sonuç '
                   'değerlendirilir. Rahmi desteklemek için progesteron takviyesi verilir.'),

        _secTitle(isEn ? '📊 Success Rate' : '📊 Başarı Oranı', _blue),
        _para(context, isEn
            ? 'The overall success rate averages 10–25%. With suitable couples and correct timing, '
              'this rate can reach up to 30%.'
            : 'Genel başarı oranı ortalama %10–25 arasındadır. Uygun çiftlerde ve doğru '
              'zamanlamayla bu oran %30\'a kadar çıkabilir.'),
        _bullet(context, isEn
            ? 'Success rate is higher when the woman is under 35 (15–25%).'
            : 'Kadın yaşı 35 altında başarı oranı daha yüksektir (%15–25).'),
        _bullet(context, isEn
            ? 'Higher sperm count and motility directly increases success.'
            : 'Sperm sayısı ve hareketliliği yüksekse başarı doğrudan artar.'),
        _bullet(context, isEn
            ? 'At least one fully open and healthy fallopian tube is required.'
            : 'En az bir tüpün tam açık ve sağlıklı olması şarttır.'),
        _bullet(context, isEn
            ? 'Generally recommended for up to 3–4 attempts for best results.'
            : 'En yüksek verim için genellikle 3–4 denemeye kadar önerilir.'),

        _secTitle(isEn ? '🆚 IUI vs. IVF?' : '🆚 Aşılama mı, Tüp Bebek mi?', _blue),
        _para(context, isEn
            ? 'Since IUI is a simpler procedure, it is generally tried before IVF. '
              'However, IVF is recommended directly in the following situations:'
            : 'Aşılama daha basit bir yöntem olduğu için genellikle tüp bebekten önce denenir. '
              'Ancak aşağıdaki durumlarda doğrudan tüp bebek (IVF) tedavisine geçilmesi önerilir:'),
        _bullet(context, isEn ? 'Both fallopian tubes are blocked.' : 'Her iki tüpün de kapalı olması.'),
        _bullet(context, isEn
            ? 'Severe sperm disorders (very low count and motility).'
            : 'Şiddetli sperm bozuklukları (sayı ve hareketliliğin çok düşük olması).'),
        _bullet(context, isEn
            ? 'Low ovarian reserve in women over 38.'
            : '38 yaş üstü kadınlarda düşük yumurtalık rezervi.'),
        _bullet(context, isEn
            ? '3 or more failed IUI attempts.'
            : '3 veya daha fazla başarısız aşılama denemesinin bulunması.'),

        _secTitle(isEn ? '✅ Things to Watch Out For' : '✅ Dikkat Edilmesi Gerekenler', _blue),
        _bullet(context, isEn
            ? 'Stop smoking and alcohol consumption before treatment.'
            : 'Tedavi öncesi sigara ve alkol tüketimi sonlandırılmalıdır.'),
        _bullet(context, isEn
            ? 'Pay attention to healthy eating and maintaining an ideal weight.'
            : 'Sağlıklı beslenmeye ve ideal kiloyu dengelemeye özen gösterilmeli.'),
        _bullet(context, isEn
            ? 'Complete basic hormone tests such as TSH, Prolactin, and AMH.'
            : 'Tiroid, Prolaktin ve AMH gibi temel hormon testleri tamamlanmalı.'),
        _bullet(context, isEn
            ? 'After the procedure, a brief rest is sufficient before returning to normal daily life.'
            : 'İşlem günü kısa süreli dinlenmeden sonra normal yaşama dönülebilir.'),
        _bullet(context, isEn
            ? 'Use progesterone support as directed by your doctor.'
            : 'Doktorun önerdiği progesteron desteği düzenli kullanılmalıdır.'),

        _secTitle(isEn ? '❓ Frequently Asked Questions' : '❓ Sık Sorulan Sorular', _blue),
        _qa(context,
            isEn ? 'Is IUI a painful procedure?' : 'Aşılama tedavisi ağrılı bir işlem midir?',
            isEn ? 'No. The procedure requires no anesthesia, is performed in an examination room, '
                   'and is generally painless. Only mild cramping similar to menstrual pain may be felt.'
                 : 'Hayır. İşlem anestezi gerektirmez, muayene odası şartlarında yapılır ve genellikle ağrısızdır. '
                   'Sadece hafif bir adet sancısı benzeri kramp hissedilebilir.'),
        _qa(context,
            isEn ? 'Is intercourse allowed after IUI?' : 'Aşılama sonrası cinsel ilişki serbest midir?',
            isEn ? 'Doctors generally recommend intercourse on the day of the procedure or the next day; '
                   'this may increase the chance of pregnancy.'
                 : 'Genellikle aşılamanın yapıldığı gün veya ertesi gün doktorlar tarafından cinsel ilişki önerilir; '
                   'bu durum gebelik şansını artırabilir.'),
        _qa(context,
            isEn ? 'How many IUI attempts can be done?' : 'Kaç defa aşılama yaptırılabilir?',
            isEn ? 'If pregnancy is not achieved after 3–4 attempts, switching to IVF is typically '
                   'recommended to avoid losing time and resources.'
                 : 'Genellikle 3–4 deneme sonrasında gebelik elde edilemezse, zaman ve maliyet kaybını önlemek adına '
                   'tüp bebek tedavisine geçilmesi düşünülür.'),
        _qa(context,
            isEn ? 'Is bed rest required after IUI?' : 'Aşılama sonrası yatak istirahati gerekir mi?',
            isEn ? 'No. Lying down at the clinic for 15–20 minutes after the procedure is sufficient. '
                   'You can comfortably return to your daily social and work life the same day.'
                 : 'Hayır. İşlem bittikten sonra klinikte 15–20 dakika uzanmak yeterlidir. Aynı gün günlük '
                   'sosyal ve iş hayatınıza rahatlıkla dönebilirsiniz.'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet: Tüp Bebek Tedavisi (IVF) / IVF Treatment
// ─────────────────────────────────────────────────────────────────────────────

class _IVFSheet extends StatelessWidget {
  final bool isEn;
  const _IVFSheet({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      children: [
        _dragHandle(context),
        Row(children: [
          const Text('🧬', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEn ? 'What Is IVF (In Vitro Fertilization)?' : 'Tüp Bebek Tedavisi (IVF) Nedir?',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _purple),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _para(context, isEn
            ? 'IVF (in vitro fertilization) is a procedure where eggs retrieved from a woman '
              'are fertilized with sperm in a laboratory and then transferred to the uterus. '
              'This treatment has been safely practiced worldwide since 1978 and has helped '
              'millions of couples have children.'
            : 'Tüp bebek tedavisi; kadından alınan yumurta ile erkeğin sperminin laboratuvar '
              'ortamında döllenerek rahme yerleştirilmesi işlemidir. Bu tedavi 1982 yılından '
              'beri dünyada güvenle uygulanmakta ve milyonlarca çiftin çocuk sahibi olmasını '
              'sağlamaktadır.'),

        _secTitle(isEn ? '👥 Who Is It For?' : '👥 Kimler İçin Uygulanır?', _purple),
        _bullet(context, isEn
            ? 'Advanced maternal age: Especially preferred over 40 to avoid wasting time.'
            : 'İleri Kadın Yaşı: Özellikle 40 yaş üzerinde zaman kaybetmemek adına tercih edilir.'),
        _bullet(context, isEn
            ? 'Blocked or damaged fallopian tubes: From infection, previous surgery, ectopic pregnancy, or hydrosalpinx.'
            : 'Tüplerde Tıkanıklık veya Hasar: Enfeksiyon, geçirilmiş cerrahi, dış gebelik veya hidrosalpenks.'),
        _bullet(context, isEn
            ? 'Ovarian dysfunction: Ovulation disorders, diminished ovarian reserve, premature ovarian insufficiency.'
            : 'Yumurtalık Fonksiyon Bozuklukları: Yumurtlama sorunları, yumurta rezervi azlığı, erken over yetmezliği.'),
        _bullet(context, isEn
            ? 'Endometriosis: The condition known as chocolate cyst negatively affecting egg quality.'
            : 'Endometriozis: Çikolata kisti olarak bilinen durumun yumurta kalitesini olumsuz etkilemesi.'),
        _bullet(context, isEn
            ? 'Sperm problems: Sperm count, motility, and functional disorders in men.'
            : 'Sperm Sorunları: Erkekte sperm sayısı, hareketliliği ve fonksiyon bozuklukları.'),
        _bullet(context, isEn
            ? 'Unexplained infertility: Cases where no cause is found despite all testing.'
            : 'Açıklanamayan Kısırlık: Yapılan tüm testlere rağmen nedeni belli olmayan vakalar.'),
        _bullet(context, isEn
            ? 'Recurrent pregnancy loss: PGT can select healthy embryos in cases of 3+ miscarriages.'
            : 'Tekrarlayan Gebelik Kayıpları: 3\'ten fazla düşük öyküsünde PGT ile sağlıklı embriyo seçimi.'),
        _bullet(context, isEn
            ? 'Genetic disease carrier: Conditions such as thalassemia, cystic fibrosis, SMA.'
            : 'Genetik Hastalık Taşıyıcılığı: Talasemi, kistik fibrozis, SMA gibi hastalıklarda.'),

        _secTitle(isEn ? '📊 Success Rates' : '📊 Başarı Oranları', _purple),
        _para(context, isEn
            ? 'The most critical factor affecting success is the woman\'s age. '
              'With repeated attempts, success rates can reach 45–60%.'
            : 'Başarıyı etkileyen en kritik faktör kadının yaşıdır. Tekrarlayan denemelerle '
              'başarı oranı %45–60 seviyelerine ulaşabilir.'),
        _IVFTable(isEn: isEn),

        _secTitle(isEn ? '⚠️ Treatment Risks' : '⚠️ Tedavi Riskleri', _purple),
        _bullet(context, isEn
            ? 'OHSS (Ovarian Hyperstimulation Syndrome): Overstimulation of the ovaries by medications. '
              'Causes abdominal bloating, nausea, fluid accumulation. Higher risk in women with PCOS.'
            : 'OHSS (Ovaryen Hiperstimülasyon Sendromu): İlaçların yumurtalıkları aşırı uyarması. '
              'Karında şişlik, bulantı, sıvı birikmesi ile kendini gösterir. PKOS\'lu kadınlarda risk daha yüksektir.'),
        _bullet(context, isEn
            ? 'Ovarian torsion: Risk of the enlarged ovaries twisting on themselves.'
            : 'Over Torsiyonu: Büyüyen yumurtalıkların kendi etrafında dönmesi riski.'),
        _bullet(context, isEn
            ? 'Multiple pregnancy: Risk of twins or triplets due to multiple embryo transfer.'
            : 'Çoğul Gebelik: Birden fazla embriyo transferine bağlı ikiz veya üçüz gebelik riski.'),
        _bullet(context, isEn
            ? 'Ectopic pregnancy: There is also a 2–5% ectopic pregnancy risk with IVF.'
            : 'Dış Gebelik: IVF tedavisinde de %2–5 oranında dış gebelik riski mevcuttur.'),

        _secTitle(isEn ? '🔢 Treatment Steps (7 Steps)' : '🔢 Tedavi Aşamaları (7 Adım)', _purple),
        _step(context, '1',
            isEn ? 'Ovarian Stimulation' : 'Yumurta Geliştirilmesi (Ovülasyon İndüksiyonu)',
            isEn ? 'On days 2–5 of the period, hormone medications trigger follicle growth in the ovaries. '
                   'The dose is determined by the patient\'s age, weight, and ovarian reserve.'
                 : 'Adetin 2–5. günü hormon ilaçları ile yumurtalıklardaki folikül büyümesi '
                   'tetiklenir. Doz hastanın yaşına, kilosuna ve over rezervine göre belirlenir.'),
        _step(context, '2',
            isEn ? 'Trigger Injection' : 'Çatlatma İğnesi Uygulaması',
            isEn ? 'When follicles reach 17–18 mm, a single-dose injection is given to trigger '
                   'egg maturation. It must be administered at the exact specified time.'
                 : 'Foliküller 17–18 mm boyutuna ulaştığında yumurtanın olgunlaşmasını sağlayan '
                   'tek dozluk iğne uygulanır. Tam olarak belirtilen saatte yapılmalıdır.'),
        _step(context, '3',
            isEn ? 'Egg Retrieval (OPU)' : 'Yumurta Toplanması (OPU)',
            isEn ? '34–36 hours after the trigger injection, eggs are retrieved under sedation '
                   'anesthesia with vaginal ultrasound guidance. The procedure takes ~15 minutes.'
                 : 'Çatlatma iğnesinden 34–36 saat sonra, sedasyon anestezisi altında vajinal '
                   'ultrason eşliğinde yumurtalar toplanır. İşlem ~15 dakika sürer.'),
        _step(context, '4',
            isEn ? 'Sperm Collection' : 'Sperm Elde Edilmesi',
            isEn ? 'A sperm sample is collected on egg retrieval day and processed. In azoospermia '
                   'cases, sperm can be retrieved from the testicle via microsurgical methods (MESA, TESA, Micro-TESE).'
                 : 'Yumurta toplama günü sperm örneği alınır ve özel işlemlerden geçirilir. '
                   'Azospermi vakalarında mikrocerrahi yöntemlerle (MESA, TESA, Mikro-TESE) '
                   'testisten sperm elde edilebilir.'),
        _step(context, '5',
            isEn ? 'Fertilization' : 'Yumurtanın Döllenmesi',
            isEn ? 'Retrieved eggs are fertilized in the laboratory. For low sperm quality, '
                   'the most widely preferred method is Microinjection (ICSI/IMSI).'
                 : 'Toplanan yumurtalar laboratuvarda döllenir. Sperm kalitesi düşük vakalarda '
                   'en yaygın tercih edilen yöntem Mikroenjeksiyon (ICSI/IMSI)\'dir.'),
        _step(context, '6',
            isEn ? 'Embryo Development & Storage' : 'Embriyo Gelişimi ve Saklanması',
            isEn ? 'Fertilized eggs are monitored in an incubator for 2–6 days. An embryoscope '
                   'allows development to be tracked without exposing embryos to external conditions.'
                 : 'Döllenen yumurtalar inkübatörde 2–6 gün takip edilir. Embriyoskop ile '
                   'dış ortama maruz bırakmadan gelişim izlenir.'),
        _step(context, '7',
            isEn ? 'Embryo Transfer' : 'Embriyonun Rahme Transferi',
            isEn ? 'Up to age 35, a single embryo is transferred in the first two attempts; '
                   'after age 35, up to 2 embryos may be transferred. No anesthesia required, ~10 minutes.'
                 : '35 yaşına kadar ilk iki denemede tek embriyo, 35 yaşından sonra en fazla '
                   '2 embriyo transfer edilebilir. İşlem anestezi gerektirmez, ~10 dakika sürer.'),

        _secTitle(isEn ? '💊 Post-Treatment Care' : '💊 Tedavi Sonrası Dikkat Edilmesi Gerekenler', _purple),
        _bullet(context, isEn
            ? 'After transfer, pills, injections, blood thinners, or patches containing hormones '
              'are used to increase embryo implantation.'
            : 'Transfer sonrasında embriyonun tutunmasını artırmak için hormon içeren haplar, '
              'iğneler, kan sulandırıcılar veya bantlar kullanılır.'),
        _bullet(context, isEn
            ? 'Medications must be taken at the same time each day, strictly following the doctor\'s schedule.'
            : 'İlaçlar her gün aynı saatte ve doktorun hazırladığı çizelgeye tam uyularak kullanılmalıdır.'),
        _bullet(context, isEn
            ? 'Abdominal injections should be given 3 fingers below the navel, alternating sides each day (right one day, left the next).'
            : 'Göbekten yapılan iğneler göbek deliğinin 3 parmak altına, her gün yön değiştirerek '
              '(bir gün sağ, bir gün sol) uygulanmalıdır.'),
        _bullet(context, isEn
            ? 'Quit smoking and alcohol completely; limit tea and coffee to 1–2 cups per day.'
            : 'Sigara ve alkol tamamen bırakılmalı; çay ve kahve günde 1–2 fincanla sınırlandırılmalıdır.'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _purple.withValues(alpha: 0.22)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'Scientific studies have shown that hormonal medications used in IVF treatment '
                        'do not increase the risk of breast, uterine, cervical, or ovarian cancer in women.'
                      : 'Yapılan bilimsel çalışmalar, tüp bebek tedavisinde kullanılan hormon '
                        'ilaçlarının kadınlarda meme, rahim, rahim ağzı veya yumurtalık kanseri '
                        'riskini artırmadığını göstermiştir.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// IVF yaş-başarı tablosu
class _IVFTable extends StatelessWidget {
  final bool isEn;
  const _IVFTable({required this.isEn});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final rows = isEn
        ? const [
            ('Under 35',  '35% – 45%'),
            ('35 – 37',   '35%'),
            ('38 – 40',   '25%'),
            ('Over 40',   '15%'),
            ('Over 42',   '5% – 10%'),
          ]
        : const [
            ('35 Yaş Altı', '%35 – %45'),
            ('35 – 37 Yaş', '%35'),
            ('38 – 40 Yaş', '%25'),
            ('40 Yaş Üzeri', '%15'),
            ('42 Yaş Üzeri', '%5 – %10'),
          ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _purple.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          // Başlık satırı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(isEn ? "Woman's Age" : 'Kadın Yaşı',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _purple)),
                ),
                Text(isEn ? 'Success Rate' : 'Başarı Oranı',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _purple)),
              ],
            ),
          ),
          // Veri satırları
          for (int i = 0; i < rows.length; i++)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: i.isEven
                    ? Colors.transparent
                    : cs.onSurface.withValues(alpha: isDark ? 0.04 : 0.03),
                borderRadius: i == rows.length - 1
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(11))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(rows[i].$1,
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface
                                .withValues(alpha: 0.8))),
                  ),
                  Text(rows[i].$2,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _purple)),
                ],
              ),
            ),
        ],
      ),
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

// Numaralı adım (IUI ve IVF sheet'lerinde kullanılır)
Widget _step(
    BuildContext context, String num, String title, String desc) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: _purple,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
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
