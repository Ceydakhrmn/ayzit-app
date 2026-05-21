// =============================================
// data/pregnancy_data.dart
// Gebelik takip modu için statik veri:
//   • PregnancyWeekInfo  — 40 haftalık bebek gelişim bilgisi
//   • PregnancyMilestone — LMP'ye göre hesaplanan kilometre taşları
// Tüm hesaplamalar son adet tarihinden (LMP) gün farkıyla yapılır.
// =============================================

import 'package:flutter/material.dart';

// ── Meyve / boyut arketipleri (fruit_painter.dart bunları çizer) ──
enum FruitShape {
  none,
  tinySeed, // haşhaş, susam
  smallRound, // mercimek, yaban mersini, kiraz, incir
  raspberry, // ahududu
  strawberry, // çilek
  citrus, // limon, misket limonu, şeftali, greyfurt
  apple, // elma, domates
  avocado, // avokado
  pear, // armut
  pepper, // dolmalık biber
  banana, // muz
  carrot, // havuç
  longGreen, // salatalık, kabak, kereviz, pırasa
  corn, // mısır
  leafy, // marul, lahana, karnabahar, pazı
  eggplant, // patlıcan
  melon, // kavun, bal kabağı, hindistan cevizi
  watermelon, // karpuz
}

// ── Embriyo / fetüs siluet aşamaları (embryo_painter.dart bunları çizer) ──
enum EmbryoStage {
  cellCluster, // 1-4. hafta — hücre topu
  embryoTadpole, // 5-9. hafta — kuyruklu embriyo
  earlyFetus, // 10-13. hafta — büyük başlı erken fetüs
  fetus, // 14-22. hafta — kıvrılmış bebek
  plumpFetus, // 23-31. hafta — dolgunlaşan bebek
  fullTerm, // 32-40. hafta — doğuma hazır bebek
}

class PregnancyWeekInfo {
  final int week;
  final String summary; // bebeğin gelişimi metni
  final String sizeText; // boyut karşılaştırması ("" ise gösterme)
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
    summary: 'Henüz yola çıkmadın sayılır — bu hafta vücudun hazırlık yapıyor.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.cellCluster,
  ),
  PregnancyWeekInfo(
    week: 2,
    summary: 'Yumurtan olgunlaşıyor, döllenme bu haftanın sonunda olabilir.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.cellCluster,
  ),
  PregnancyWeekInfo(
    week: 3,
    summary: 'Sperm ve yumurta buluştu! Minik bir hücre yolculuğa başladı.',
    sizeText: 'Bir haşhaş tohumu kadar.',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.cellCluster,
  ),
  PregnancyWeekInfo(
    week: 4,
    summary: 'Hücreler çoğaldı, minik bir top oldu ve rahmine tutundu.',
    sizeText: 'Bir haşhaş tohumu kadar.',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.cellCluster,
  ),
  PregnancyWeekInfo(
    week: 5,
    summary: 'Kalbi atmaya hazırlanıyor, temel organların taslağı çiziliyor.',
    sizeText: 'Bir susam tanesi kadar.',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 6,
    summary: 'İlk kalp atışı bu hafta! Minicik ama çarpıyor.',
    sizeText: 'Bir mercimek kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 7,
    summary: 'Kol ve bacak tomurcukları belirdi, beyni hızla büyüyor.',
    sizeText: 'Bir yaban mersini kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 8,
    summary: 'Minik parmaklar oluşuyor, kıpırdamaya başladı bile.',
    sizeText: 'Bir ahududu kadar.',
    fruit: FruitShape.raspberry,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 9,
    summary: 'Minik kuyruğu kayboldu, artık gerçek bir bebek silueti var.',
    sizeText: 'Bir kiraz kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
  ),
  PregnancyWeekInfo(
    week: 10,
    summary: 'Hayati organların hepsi yerinde — şimdi büyüme zamanı.',
    sizeText: 'Bir çilek kadar.',
    fruit: FruitShape.strawberry,
    stage: EmbryoStage.earlyFetus,
  ),
  PregnancyWeekInfo(
    week: 11,
    summary: 'Tırnaklar ve saç folikülleri oluşuyor.',
    sizeText: 'Bir incir kadar.',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.earlyFetus,
  ),
  PregnancyWeekInfo(
    week: 12,
    summary: 'İlk trimester bitiyor! Refleksleri gelişti, esniyor bile.',
    sizeText: 'Bir misket limonu kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.earlyFetus,
  ),
  PregnancyWeekInfo(
    week: 13,
    summary: 'İkinci trimester başladı, minik parmak izleri oluştu.',
    sizeText: 'Bir şeftali kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.earlyFetus,
  ),
  PregnancyWeekInfo(
    week: 14,
    summary: 'Yüz ifadeleri yapabiliyor, kaş bile çatabiliyor.',
    sizeText: 'Bir limon kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 15,
    summary: 'Sesini duyabiliyor, ışığı algılamaya başladı.',
    sizeText: 'Bir elma kadar.',
    fruit: FruitShape.apple,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 16,
    summary: 'Minik kasları güçleniyor, ilk tekmeler yakın.',
    sizeText: 'Bir avokado kadar.',
    fruit: FruitShape.avocado,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 17,
    summary: 'Yağ depolamaya başladı, derisi pürüzsüzleşiyor.',
    sizeText: 'Bir armut kadar.',
    fruit: FruitShape.pear,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 18,
    summary: 'Esniyor, hıçkırıyor — yakında sen de hissedeceksin.',
    sizeText: 'Bir dolmalık biber kadar.',
    fruit: FruitShape.pepper,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 19,
    summary: 'Vücudunu koruyan vernix tabakası oluştu.',
    sizeText: 'Bir domates kadar.',
    fruit: FruitShape.apple,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 20,
    summary: 'Yarı yoldasın! Bebek artık seni net duyuyor.',
    sizeText: 'Bir muz kadar.',
    fruit: FruitShape.banana,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 21,
    summary: 'Yutkunma hareketleri yapıyor, sindirimi çalışıyor.',
    sizeText: 'Bir havuç kadar.',
    fruit: FruitShape.carrot,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 22,
    summary: 'Kaş ve kirpikleri belirginleşti.',
    sizeText: 'Bir kabak kadar.',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fetus,
  ),
  PregnancyWeekInfo(
    week: 23,
    summary: 'Derisi hâlâ buruşuk ama hızla kilo alıyor.',
    sizeText: 'Bir greyfurt kadar.',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 24,
    summary: 'Akciğerleri nefes almaya hazırlanıyor.',
    sizeText: 'Bir mısır kadar.',
    fruit: FruitShape.corn,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 25,
    summary: 'Saçları belirginleşti, denge duyusu gelişiyor.',
    sizeText: 'Bir karnabahar kadar.',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 26,
    summary: 'Gözlerini açıp kapatabiliyor.',
    sizeText: 'Bir marul kadar.',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 27,
    summary: 'Üçüncü trimester başladı! Beyni hızla gelişiyor.',
    sizeText: 'Bir salatalık kadar.',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 28,
    summary: 'Rüya görebiliyor, gözleri ışığa tepki veriyor.',
    sizeText: 'Bir patlıcan kadar.',
    fruit: FruitShape.eggplant,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 29,
    summary: 'Kasları ve akciğerleri olgunlaşmaya devam ediyor.',
    sizeText: 'Bir bal kabağı kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 30,
    summary: 'Beynindeki kıvrımlar artıyor — daha da akıllı :)',
    sizeText: 'Bir lahana kadar.',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 31,
    summary: 'Tüm duyuları çalışıyor, hızla kilo alıyor.',
    sizeText: 'Bir hindistan cevizi kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.plumpFetus,
  ),
  PregnancyWeekInfo(
    week: 32,
    summary: 'Tırnakları parmak uçlarına ulaştı.',
    sizeText: 'Bir kereviz kadar.',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 33,
    summary: 'Kemikleri sertleşiyor, kafatası hâlâ yumuşacık.',
    sizeText: 'Bir ananas kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 34,
    summary: 'Bağışıklık sistemi gelişiyor, doğuma hazırlanıyor.',
    sizeText: 'Bir kavun kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 35,
    summary: 'Böbrekleri tam gelişti, hızla yağlanıyor.',
    sizeText: 'Bir bal kabağı kadar.',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 36,
    summary: 'Doğum pozisyonuna geçiyor, başı aşağıda.',
    sizeText: 'Bir marul kadar.',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 37,
    summary: 'Erken term sayılır — artık her an hazır.',
    sizeText: 'Bir pazı demeti kadar.',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 38,
    summary: 'Organları tamamen olgun, kavrama refleksi güçlü.',
    sizeText: 'Bir pırasa kadar.',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 39,
    summary: 'Doğuma çok az kaldı, son rötuşlar yapılıyor.',
    sizeText: 'Küçük bir karpuz kadar.',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
  ),
  PregnancyWeekInfo(
    week: 40,
    summary: 'Hoş geldin günü çok yakın! Bebek tamamen hazır.',
    sizeText: 'Bir karpuz kadar.',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
  ),
];

/// Verilen hafta için gelişim bilgisini döndürür (1..40 arası kırpılır).
PregnancyWeekInfo pregnancyWeekInfo(int week) {
  final w = week.clamp(1, 40).toInt();
  return kPregnancyWeeks[w - 1];
}

// ─────────────────────────────────────────────
// Kilometre taşları (Önemli Günler)
// ─────────────────────────────────────────────

/// Kilometre taşı kategorisi — takvim noktası ve kart rengini belirler.
enum MilestoneCategory { folicAcid, fertilization, implantation, test, organ, heartbeat }

extension MilestoneCategoryX on MilestoneCategory {
  Color get color {
    switch (this) {
      case MilestoneCategory.folicAcid:
        return const Color(0xFFEC4899); // pembe
      case MilestoneCategory.fertilization:
        return const Color(0xFF3B82F6); // mavi
      case MilestoneCategory.implantation:
        return const Color(0xFFE11D48); // kırmızı
      case MilestoneCategory.test:
        return const Color(0xFF9333EA); // mor
      case MilestoneCategory.organ:
        return const Color(0xFF14B8A6); // turkuaz
      case MilestoneCategory.heartbeat:
        return const Color(0xFFF97316); // turuncu
    }
  }
}

class PregnancyMilestone {
  final String title;
  final String description;
  final MilestoneCategory category;
  // LMP'den itibaren gün aralığı (her iki uç dahil).
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

/// LMP'ye göre sabit kilometre taşı tanımları.
/// Tarihler tıbbi olarak yaklaşıktır; takip amaçlıdır.
const List<PregnancyMilestone> kMilestones = [
  PregnancyMilestone(
    title: 'Folik asit kullanımı',
    description:
        'Bebeğin nöral tüpünün sağlıklı gelişimi için bu dönemde folik asit '
        'almak çok önemli. Doktorunun önerdiği dozu aksatma.',
    category: MilestoneCategory.folicAcid,
    startDayOffset: 0,
    endDayOffset: 90, // ~12. hafta sonuna kadar
  ),
  PregnancyMilestone(
    title: 'Döllenme',
    description:
        'Sperm ve yumurta buluştu — minicik bir hücre yolculuğuna başladı. :)',
    category: MilestoneCategory.fertilization,
    startDayOffset: 13,
    endDayOffset: 15,
  ),
  PregnancyMilestone(
    title: 'Rahme tutunma',
    description:
        'Döllenmiş yumurta rahim duvarına tutundu. Gebelik resmen başladı!',
    category: MilestoneCategory.implantation,
    startDayOffset: 20,
    endDayOffset: 24,
  ),
  PregnancyMilestone(
    title: 'Gebelik testinde çıkması',
    description:
        'hCG hormonu artık testte görülecek kadar yükseldi. Müjdeli haber zamanı!',
    category: MilestoneCategory.test,
    startDayOffset: 27,
    endDayOffset: 31,
  ),
  PregnancyMilestone(
    title: 'Organ gelişim dönemi',
    description:
        'Bebeğin hayati organlarının temeli bu haftalarda atılıyor. '
        'İlaç ve beslenmene özen göstermenin en kritik dönemi.',
    category: MilestoneCategory.organ,
    startDayOffset: 28,
    endDayOffset: 70, // ~5-10. haftalar
  ),
  PregnancyMilestone(
    title: 'İlk kalp atışı',
    description:
        'Minik kalp atmaya başladı! Ultrasonda bu haftalarda duyulabilir.',
    category: MilestoneCategory.heartbeat,
    startDayOffset: 38,
    endDayOffset: 44,
  ),
];

/// Verilen takvim gününe denk gelen kilometre taşlarını döndürür.
/// [lmp] null ise boş liste döner.
List<PregnancyMilestone> milestonesForDate(DateTime date, DateTime? lmp) {
  if (lmp == null) return const [];
  final d0 = DateTime(lmp.year, lmp.month, lmp.day);
  final d1 = DateTime(date.year, date.month, date.day);
  final offset = d1.difference(d0).inDays;
  return kMilestones
      .where((m) => offset >= m.startDayOffset && offset <= m.endDayOffset)
      .toList();
}

/// Verilen takvim gününün gebelik haftası (1..40). LMP yoksa null.
int? pregnancyWeekForDate(DateTime date, DateTime? lmp) {
  if (lmp == null) return null;
  final d0 = DateTime(lmp.year, lmp.month, lmp.day);
  final d1 = DateTime(date.year, date.month, date.day);
  final days = d1.difference(d0).inDays;
  if (days < 0) return null;
  final week = (days ~/ 7) + 1;
  if (week < 1) return 1;
  if (week > 40) return 40;
  return week;
}
