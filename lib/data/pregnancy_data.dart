// =============================================
// data/pregnancy_data.dart
// 40 haftalık gebelik gelişim verisi, kilometre taşları
// ve yardımcı hesaplama fonksiyonları.
// =============================================

import 'package:flutter/material.dart';

// ── Meyve / boyut arketipleri ──────────────────────────────────────────────
enum FruitShape {
  none,
  tinySeed,    // haşhaş, elma çekirdeği
  smallRound,  // bezelye, yaban mersini, zeytin, erik kurusu, nar, şalgam, erik
  raspberry,   // ahududu
  strawberry,  // (painter'da var, geriye dönük uyumluluk)
  citrus,      // misket limonu, şeftali, limon, portakal, greyfurt
  avocado,     // avokado
  apple,       // soğan (yuvarlak)
  pear,        // tatlı patates, mango, papaya
  pepper,      // (painter'da var, geriye dönük uyumluluk)
  banana,      // muz
  carrot,      // (painter'da var, geriye dönük uyumluluk)
  leafy,       // karnıbahar, lahana
  longGreen,   // salatalık, kabak, kış kavunu
  corn,        // (painter'da var, geriye dönük uyumluluk)
  eggplant,    // patlıcan
  melon,       // bal kabağı, hindistan cevizi, kavun, durian, tatlı kabak
  watermelon,  // karpuz, jack meyvesi
}

// ── Embriyo / fetüs siluet aşamaları ──────────────────────────────────────
enum EmbryoStage {
  fertilization,  // 1-2. hafta
  cellCluster,    // 3-4. hafta
  embryoTadpole,  // 5-6. hafta
  earlyFetus,     // 7-8. hafta
  fetus,          // 9-10. hafta
  plumpFetus,     // 11-12. hafta
  matureFetus,    // 13-28. hafta
  fullTerm,       // 29-40. hafta
}

EmbryoStage embryoStageForWeek(int week) {
  final w = week.clamp(1, 40);
  if (w <= 2) return EmbryoStage.fertilization;
  if (w <= 4) return EmbryoStage.cellCluster;
  if (w <= 6) return EmbryoStage.embryoTadpole;
  if (w <= 8) return EmbryoStage.earlyFetus;
  if (w <= 10) return EmbryoStage.fetus;
  if (w <= 12) return EmbryoStage.plumpFetus;
  if (w <= 28) return EmbryoStage.matureFetus;
  return EmbryoStage.fullTerm;
}

// ── Haftalık gelişim modeli ────────────────────────────────────────────────
class PregnancyWeekInfo {
  final int week;
  final String summary;
  final String sizeText;
  final FruitShape fruit;
  final EmbryoStage stage;

  const PregnancyWeekInfo({
    required this.week,
    required this.summary,
    required this.sizeText,
    required this.fruit,
    required this.stage,
  });
}

const List<PregnancyWeekInfo> kPregnancyWeeks = [
  PregnancyWeekInfo(
    week: 1,
    summary: 'Henüz yola çıkmadın sayılır — vücudun hazırlık yapıyor, '
        'uterus yumurtayı karşılamak için kalınlaşıyor.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
  ),
  PregnancyWeekInfo(
    week: 2,
    summary: 'Yumurtan olgunlaşıyor. Bu haftanın sonunda ovulasyon '
        'gerçekleşebilir — döllenme için en verimli dönem.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
  ),
  PregnancyWeekInfo(
    week: 3,
    summary: 'Sperm ve yumurta buluştu! Zigot oluştu ve '
        'rahme doğru yolculuğa başladı.',
    sizeText: 'Bir haşhaş tohumu kadar.',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.fertilization,
  ),
  PregnancyWeekInfo(
    week: 4,
    summary: 'Hücreler çoğaldı, blastosist rahim duvarına tutundu. '
        'hCG hormonu yükseliyor.',
    sizeText: 'Bir haşhaş tohumu kadar.',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.cellCluster,
  ),
  PregnancyWeekInfo(
    week: 5,
    summary: 'Kalp, beyin ve omurga taslakları şekilleniyor. '
        'Minik kalp bu hafta atmaya hazırlanıyor.',
    sizeText: 'Bir elma çekirdeği kadar.',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 6,
    summary: 'İlk kalp atışı bu hafta! Ultrasonda duyulabilir. '
        'Kol ve bacak tomurcukları belirmeye başladı.',
    sizeText: 'Bir bezelye kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 7,
    summary: 'Beyni saniyede 100 yeni nöron üretiyor. '
        'Yüz hatları, göz çukurları belirginleşiyor.',
    sizeText: 'Bir yaban mersini kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 8,
    summary: 'Parmaklar ayrışıyor, bilek ve dirsekler kıpırdıyor. '
        'Kulak kepçeleri oluşuyor.',
    sizeText: 'Bir ahududu kadar.',
    fruit: FruitShape.raspberry,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 9,
    summary: 'Minik kuyruk tamamen geride kaldı. '
        'Kas hareketleri başladı, yutkunabiliyor.',
    sizeText: 'Bir yeşil zeytin kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 10,
    summary: 'Hayati organların tümü yerleşti — artık fetüs dönemi başladı. '
        'Tırnaklar oluşmaya başladı.',
    sizeText: 'Bir erik kurusu kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 11,
    summary: 'Saç folikülleri ve saç oluşumu bu hafta başlıyor! '
        'Bebek artık ışığa tepki verebiliyor.',
    sizeText: 'Bir misket limonu kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 12,
    summary: 'İlk trimester bitiyor! Refleksleri gelişti, '
        'esniyor ve bükülebiliyor.',
    sizeText: 'Bir erik kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 13,
    summary: 'İkinci trimester başladı! Minik parmak izleri oluştu, '
        'kemikler sertleşmeye başladı.',
    sizeText: 'Bir şeftali kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 14,
    summary: 'Yüz ifadeleri yapabiliyor: kaş çatıyor, gülümsüyor. '
        'Troid bezi çalışmaya başladı.',
    sizeText: 'Bir limon kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 15,
    summary: 'Sesini duyabiliyor, ışığı algılamaya başladı. '
        'Kemik iliği kan hücreleri üretiyor.',
    sizeText: 'Bir portakal kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 16,
    summary: 'Kasları güçleniyor, ilk tekmeler yakın! '
        'Gözleri yavaş yavaş açılmaya başladı.',
    sizeText: 'Bir avokado kadar.',
    fruit: FruitShape.avocado,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 17,
    summary: 'Yağ depolamaya başladı, derisi pürüzsüzleşiyor. '
        'İşitme duyusu gelişiyor.',
    sizeText: 'Bir soğan kadar.',
    fruit: FruitShape.apple,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 18,
    summary: 'Esniyor, hıçkırıyor — yakında sen de hissedeceksin! '
        'Sinir sistemi hızla gelişiyor.',
    sizeText: 'Bir tatlı patates kadar.',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 19,
    summary: 'Deriyi koruyan vernix tabakası oluştu. '
        'Duyu organları olgunlaşıyor.',
    sizeText: 'Bir mango kadar.',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 20,
    summary: 'Yarı yoldasın! Bebek artık seni net duyuyor, '
        'sesine alışıyor.',
    sizeText: 'Bir muz kadar.',
    fruit: FruitShape.banana,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 21,
    summary: 'Yutkunma hareketleri yapıyor, sindirim sistemi çalışıyor. '
        'Kaşlar ve kirpikler belirginleşti.',
    sizeText: 'Bir nar kadar.',
    fruit: FruitShape.apple,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 22,
    summary: 'Kaş ve kirpikleri belirginleşti, dudak hareketleri yapıyor. '
        'Görme siniri gelişiyor.',
    sizeText: 'Bir papaya kadar.',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 23,
    summary: 'Derisi hâlâ buruşuk ama hızla kilo alıyor. '
        'Akciğer gelişimi hızlanıyor.',
    sizeText: 'Bir greyfurt kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 24,
    summary: 'Akciğerleri nefes almaya hazırlanıyor, surfaktan üretiyor. '
        'Denge duyusu çalışıyor.',
    sizeText: 'Bir kavun kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 25,
    summary: 'Saçları belirginleşti, deri altı yağ dokusu birikmeye başladı. '
        'Elleri kavrayabiliyor.',
    sizeText: 'Bir karnıbahar kadar.',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 26,
    summary: 'Gözlerini açıp kapatabiliyor, ışık ve karanlık farkını '
        'hissediyor.',
    sizeText: 'Bir lahana kadar.',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 27,
    summary: 'Üçüncü trimester başladı! Beyni hızla kıvrımlanıyor, '
        'rüya görebiliyor.',
    sizeText: 'Bir şalgam kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 28,
    summary: 'Gözler ışığa tepki veriyor. Artık "tekme sayarı" '
        'kullanabilirsin — günde 10 tekme hedef.',
    sizeText: 'Bir patlıcan kadar.',
    fruit: FruitShape.eggplant,
    stage: EmbryoStage.matureFetus,
  ),
  PregnancyWeekInfo(
    week: 29,
    summary: 'Kasları ve akciğerleri olgunlaşmaya devam ediyor. '
        'Kalsiyum ihtiyacı arttı.',
    sizeText: 'Bir bal kabağı kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 30,
    summary: 'Beyin kıvrımları artıyor, daha da akıllı oluyor! '
        'Kilo alımı hızlandı.',
    sizeText: 'Bir salatalık kadar.',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 31,
    summary: 'Tüm duyuları çalışıyor. Vücudu ısısını düzenlemeye '
        'başlıyor.',
    sizeText: 'Bir hindistan cevizi kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 32,
    summary: 'Tırnakları parmak uçlarına ulaştı. '
        'Büyük olasılıkla baş aşağı döndü.',
    sizeText: 'Bir kabak kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 33,
    summary: 'Kemikleri sertleşiyor, kafatası hâlâ esneme kabiliyetinde — '
        'doğum kanalından geçmek için.',
    sizeText: 'Bir durian meyvesi kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 34,
    summary: 'Bağışıklık sistemi güçleniyor, anneden antikorlar geçiyor. '
        'Doğuma hazırlanıyor.',
    sizeText: 'Bir tatlı kabak kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 35,
    summary: 'Böbrekleri tam gelişti, hızla yağlanıyor. '
        'Kasılmalar (Braxton Hicks) hissedebilirsin.',
    sizeText: 'Bir kokonat kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 36,
    summary: 'Doğum pozisyonuna geçiyor — başı aşağıda. '
        'Haftalık NST kontrolleri başlıyor.',
    sizeText: 'Bir tatlı kavun kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 37,
    summary: 'Erken term — artık her an hazır! '
        'Akciğerleri tamamen olgun.',
    sizeText: 'Bir kış kavunu kadar.',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 38,
    summary: 'Organları tamamen olgun. Kavrama refleksi çok güçlü — '
        'doğar doğmaz seni tutacak.',
    sizeText: 'Bir kestane kabağı kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 39,
    summary: 'Doğum çok yakın! Son rötuşlar tamamlanıyor, '
        'çantanı hazırla.',
    sizeText: 'Bir karpuz kadar.',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 40,
    summary: 'Hoş geldin günü çok yakın! Bebek tamamen hazır. '
        'Doğum çantanı yanında tut.',
    sizeText: 'Bir jack meyvesi kadar.',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
  ),
];

PregnancyWeekInfo pregnancyWeekInfo(int week) {
  final w = week.clamp(1, 40).toInt();
  return kPregnancyWeeks[w - 1];
}

// ─────────────────────────────────────────────
// Kilometre taşları
// ─────────────────────────────────────────────
enum MilestoneCategory {
  folicAcid,
  fertilization,
  implantation,
  test,
  organ,
  heartbeat,
}

extension MilestoneCategoryX on MilestoneCategory {
  Color get color {
    switch (this) {
      case MilestoneCategory.folicAcid:
        return const Color(0xFFEC4899);
      case MilestoneCategory.fertilization:
        return const Color(0xFF3B82F6);
      case MilestoneCategory.implantation:
        return const Color(0xFFE11D48);
      case MilestoneCategory.test:
        return const Color(0xFF9333EA);
      case MilestoneCategory.organ:
        return const Color(0xFF14B8A6);
      case MilestoneCategory.heartbeat:
        return const Color(0xFFF97316);
    }
  }
}

class PregnancyMilestone {
  final String title;
  final String description;
  final MilestoneCategory category;
  final int startDayOffset;
  final int endDayOffset;

  const PregnancyMilestone({
    required this.title,
    required this.description,
    required this.category,
    required this.startDayOffset,
    required this.endDayOffset,
  });

  Color get color => category.color;
}

const List<PregnancyMilestone> kMilestones = [
  PregnancyMilestone(
    title: 'Folik asit kullanımı',
    description:
        'Bebeğin nöral tüpünün sağlıklı gelişimi için folik asit almak '
        'bu dönemde çok kritik. Doktorunun önerdiği dozu aksatma.',
    category: MilestoneCategory.folicAcid,
    startDayOffset: 0,
    endDayOffset: 90,
  ),
  PregnancyMilestone(
    title: 'Döllenme',
    description: 'Sperm ve yumurta buluştu — yolculuk başladı!',
    category: MilestoneCategory.fertilization,
    startDayOffset: 13,
    endDayOffset: 15,
  ),
  PregnancyMilestone(
    title: 'Rahme tutunma',
    description: 'Döllenmiş yumurta rahim duvarına tutundu. Gebelik resmen başladı!',
    category: MilestoneCategory.implantation,
    startDayOffset: 20,
    endDayOffset: 24,
  ),
  PregnancyMilestone(
    title: 'Gebelik testi pozitif',
    description: 'hCG hormonu testte görünecek kadar yükseldi.',
    category: MilestoneCategory.test,
    startDayOffset: 27,
    endDayOffset: 31,
  ),
  PregnancyMilestone(
    title: 'Organ gelişim dönemi',
    description:
        'Bebeğin hayati organlarının temeli bu haftalarda atılıyor. '
        'İlaç ve beslenmene en çok dikkat etmen gereken dönem.',
    category: MilestoneCategory.organ,
    startDayOffset: 28,
    endDayOffset: 70,
  ),
  PregnancyMilestone(
    title: 'İlk kalp atışı',
    description: 'Minik kalp atmaya başladı! Ultrasonda duyulabilir.',
    category: MilestoneCategory.heartbeat,
    startDayOffset: 38,
    endDayOffset: 44,
  ),
];

List<PregnancyMilestone> milestonesForDate(DateTime date, DateTime? lmp) {
  if (lmp == null) return const [];
  final d0 = DateTime(lmp.year, lmp.month, lmp.day);
  final d1 = DateTime(date.year, date.month, date.day);
  final offset = d1.difference(d0).inDays;
  return kMilestones
      .where((m) => offset >= m.startDayOffset && offset <= m.endDayOffset)
      .toList();
}

int? pregnancyWeekForDate(DateTime date, DateTime? lmp) {
  if (lmp == null) return null;
  final d0 = DateTime(lmp.year, lmp.month, lmp.day);
  final d1 = DateTime(date.year, date.month, date.day);
  final days = d1.difference(d0).inDays;
  if (days < 0) return null;
  final week = (days ~/ 7) + 1;
  return week.clamp(1, 40);
}
