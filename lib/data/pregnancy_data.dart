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
  final String heightText; // ör. "1 mm" / "3 cm" / "52 cm"
  final String weightText; // ör. "< 0,1 gr" / "4 gr" / "3.500 gr"
  final String motherInfo; // Annedeki değişimler ve önemli bilgiler

  const PregnancyWeekInfo({
    required this.week,
    required this.summary,
    required this.sizeText,
    required this.fruit,
    required this.stage,
    this.heightText = '',
    this.weightText = '',
    this.motherInfo = '',
  });
}

const List<PregnancyWeekInfo> kPregnancyWeeks = [
  PregnancyWeekInfo(
    week: 1,
    summary: 'Henüz embriyo yoktur. Gebelik, son adet tarihi (SAT) ilk gününden '
        'hesaplandığı için bu hafta rahim dökülür ve yeniden kalınlaşarak '
        'gebeliğe hazırlanır.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
    heightText: '< 0,001 mm',
    weightText: '< 0,001 gr',
    motherInfo: 'Folik asit takviyesi (400–800 mcg/gün) kritik öneme sahiptir — '
        'nöral tüp defektlerini önler. Sigara, alkol ve zararlı ilaçlardan '
        'uzak durulmalıdır. Dengeli beslenme ve düzenli uyku gebelik için '
        'uygun zemin hazırlar.',
  ),
  PregnancyWeekInfo(
    week: 2,
    summary: 'Ovulasyon gerçekleşir; yumurta folikülden serbest bırakılır ve '
        'fallop tüpüne geçer. Spermle karşılaşma olursa döllenme başlayacaktır. '
        'Döllenme için en uygun dönem.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
    heightText: '< 0,01 mm',
    weightText: '< 0,001 gr',
    motherInfo: 'Yumurtlama belirtileri: servikal mukusun berrak ve esnek hale '
        'gelmesi, hafif kasık ağrısı (mittelschmerz), cinsel istekte artış. '
        'Kafein tüketimi sınırlanmalıdır (günde < 200 mg). Gebelik isteyen '
        'çiftler için bu hafta en uygun zamandır.',
  ),
  PregnancyWeekInfo(
    week: 3,
    summary: 'Sperm ile yumurta birleşerek 46 kromozomlu zigot oluştu! '
        'Hızla bölünerek morula ve ardından blastosist halini alır; '
        'fallop tüpünden rahme doğru ilerliyor.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
    heightText: '< 0,1 mm',
    weightText: '< 0,01 gr',
    motherInfo: 'Kadın henüz gebeliğini hissetmez. Döllenmeden 6–10 gün sonra '
        'hafif lekelenme (implantasyon kanaması) görülebilir. Progesteron '
        'artışına bağlı göğüs hassasiyeti, hafif yorgunluk veya duygusal '
        'dalgalanmalar olabilir.',
  ),
  PregnancyWeekInfo(
    week: 4,
    summary: 'Blastosist endometriuma tutundu — implantasyon gerçekleşti! '
        'Plasentanın ilk hücresel temelleri atılıyor. Embriyo yaklaşık '
        '1 mm boyutundadır ve hCG hormonu salgılamaya başladı.',
    sizeText: 'bir haşhaş tohumu büyüklüğünde',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.cellCluster,
    heightText: '0,1 mm',
    weightText: '< 0,1 gr',
    motherInfo: 'Adet gecikmesi başlar, gebelik testleri pozitif. Göğüslerde '
        'dolgunluk, sabah bulantıları, halsizlik görülebilir. İlaç kullanımı '
        'mutlaka doktor kontrolünde olmalı; alkol, sigara ve toksik maddelerden '
        'kesinlikle uzak durulmalıdır.',
  ),
  PregnancyWeekInfo(
    week: 5,
    summary: 'Embriyo ultrasonla görülebilecek kadar gelişti (≈1,5–2 mm). '
        'Kalp tüpü atmaya başladı — ilk fonksiyonel organ! Nöral tüp hızla '
        'gelişiyor; beyin, omurilik ve omurga taslakları şekilleniyor.',
    sizeText: 'bir pirinç tanesi büyüklüğünde',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.embryoTadpole,
    heightText: '1 mm',
    weightText: '< 0,1 gr',
    motherInfo: 'β-hCG düzeyleri hızla artıyor, gebelik testleri kuvvetle '
        'pozitif. Sabah bulantıları, göğüslerde hassasiyet ve yorgunluk '
        'başlayabilir. Nöral tüp kapanması 5–6. haftada tamamlandığından '
        'folik asit alımı çok kritiktir.',
  ),
  PregnancyWeekInfo(
    week: 6,
    summary: 'Embriyo ≈4–6 mm. Kalp atımları dakikada 100–120 olup '
        'ultrasonla saptanabilir! Kol ve bacak tomurcukları oluştu, '
        'yüz hatlarının temeli atılıyor.',
    sizeText: 'bir bezelye büyüklüğünde',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
    heightText: '4 mm',
    weightText: '0,5 gr',
    motherInfo: 'Bulantı-kusma en belirgin şikâyet (hiperemezis gravidarum '
        'riskine dikkat). Sık idrara çıkma ve halsizlik görülebilir. İlk '
        'gebelik muayenesi planlanır: kan grubu, tam kan sayımı, enfeksiyon '
        'taramaları. Doktor ultrasonla kalp atışını doğrular.',
  ),
  PregnancyWeekInfo(
    week: 7,
    summary: 'Embriyo 8–10 mm\'ye ulaştı. Kollar ve bacaklar daha belirgin, '
        'parmak taslakları görülmeye başladı. Beyin gelişimi hızlanıyor, '
        'sindirim sistemi ve akciğer taslakları oluşuyor.',
    sizeText: 'bir yaban mersini büyüklüğünde',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
    heightText: '11 mm',
    weightText: '1 gr',
    motherInfo: 'Gebelik belirtileri şiddetlenebilir: bulantı, koku hassasiyeti, '
        'yorgunluk. Progesteron artışı nedeniyle kabızlık görülebilir. Anne '
        'adayı ruhsal dalgalanmalar yaşayabilir; sosyal destek çok önemlidir.',
  ),
  PregnancyWeekInfo(
    week: 8,
    summary: 'Embriyo ≈14–16 mm. Yüz yapıları (göz kapakları, burun ucu) '
        'belirginleşiyor, kulak kepçesi gelişiyor. İç organların (karaciğer, '
        'böbrek, mide) temel yapıları oluştu.',
    sizeText: 'bir kiraz büyüklüğünde',
    fruit: FruitShape.raspberry,
    stage: EmbryoStage.embryoTadpole,
    heightText: '16 mm',
    weightText: '1 gr',
    motherInfo: 'Gebelik belirtileri devam eder. Rahim portakal büyüklüğüne '
        'ulaşır. Anne adaylarına dengeli beslenme çok önemlidir: demir, '
        'kalsiyum ve omega-3 alımı desteklenmelidir.',
  ),
  PregnancyWeekInfo(
    week: 9,
    summary: 'Resmi olarak "fetus" adını aldı (≈2,5 cm)! Baş vücudun yarısı '
        'kadardır, yüz hatları belirginleşiyor. Kalp dört odacıklı yapıya '
        'yaklaşarak dakikada 140–160 kez atıyor.',
    sizeText: 'bir yeşil zeytin büyüklüğünde',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.fetus,
    heightText: '23 mm',
    weightText: '2 gr',
    motherInfo: 'Bulantı, koku hassasiyeti ve yorgunluk devam edebilir. '
        'Hormonal değişikliklere bağlı ciltte yağlanma veya akne görülebilir. '
        'İlk trimester tarama testleri için planlama yapılır.',
  ),
  PregnancyWeekInfo(
    week: 10,
    summary: 'Fetus ≈3–4 cm, 4–5 gram. Diş tomurcukları ve tırnak temelleri '
        'atıldı. Böbrekler çalışmaya başladı, parmaklar netleşti, '
        'sinir sistemi ilk refleksleri oluşturuyor.',
    sizeText: 'bir çilek büyüklüğünde',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.fetus,
    heightText: '3 cm',
    weightText: '4 gr',
    motherInfo: 'Karn dışarıdan henüz çok belirgin değil. Bulantılar '
        'hafifleyebilir, iştah artışı başlayabilir. Bu haftadan itibaren '
        'NIPT (Non-invaziv Prenatal Test) uygulanabilir — kromozomal '
        'anomaliler için önemli bir tarama.',
  ),
  PregnancyWeekInfo(
    week: 11,
    summary: 'Fetus ≈4–5 cm, 7–8 gram. El ve ayak parmakları tamamen '
        'ayrılmış, hareketler aktifleşti. Karaciğer kırmızı kan hücreleri '
        'üretiyor, dış genital organ farklılaşmaya başlıyor.',
    sizeText: 'bir zencefil kökü büyüklüğünde',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.plumpFetus,
    heightText: '4 cm',
    weightText: '7 gr',
    motherInfo: 'Halsizlik ve baş dönmesi görülebilir — artan kan hacmine '
        'bağlı. Kan basıncı biraz düşebilir; sıvı alımı önemlidir. Ense '
        'kalınlığı (nuchal translucency) ölçümü ve ikili test için '
        'hazırlık yapılır.',
  ),
  PregnancyWeekInfo(
    week: 12,
    summary: 'Fetus ≈5–6 cm, 14 gram. Yüz hatları belirginleşti, '
        'tırnaklar görülmeye başladı. Sindirim hareketleri (peristaltizm) '
        'başladı, fetus amniyon sıvısını yutuyor.',
    sizeText: 'bir limon büyüklüğünde',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.plumpFetus,
    heightText: '6 cm',
    weightText: '14 gr',
    motherInfo: 'Bulantı ve kusmalar genellikle azalır, enerji artar. İkili '
        'test (ense kalınlığı + PAPP-A ve β-hCG) yapılır — Down sendromu '
        'gibi kromozomal anomaliler için önemli tarama. Düşük riski bu '
        'haftadan sonra belirgin şekilde azalır.',
  ),
  PregnancyWeekInfo(
    week: 13,
    summary: 'İkinci trimester başladı! Fetus ≈7–8 cm, 20–25 gram. '
        'Parmak izleri oluştu, karaciğer safra üretiyor, pankreas insülin '
        'salgılıyor. Ses telleri gelişiyor.',
    sizeText: 'bir yeşil elma büyüklüğünde',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '8 cm',
    weightText: '23 gr',
    motherInfo: 'Bulantı ve halsizlik azalır, enerji artar. Rahim kasık '
        'kemiğinin üzerine çıktı, karın belirginleşiyor. İlk trimester '
        'taramaları bu hafta sonuna kadar tamamlanmalıdır.',
  ),
  PregnancyWeekInfo(
    week: 14,
    summary: 'Fetus ≈8–9 cm, 40–45 gram. Yüz kasları gelişti; kaş çatma, '
        'göz kırpma gibi ifadeler yapabiliyor. Tiroid bezi aktifleşti, '
        'lanugo (ince tüyler) çıkmaya başladı.',
    sizeText: 'bir şeftali büyüklüğünde',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '9 cm',
    weightText: '43 gr',
    motherInfo: 'Anne adayı daha rahat hisseder, iştah artar. Kabızlık ve '
        'mide yanması görülebilir. Cilt değişiklikleri (linea nigra, melazma) '
        'başlayabilir. Düzenli egzersiz (yürüyüş, yüzme, yoga) önerilir.',
  ),
  PregnancyWeekInfo(
    week: 15,
    summary: 'Fetus ≈10 cm, 70–80 gram. Kemikler kalsiyum depolamaya '
        'başladı. Kulaklar işitmeye hazırlanıyor, dışarıdan gelen seslere '
        'duyarlı hale geliyor.',
    sizeText: 'bir kırmızı elma büyüklüğünde',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '10 cm',
    weightText: '70 gr',
    motherInfo: 'Karnın büyümesi hızlanıyor, kıyafetlerde değişiklik '
        'gerekebilir. Baş ağrısı ve gebelik riniti (burun tıkanıklığı) '
        'görülebilir. İkinci trimester tarama testleri planlanır: üçlü '
        'veya dörtlü test. Demir ve kalsiyum desteği başlanabilir.',
  ),
  PregnancyWeekInfo(
    week: 16,
    summary: 'Fetus ≈11–12 cm, 100 gram. Hareketler daha koordineli; '
        'anne bazı durumlarda ilk hareketleri hissedebilir. Kalp dakikada '
        '150–160 atım yapıyor, stetoskopla duyulabilir.',
    sizeText: 'bir avokado büyüklüğünde',
    fruit: FruitShape.avocado,
    stage: EmbryoStage.matureFetus,
    heightText: '11 cm',
    weightText: '100 gr',
    motherInfo: 'Karnın büyümesi hızlanıyor, karın çizgisi (linea nigra) '
        'belirginleşebilir. Bebek hareketleri hissedilebilir — özellikle '
        'ikinci gebeliklerde daha erken. Psikolojik olarak daha dengeli '
        'bir dönem.',
  ),
  PregnancyWeekInfo(
    week: 17,
    summary: 'Fetus ≈12–13 cm, 140–150 gram. Isı regülasyonu için kahverengi '
        'yağ dokusu oluşuyor. Bebek seslere duyarlı; annenin kalp atışlarını '
        've dış sesleri işitmeye başladı.',
    sizeText: 'bir armut büyüklüğünde',
    fruit: FruitShape.apple,
    stage: EmbryoStage.matureFetus,
    heightText: '13 cm',
    weightText: '140 gr',
    motherInfo: 'Karnın büyümesi belirginleşiyor, ağırlık merkezi değişiyor. '
        'Bel ve sırt ağrıları görülebilir. Gebelik hormonlarına bağlı burun '
        've diş eti kanamaları yaşanabilir. İştah artışı sürer.',
  ),
  PregnancyWeekInfo(
    week: 18,
    summary: 'Fetus ≈14 cm, 190 gram. Parmak izleri netleşti, dış genital '
        'organlar belirginleşti. Sindirim sistemi mekoniyum (ilk dışkı) '
        'üretmeye başladı.',
    sizeText: 'bir soğan büyüklüğünde',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
    heightText: '14 cm',
    weightText: '195 gr',
    motherInfo: 'İlk bebek hareketleri net şekilde hissedilebilir (ilk '
        'gebelikse genellikle 18–20. hafta). Denge sorunları ve baş '
        'dönmeleri görülebilir. Ayrıntılı ultrason (detaylı tarama) için '
        'hazırlık yapılır.',
  ),
  PregnancyWeekInfo(
    week: 19,
    summary: 'Fetus ≈15 cm, 240 gram. Vernix caseosa adlı koruyucu tabaka '
        'oluştu. Tat tomurcukları gelişti — bebek amniyon sıvısının tadını '
        'hissedebilir.',
    sizeText: 'bir mango büyüklüğünde',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
    heightText: '15 cm',
    weightText: '240 gr',
    motherInfo: 'Karın belirginleşti. Mide ekşimesi, reflü ve kabızlık '
        'görülebilir. Ciltte çatlaklar (stria gravidarum) oluşmaya başlayabilir. '
        'İkinci trimester tarama testleri ve ayrıntılı ultrason planlanır.',
  ),
  PregnancyWeekInfo(
    week: 20,
    summary: 'Fetus ≈16 cm, 300 gram — gebeliğin tam ortası! Kalp '
        'stetoskopla duyulabilir. Saçlar, kaşlar ve kirpikler çıkıyor; '
        'beyin duyusal alanları hızla gelişiyor.',
    sizeText: 'bir muz büyüklüğünde',
    fruit: FruitShape.banana,
    stage: EmbryoStage.matureFetus,
    heightText: '16 cm',
    weightText: '300 gr',
    motherInfo: 'Bebek hareketleri günlük hissediliyor. Rahim göbek hizasına '
        'ulaştı. Ayrıntılı ultrason (ikinci trimester morfoloji taraması) bu '
        'hafta yapılır — kalp, beyin, omurga, böbrekler ayrıntılı incelenir. '
        'Preeklampsi riskine karşı kan basıncı takip edilmeli.',
  ),
  PregnancyWeekInfo(
    week: 21,
    summary: 'Fetus ≈18 cm, 350 gram. Sindirim sistemi çalışıyor, bebek '
        'yutkunuyor. Tat duyusu gelişti — annenin yediği besinlerin '
        'tatlarını dolaylı olarak hissedebilir.',
    sizeText: 'bir havuç büyüklüğünde',
    fruit: FruitShape.apple,
    stage: EmbryoStage.matureFetus,
    heightText: '27 cm',
    weightText: '360 gr',
    motherInfo: 'Bebek hareketleri artık net ve düzenli. Mide ekşimesi ve '
        'reflü şikâyetleri artabilir. Sırt ve bel ağrıları daha belirgin. '
        'Günlük demir ihtiyacı artar; demir desteği başlanabilir.',
  ),
  PregnancyWeekInfo(
    week: 22,
    summary: 'Fetus ≈19 cm, 430–450 gram. Dudaklar ve göz kapakları '
        'belirginleşti. Erkek fetüslerde testisler aşağıya inmeye başladı. '
        'Kaslar güçleniyor, tekmeler daha kuvvetli.',
    sizeText: 'bir patates büyüklüğünde',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
    heightText: '28 cm',
    weightText: '430 gr',
    motherInfo: 'Karın büyümesi hızlanıyor, ciltte çatlaklar gelişebilir. '
        'Duruş değişiklikleri bel ağrılarını artırabilir. Cilt güneş '
        'lekelerine (melazma) daha yatkın. Sırt kaslarını destekleyen '
        'aktiviteler önerilir.',
  ),
  PregnancyWeekInfo(
    week: 23,
    summary: 'Fetus ≈20 cm, 500–520 gram. Akciğerlerde alveol yapıları '
        'oluşmaya başladı. Kulaklar dış seslere duyarlılaştı; '
        'uyku–uyanıklık döngüleri başladı.',
    sizeText: 'bir domates büyüklüğünde',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '29 cm',
    weightText: '500 gr',
    motherInfo: 'Rahim göbek hizasının birkaç parmak üzerinde. İştah '
        'artıyor, kilo alımı hızlanabilir. Ellerde ve ayaklarda şişlik '
        '(ödem) başlayabilir. Gestasyonel diyabet tarama testi için '
        'planlama yapılır.',
  ),
  PregnancyWeekInfo(
    week: 24,
    summary: '"Yaşam sınırı" (viabilite) dönemi! Fetus ≈21 cm, 600 gram. '
        'Akciğerlerde sürfaktan üretimi başladı. Yoğun bakım şartlarında '
        'hayatta kalma artık mümkün.',
    sizeText: 'bir mısır koçanı büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.matureFetus,
    heightText: '30 cm',
    weightText: '600 gr',
    motherInfo: 'Karnın büyümesi belirgin, nefes darlığı artabilir. Bel ve '
        'kasık ağrıları daha sık. Uyku problemleri başlayabilir. 24–28. '
        'haftalar arasında gestasyonel diyabet taraması yapılır. '
        'Düzenli su içmek ve sağlıklı beslenmek kritik önem taşır.',
  ),
  PregnancyWeekInfo(
    week: 25,
    summary: 'Fetus ≈22 cm, 700–750 gram. Solunum hareketleri prova '
        'ediliyor. Omurga ve sinir bağlantıları olgunlaşıyor. '
        'Bebek ışık ve sese daha net tepki veriyor.',
    sizeText: 'bir brokoli büyüklüğünde',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.matureFetus,
    heightText: '35 cm',
    weightText: '660 gr',
    motherInfo: 'Karın iyice belirginleşti, rahim göğüs kafesine yaklaşıyor. '
        'Nefes darlığı, mide ekşimesi sıklaşabilir. Braxton Hicks kasılmaları '
        'başlayabilir. Düzenli kan basıncı ve idrar takibi önemlidir.',
  ),
  PregnancyWeekInfo(
    week: 26,
    summary: 'Fetus ≈23 cm, 850 gram. Göz kapakları açılıp kapanmaya '
        'başladı, retina ışığa duyarlı. Bebek uyku ve uyanıklık '
        'döngülerine giriyor.',
    sizeText: 'bir marul büyüklüğünde',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.matureFetus,
    heightText: '36 cm',
    weightText: '760 gr',
    motherInfo: 'Uyku problemleri artabilir; sık idrara çıkma ve karın '
        'büyümesi nedeniyle. Sırt ve bel ağrıları, bacak krampları sık. '
        'Kan hacmi arttığı için demir ihtiyacı yüksektir, demir desteği '
        'şarttır.',
  ),
  PregnancyWeekInfo(
    week: 27,
    summary: 'Üçüncü trimester başladı! Fetus ≈24 cm, 950–1000 gram. '
        'Beyin kıvrımları (gyri ve sulci) belirginleşiyor. '
        'Bebek hıçkırık refleksleri gösterebilir.',
    sizeText: 'bir dolmalık biber büyüklüğünde',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.matureFetus,
    heightText: '37 cm',
    weightText: '875 gr',
    motherInfo: 'Anne adayı daha ağır hisseder, hızlı yorulabilir. El ve '
        'ayaklarda ödem artabilir; tuz kısıtlaması faydalıdır. 24–28. hafta '
        'glukoz yükleme testi (50 g) yapılır. Yüksek çıkarsa 100 g OGTT '
        'ile tanı konur.',
  ),
  PregnancyWeekInfo(
    week: 28,
    summary: 'Fetus ≈25 cm, 1.100–1.200 gram. Gözler tamamen açılıp '
        'kapanabiliyor, ışığa tepki veriyor. Beyin sinir ağları karmaşık '
        'hale geliyor; öğrenme ve hafıza temelleri oluşuyor.',
    sizeText: 'bir patlıcan büyüklüğünde',
    fruit: FruitShape.eggplant,
    stage: EmbryoStage.matureFetus,
    heightText: '38 cm',
    weightText: '1.000 gr',
    motherInfo: 'Rahim göğüs kafesine dayanıyor, nefes darlığı sıklaşabilir. '
        'Bacaklarda varisler ve ödem artar. Rh(-) anne adaylarına anti-D '
        'immünglobulin yapılır. Doğum planlaması ve doğum yöntemleri '
        'konuşulmaya başlanabilir.',
  ),
  PregnancyWeekInfo(
    week: 29,
    summary: 'Fetus ≈26 cm, 1.250–1.300 gram. Kaslar hızla güçleniyor, '
        'tekme ve dönme hareketleri kuvvetli. Ciltteki kırışıklıklar '
        'yağ depolanmasıyla yavaş yavaş azalıyor.',
    sizeText: 'bir hindistan cevizi büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '39 cm',
    weightText: '1.150 gr',
    motherInfo: 'Yorgunluk, nefes darlığı ve bel ağrısı sıklaşıyor. Uyku '
        'problemleri belirginleşiyor. Braxton Hicks kasılmaları artabilir. '
        'Erken doğum riski olan anneler yakından takip edilir.',
  ),
  PregnancyWeekInfo(
    week: 30,
    summary: 'Fetus ≈27 cm, 1.400–1.500 gram. Akciğerler daha olgunlaşmış; '
        'erken doğumda yaşam şansı yüksek. Bebek uyku–uyanıklık döngülerine '
        'daha düzenli giriyor.',
    sizeText: 'bir salatalık büyüklüğünde',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
    heightText: '40 cm',
    weightText: '1.320 gr',
    motherInfo: 'Rahim göğüs kafesine baskı yapıyor, nefes almak zorlaşıyor. '
        'Sırt ağrıları ve bacak krampları sık. Ciltte kaşıntılar ve çatlaklar '
        'artabilir. Bu haftadan itibaren doktor kontrolleri 2 haftada bir '
        'yapılır.',
  ),
  PregnancyWeekInfo(
    week: 31,
    summary: 'Fetus ≈28 cm, 1.600–1.700 gram. Sinir sistemi hızla olgunlaşıyor. '
        'Akciğerler sürfaktan üretimi sayesinde dış yaşam için giderek hazır '
        'hale geliyor.',
    sizeText: 'bir ananas büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '41 cm',
    weightText: '1.500 gr',
    motherInfo: 'Anne adayı karnının ağırlığını yoğun hissediyor. Varisler '
        've ödem artabilir. Uyku problemleri devam ediyor. Doğuma hazırlık '
        'eğitimi ve nefes egzersizleri önerilir.',
  ),
  PregnancyWeekInfo(
    week: 32,
    summary: 'Fetus ≈29 cm, 1.800–2.000 gram. Cilt altı yağ dokusu '
        'belirginleşti — bebek daha yuvarlak görünüyor. Çoğu bebek baş '
        'aşağı (sefalik) pozisyona geçiyor.',
    sizeText: 'bir portakal büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '42 cm',
    weightText: '1.700 gr',
    motherInfo: 'Sık idrara çıkma, mide ekşimesi ve nefes darlığı arttı. '
        'NST (Non-Stres Test) ve fetal iyilik değerlendirmeleri başlayabilir. '
        'Yalancı kasılmalar daha belirgin. Erken doğum tehdidinde akciğer '
        'olgunlaştırıcı kortikosteroidler uygulanabilir.',
  ),
  PregnancyWeekInfo(
    week: 33,
    summary: 'Fetus ≈30 cm, 2.100–2.200 gram. Beyin gelişimi çok hızlı; '
        'anne plasentadan antikor geçişiyle bebek bağışıklık kazanıyor. '
        'Bebek güçlü hareketler yapıyor.',
    sizeText: 'bir kavun büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '44 cm',
    weightText: '1.920 gr',
    motherInfo: 'Rahim diyaframı yukarı iterek nefes darlığını artırıyor. '
        'Sırt ve bel ağrıları şiddetlenebilir. Braxton Hicks kasılmaları '
        'daha sık ve belirgin. Doğum çantası hazırlıklarına başlanmalıdır.',
  ),
  PregnancyWeekInfo(
    week: 34,
    summary: 'Fetus ≈31 cm, 2.300–2.400 gram. Yağ depolanması hızlandı, '
        'bebek daha tombul. Akciğerler büyük ölçüde gelişti; erken '
        'doğumda yaşam şansı yüksek.',
    sizeText: 'bir üzüm salkımı büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '45 cm',
    weightText: '2.145 gr',
    motherInfo: 'Sol yan yatış önerilir. Bacak krampları ve varisler sık. '
        'Vajinal kanama veya su gelmesi erken doğum belirtisi olabilir. '
        'Doktor kontrolleri haftalık veya iki haftada bir yapılabilir.',
  ),
  PregnancyWeekInfo(
    week: 35,
    summary: 'Fetus ≈32 cm, 2.500–2.600 gram. Sinir sistemi olgun, '
        'refleksler güçlü. Vernix caseosa ve lanugo azalıyor; doğuma '
        'yakın kaybolacak.',
    sizeText: 'büyük bir patates büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '46 cm',
    weightText: '2.380 gr',
    motherInfo: 'Sık yorgunluk, uyku düzeni bozulabilir. Braxton Hicks '
        'kasılmaları daha düzenli — gerçek doğum sancılarıyla '
        'karıştırılmamalıdır. Doktor bebeğin duruşunu (sefalik, makat vb.) '
        'değerlendirir.',
  ),
  PregnancyWeekInfo(
    week: 36,
    summary: 'Fetus ≈33 cm, 2.700–2.800 gram. Akciğerler neredeyse '
        'tamamen olgunlaştı. Çoğu bebek baş aşağı (vertex) pozisyonunda; '
        'kilo alımı haftada ≈200–250 gram.',
    sizeText: 'büyük bir lahana büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '48 cm',
    weightText: '2.650 gr',
    motherInfo: 'Rahim göğüs kafesinden biraz aşağıya iner; nefes darlığı '
        'azalır ama sık idrara çıkma artar. Pelvik bölgede baskı artar, '
        'yürümek zorlaşabilir. Bu haftadan itibaren doğum her an başlayabilir.',
  ),
  PregnancyWeekInfo(
    week: 37,
    summary: '"Miadında" kabul edilir — doğuma hazır! Fetus ≈34 cm, '
        '2.900–3.000 gram. Akciğerler, karaciğer ve böbrekler olgunlaşmış. '
        'Bebek doğum kanalına yerleşiyor.',
    sizeText: 'uzun bir mısır koçanı büyüklüğünde',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
    heightText: '49 cm',
    weightText: '2.850 gr',
    motherInfo: 'Rahim alt karına inmiş, nefes almak kolaylaşır. Pelvik '
        'bölgede baskı ve bacak arası ağrılar olabilir. Braxton Hicks '
        'kasılmaları gerçek doğum sancılarıyla karışabilir. Doğum çantası '
        'hazır olmalıdır.',
  ),
  PregnancyWeekInfo(
    week: 38,
    summary: 'Fetus ≈35 cm, 3.100–3.200 gram. Yağ depolanması tamamlandı; '
        'vücut yuvarlak ve dolgun. Vernix ve lanugo büyük ölçüde kayboldu. '
        'Sinir sistemi ve beyin gelişimi devam ediyor.',
    sizeText: 'bir bal kabağı büyüklüğünde',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '50 cm',
    weightText: '3.100 gr',
    motherInfo: 'Vajinal akıntıda artış ve kanlı tıkacın gelmesi doğumun '
        'yaklaştığını gösterebilir. Düzenli, giderek sıklaşan kasılmalar '
        'gerçek doğum sancısıdır. Doktor kontrolleri haftalık yapılır.',
  ),
  PregnancyWeekInfo(
    week: 39,
    summary: 'Fetus ≈36 cm, 3.300–3.400 gram. Tüm organlar olgunlaştı, '
        'doğuma hazır! Plasenta hâlâ bebeğe besin ve oksijen sağlıyor, '
        'bebek doğum kanalına iyice yerleşti.',
    sizeText: 'bir karpuz dilimi büyüklüğünde',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
    heightText: '51 cm',
    weightText: '3.300 gr',
    motherInfo: 'Rahim kasılmaları düzenli hale gelebilir. Su gelmesi '
        '(amniyotik zarların yırtılması) doğumun başladığını gösterebilir. '
        'Doğum korkusu ve heyecanı artabilir; destek çok önemlidir.',
  ),
  PregnancyWeekInfo(
    week: 40,
    summary: 'Fetus ≈37–38 cm, 3.400–3.600 gram. Tüm organ sistemleri '
        'olgun ve dış yaşam için hazır! Kordon ve plasenta bebeğe destek '
        'vermeye devam ediyor.',
    sizeText: 'bir karpuz büyüklüğünde',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
    heightText: '52 cm',
    weightText: '3.500 gr',
    motherInfo: 'Düzenli kasılmalar, su gelmesi ve kanlı tıkacın ayrılması '
        'doğumun başladığını gösterir. Doğum üç evreden oluşur: açılma '
        'evresi, itme ve doğum evresi, plasenta evresi. Doğum başlamadıysa '
        'doktor indüksiyon değerlendirebilir.',
  ),
];

PregnancyWeekInfo pregnancyWeekInfo(int week, {bool isEnglish = false}) {
  final w = week.clamp(1, 40).toInt();
  if (isEnglish) {
    try {
      return kPregnancyWeeksEn.firstWhere((e) => e.week == w);
    } catch (_) {}
  }
  return kPregnancyWeeks[w - 1];
}

// ─────────────────────────────────────────────
// English pregnancy week data
// ─────────────────────────────────────────────
const List<PregnancyWeekInfo> kPregnancyWeeksEn = [
  PregnancyWeekInfo(
    week: 1,
    summary: 'No embryo yet. Pregnancy is counted from the first day of your last period (LMP). The uterus sheds its lining and begins rebuilding to prepare for pregnancy.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
    heightText: '< 0,001 mm',
    weightText: '< 0,001 gr',
    motherInfo: 'Folic acid (400–800 mcg/day) is critical — it prevents neural tube defects. Avoid smoking, alcohol, and harmful medications. A balanced diet and regular sleep lay the foundation for a healthy pregnancy.',
  ),
  PregnancyWeekInfo(
    week: 2,
    summary: 'Ovulation occurs; the egg is released from the follicle into the fallopian tube. If sperm are present, fertilization will begin. This is the optimal window for conception.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
    heightText: '< 0,01 mm',
    weightText: '< 0,001 gr',
    motherInfo: 'Signs of ovulation include clear stretchy cervical mucus, mild pelvic pain (mittelschmerz), and increased libido. Limit caffeine to < 200 mg/day.',
  ),
  PregnancyWeekInfo(
    week: 3,
    summary: 'Sperm and egg unite to form a 46-chromosome zygote! It rapidly divides into a morula, then a blastocyst, traveling from the fallopian tube toward the uterus.',
    sizeText: '',
    fruit: FruitShape.none,
    stage: EmbryoStage.fertilization,
    heightText: '< 0,1 mm',
    weightText: '< 0,01 gr',
    motherInfo: 'No pregnancy symptoms yet. Slight spotting (implantation bleeding) may appear 6–10 days after fertilization. Progesterone rise may cause breast tenderness and mild fatigue.',
  ),
  PregnancyWeekInfo(
    week: 4,
    summary: 'The blastocyst has implanted in the endometrium — implantation is complete! The foundations of the placenta are being laid. The embryo is ~1 mm and has begun secreting hCG hormone.',
    sizeText: 'poppy seed sized',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.cellCluster,
    heightText: '0,1 mm',
    weightText: '< 0,1 gr',
    motherInfo: 'Period delay begins; pregnancy tests turn positive. Breast fullness, morning nausea, and fatigue may appear. All medications must be supervised by a doctor; avoid alcohol and cigarettes.',
  ),
  PregnancyWeekInfo(
    week: 5,
    summary: 'The embryo is visible on ultrasound (≈1.5–2 mm). The heart tube has begun beating — the first functional organ! The neural tube is developing rapidly; brain, spinal cord, and spine are taking shape.',
    sizeText: 'rice grain sized',
    fruit: FruitShape.tinySeed,
    stage: EmbryoStage.embryoTadpole,
    heightText: '1 mm',
    weightText: '< 0,1 gr',
    motherInfo: 'β-hCG levels rise rapidly; tests are strongly positive. Nausea, breast tenderness, and fatigue may begin. Folic acid is critical as neural tube closure completes in weeks 5–6.',
  ),
  PregnancyWeekInfo(
    week: 6,
    summary: 'Embryo ≈4–6 mm. Heart rate is 100–120 bpm, detectable on ultrasound! Arm and leg buds have formed; facial feature foundations are being laid.',
    sizeText: 'pea sized',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
    heightText: '4 mm',
    weightText: '0,5 gr',
    motherInfo: 'Nausea and vomiting are the most common complaints. First prenatal visit planned: blood type, CBC, infection screenings. Doctor confirms heartbeat by ultrasound.',
  ),
  PregnancyWeekInfo(
    week: 7,
    summary: 'Embryo reaches 8–10 mm. Arms and legs are more defined; finger buds are appearing. Brain development is accelerating; digestive system and lung buds are forming.',
    sizeText: 'blueberry sized',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.embryoTadpole,
    heightText: '11 mm',
    weightText: '1 gr',
    motherInfo: 'Symptoms may intensify: nausea, heightened smell sensitivity, fatigue. Progesterone may cause constipation. Mood swings are normal; social support is very important.',
  ),
  PregnancyWeekInfo(
    week: 8,
    summary: 'Embryo ≈14–16 mm. Facial structures (eyelids, nose tip) are becoming defined; ear formation is underway. Basic structures of internal organs (liver, kidneys, stomach) are established.',
    sizeText: 'cherry sized',
    fruit: FruitShape.raspberry,
    stage: EmbryoStage.embryoTadpole,
    heightText: '16 mm',
    weightText: '1 gr',
    motherInfo: 'Symptoms continue. Uterus reaches the size of an orange. Balanced diet rich in iron, calcium, and omega-3 is essential.',
  ),
  PregnancyWeekInfo(
    week: 9,
    summary: 'The embryo is now officially a fetus at ≈22–25 mm! Fingers and toes are distinguishable. Eyes, ears, and a tiny mouth are visible. Muscles and nerves are developing.',
    sizeText: 'olive sized',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.fetus,
    heightText: '23 mm',
    weightText: '2 gr',
    motherInfo: 'Morning sickness may begin to ease. Fatigue continues. The uterus can now be felt on abdominal exam. Regular prenatal care is important.',
  ),
  PregnancyWeekInfo(
    week: 10,
    summary: 'Fetus is ≈30–35 mm. All vital organs are present; growth and maturation begins. External genitalia start developing but sex is not yet visible on ultrasound.',
    sizeText: 'strawberry sized',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.fetus,
    heightText: '3 cm',
    weightText: '4 gr',
    motherInfo: 'First trimester screening (NT measurement, blood tests) should be scheduled. Hair, nails, and taste buds are beginning to form.',
  ),
  PregnancyWeekInfo(
    week: 11,
    summary: 'Fetus is ≈40–45 mm. Bones begin to harden; fingers and toes are fully separated. Diaphragm has formed; baby can make swallowing movements.',
    sizeText: 'ginger root sized',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.plumpFetus,
    heightText: '4 cm',
    weightText: '7 gr',
    motherInfo: 'Nausea and fatigue often begin to ease. Waistline may visibly expand. Good time to discuss genetic screening with your doctor.',
  ),
  PregnancyWeekInfo(
    week: 12,
    summary: 'Fetus is ≈55–60 mm. All major organ systems are formed. Miscarriage risk drops significantly. This marks the end of the first trimester.',
    sizeText: 'lime sized',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.plumpFetus,
    heightText: '6 cm',
    weightText: '14 gr',
    motherInfo: 'First trimester screening should be completed. Many women feel much better as nausea subsides. You may start sharing your pregnancy news!',
  ),
  PregnancyWeekInfo(
    week: 13,
    summary: 'Fetus is ≈65–70 mm, weighing ≈14 g. Face is fully formed; eyes and ears are in their final positions. Fingerprints are forming.',
    sizeText: 'green apple sized',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '8 cm',
    weightText: '23 gr',
    motherInfo: 'Second trimester begins — energy often returns. Round ligament pain may appear as the uterus grows. A visible baby bump starts to show.',
  ),
  PregnancyWeekInfo(
    week: 14,
    summary: 'Fetus is ≈80–85 mm. Facial expressions are possible; the baby can frown and squint. External genitalia are distinguishable on ultrasound.',
    sizeText: 'peach sized',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '9 cm',
    weightText: '43 gr',
    motherInfo: "Baby's sex may be revealed! Second trimester is usually the most comfortable period. Increasing blood volume makes iron-rich foods important.",
  ),
  PregnancyWeekInfo(
    week: 15,
    summary: 'Fetus is ≈95–100 mm. The skeleton is hardening; muscles are strengthening. Hearing begins to develop — baby can detect low-frequency sounds.',
    sizeText: 'apple sized',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '10 cm',
    weightText: '70 gr',
    motherInfo: 'Triple/quad screening may be done this week. Back pain may begin as center of gravity shifts. Gentle prenatal exercise is beneficial.',
  ),
  PregnancyWeekInfo(
    week: 16,
    summary: 'Fetus is ≈110–115 mm. Facial muscles are fully formed; the baby can make expressions. Eyes are closed but can move. The thyroid gland is functioning.',
    sizeText: 'avocado sized',
    fruit: FruitShape.avocado,
    stage: EmbryoStage.matureFetus,
    heightText: '11 cm',
    weightText: '100 gr',
    motherInfo: 'You may start feeling the first baby movements (flutters). Uterus is midway between pubic bone and navel. Detailed ultrasound may be scheduled.',
  ),
  PregnancyWeekInfo(
    week: 17,
    summary: 'Fetus weighs ≈120 g. Vernix caseosa (protective coating) begins to form on the skin. The skeleton is mostly cartilage but gradually hardening.',
    sizeText: 'pear sized',
    fruit: FruitShape.apple,
    stage: EmbryoStage.matureFetus,
    heightText: '13 cm',
    weightText: '140 gr',
    motherInfo: 'Appetite may increase significantly. Heartburn and leg cramps may begin. Sleeping on your side (especially left) is recommended.',
  ),
  PregnancyWeekInfo(
    week: 18,
    summary: 'Fetus is ≈13–14 cm, weighing ≈170 g. Hearing is fully developed — baby responds to sounds. Movements are becoming more defined.',
    sizeText: 'onion sized',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
    heightText: '14 cm',
    weightText: '195 gr',
    motherInfo: 'The detailed anomaly scan is typically performed this week. Movements may start to be felt more clearly.',
  ),
  PregnancyWeekInfo(
    week: 19,
    summary: 'Fetus weighs ≈210 g. The vernix coating thickens. All five senses — taste, smell, sight, hearing, and touch — are developing simultaneously.',
    sizeText: 'mango sized',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
    heightText: '15 cm',
    weightText: '240 gr',
    motherInfo: 'Uterus is now at the level of the navel. Back pain and round ligament pain are common. A pregnancy pillow between the knees helps.',
  ),
  PregnancyWeekInfo(
    week: 20,
    summary: "Fetus is ≈16–17 cm, weighing ≈300 g. Halfway point! Detailed ultrasound checks all organ systems. The baby's movements are clearly felt.",
    sizeText: 'banana sized',
    fruit: FruitShape.banana,
    stage: EmbryoStage.matureFetus,
    heightText: '16 cm',
    weightText: '300 gr',
    motherInfo: 'Halfway there! The detailed anomaly scan this week checks all organ systems. Blood pressure monitoring is important.',
  ),
  PregnancyWeekInfo(
    week: 21,
    summary: 'Fetus weighs ≈350 g. The digestive system practices by swallowing amniotic fluid. Eyebrows and lanugo (fine body hair) are present.',
    sizeText: 'carrot sized',
    fruit: FruitShape.apple,
    stage: EmbryoStage.matureFetus,
    heightText: '27 cm',
    weightText: '360 gr',
    motherInfo: 'Uterus extends above the navel. Leg cramps at night are common. Kegel exercises help prepare the pelvic floor.',
  ),
  PregnancyWeekInfo(
    week: 22,
    summary: 'Fetus is ≈19 cm, weighing ≈430 g. Grip reflex is developing; the baby can grasp the umbilical cord. Lips and eyes are well defined.',
    sizeText: 'potato sized',
    fruit: FruitShape.pear,
    stage: EmbryoStage.matureFetus,
    heightText: '28 cm',
    weightText: '430 gr',
    motherInfo: 'Braxton Hicks contractions (painless practice contractions) may begin. Iron supplementation is especially important.',
  ),
  PregnancyWeekInfo(
    week: 23,
    summary: 'Fetus weighs ≈500 g. Hearing is sharp — baby recognizes familiar voices. Lung development is progressing; breathing movements begin.',
    sizeText: 'tomato sized',
    fruit: FruitShape.citrus,
    stage: EmbryoStage.matureFetus,
    heightText: '29 cm',
    weightText: '500 gr',
    motherInfo: 'The linea nigra (dark vertical line) may appear on the abdomen. Swelling in feet and ankles can occur; elevating legs helps. Prenatal classes may be started.',
  ),
  PregnancyWeekInfo(
    week: 24,
    summary: 'Fetus is ≈21 cm, weighing ≈600 g. Viability threshold — with intensive care support, the baby could survive outside the womb. Lung surfactant production begins.',
    sizeText: 'corn cob sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.matureFetus,
    heightText: '30 cm',
    weightText: '600 gr',
    motherInfo: 'Glucose tolerance test (OGTT) should be done between weeks 24–28 to screen for gestational diabetes. Regular monitoring is important.',
  ),
  PregnancyWeekInfo(
    week: 25,
    summary: 'Fetus weighs ≈680 g. The brain is growing rapidly; folds and grooves are forming. The baby has a regular sleep-wake cycle.',
    sizeText: 'broccoli sized',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.matureFetus,
    heightText: '35 cm',
    weightText: '660 gr',
    motherInfo: 'Uterus is above the navel. Heartburn and constipation are common. Deep breathing exercises and prenatal yoga can help.',
  ),
  PregnancyWeekInfo(
    week: 26,
    summary: 'Fetus weighs ≈760 g. Eyes can open and close; the baby can blink. The immune system is beginning to develop.',
    sizeText: 'lettuce sized',
    fruit: FruitShape.leafy,
    stage: EmbryoStage.matureFetus,
    heightText: '36 cm',
    weightText: '760 gr',
    motherInfo: 'Swelling in hands and feet may increase. Sleeping on the left side improves blood flow. Start planning for the birth.',
  ),
  PregnancyWeekInfo(
    week: 27,
    summary: 'Fetus weighs ≈900 g. All body systems are functioning but still maturing. The baby regularly practices breathing motions.',
    sizeText: 'bell pepper sized',
    fruit: FruitShape.smallRound,
    stage: EmbryoStage.matureFetus,
    heightText: '37 cm',
    weightText: '875 gr',
    motherInfo: 'Shortness of breath may begin as the uterus presses upward. Sleep difficulties are common. Discuss your birth plan with your doctor.',
  ),
  PregnancyWeekInfo(
    week: 28,
    summary: 'Fetus weighs ≈1,000–1,100 g and is ≈25 cm long. Third trimester begins! Brain is developing rapidly; eyes can detect light.',
    sizeText: 'eggplant sized',
    fruit: FruitShape.eggplant,
    stage: EmbryoStage.matureFetus,
    heightText: '38 cm',
    weightText: '1.000 gr',
    motherInfo: 'Third trimester begins! Prenatal visits become more frequent. Anti-D injection for Rh-negative mothers. Leg cramps, back pain, and insomnia are common.',
  ),
  PregnancyWeekInfo(
    week: 29,
    summary: 'Fetus weighs ≈1,200 g. Bones are fully formed though still soft. The brain is expanding and developing complex functions.',
    sizeText: 'coconut sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '39 cm',
    weightText: '1.150 gr',
    motherInfo: 'Frequent urination returns as the uterus grows. Pelvic pressure increases. Monitor for signs of preterm labor.',
  ),
  PregnancyWeekInfo(
    week: 30,
    summary: 'Fetus weighs ≈1,350 g. Skin becomes smoother as fat deposits build up. The head is proportional to the body.',
    sizeText: 'cucumber sized',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
    heightText: '40 cm',
    weightText: '1.320 gr',
    motherInfo: 'Nesting instinct may begin. Braxton Hicks contractions become more noticeable. Start preparing your hospital bag.',
  ),
  PregnancyWeekInfo(
    week: 31,
    summary: 'Fetus weighs ≈1,500 g. Brain development continues rapidly. Most organ systems are fully functional; lungs and digestive system are completing development.',
    sizeText: 'pineapple sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '41 cm',
    weightText: '1.500 gr',
    motherInfo: 'Shortness of breath is common as the uterus presses on the diaphragm. Prenatal visits every 2 weeks. Complete birth classes.',
  ),
  PregnancyWeekInfo(
    week: 32,
    summary: 'Fetus weighs ≈1,700 g. Baby usually settles into head-down position. Regular sleep-wake cycles are well established.',
    sizeText: 'orange sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '42 cm',
    weightText: '1.700 gr',
    motherInfo: 'Third trimester ultrasound checks fetal growth. Swelling, back pain, and pelvic pressure are common. Rest often.',
  ),
  PregnancyWeekInfo(
    week: 33,
    summary: 'Fetus weighs ≈1,900–2,000 g. Skull bones are soft and flexible for passage through the birth canal. Lanugo (fine body hair) is disappearing.',
    sizeText: 'melon sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '44 cm',
    weightText: '1.920 gr',
    motherInfo: 'Nesting instinct intensifies. Make sure hospital bag is ready. Monitor fetal movements daily.',
  ),
  PregnancyWeekInfo(
    week: 34,
    summary: 'Fetus weighs ≈2,100–2,200 g. Immune system has strengthened. Brain continues to develop rapidly; fingernails reach the fingertips.',
    sizeText: 'grape bunch sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '45 cm',
    weightText: '2.145 gr',
    motherInfo: "Weekly prenatal visits. Watch for signs of preeclampsia (sudden swelling, headache, visual changes). Baby's position is confirmed.",
  ),
  PregnancyWeekInfo(
    week: 35,
    summary: 'Fetus weighs ≈2,300–2,400 g. Lungs are almost fully mature. Kidneys are fully functional; they excrete urine into amniotic fluid.',
    sizeText: 'large potato sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '46 cm',
    weightText: '2.380 gr',
    motherInfo: "Baby's head may engage in the pelvis (lightening). This eases breathing but increases pelvic pressure. Braxton Hicks contractions become stronger.",
  ),
  PregnancyWeekInfo(
    week: 36,
    summary: "Fetus weighs ≈2,600–2,700 g. Baby is 'early term.' Most body systems are fully mature. Baby gains about 30 g of fat per day.",
    sizeText: 'large cabbage sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '48 cm',
    weightText: '2.650 gr',
    motherInfo: 'Weekly prenatal visits. Nonstress tests (NST) begin. Hospital bag should be fully packed and ready.',
  ),
  PregnancyWeekInfo(
    week: 37,
    summary: "Fetus weighs ≈2,900–3,000 g. 'Full term' — baby is fully ready for birth! Lung maturity is complete; baby is gaining weight daily.",
    sizeText: 'long corn cob sized',
    fruit: FruitShape.longGreen,
    stage: EmbryoStage.fullTerm,
    heightText: '49 cm',
    weightText: '2.850 gr',
    motherInfo: 'Birth can happen at any time! Know the signs of labor: regular contractions, water breaking, bloody show. Rest as much as possible.',
  ),
  PregnancyWeekInfo(
    week: 38,
    summary: 'Fetus weighs ≈3,100–3,200 g. Lanugo has disappeared; vernix is still present. The placenta is aging but still functioning well.',
    sizeText: 'butternut squash sized',
    fruit: FruitShape.melon,
    stage: EmbryoStage.fullTerm,
    heightText: '50 cm',
    weightText: '3.100 gr',
    motherInfo: 'Cervical changes (effacement and dilation) may begin. Some women feel the baby drop lower. Contractions are becoming more regular and stronger.',
  ),
  PregnancyWeekInfo(
    week: 39,
    summary: 'Fetus weighs ≈3,300–3,400 g. Skull bones are firm and mobile. Baby continues to gain weight. Everything is in final preparation for birth.',
    sizeText: 'watermelon slice sized',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
    heightText: '51 cm',
    weightText: '3.300 gr',
    motherInfo: 'Body is preparing for labor. Mucus plug may be discharged. If water breaks or contractions are 5 minutes apart, go to the hospital.',
  ),
  PregnancyWeekInfo(
    week: 40,
    summary: 'Fetus weighs ≈3,300–3,500 g. Estimated due date! Only about 4–5% of babies are born on this date. Baby is fully developed and ready to meet you!',
    sizeText: 'watermelon sized',
    fruit: FruitShape.watermelon,
    stage: EmbryoStage.fullTerm,
    heightText: '52 cm',
    weightText: '3.500 gr',
    motherInfo: 'If labor has not started, your doctor may discuss induction. Trust your body and your medical team. Your baby is ready to come into the world!',
  ),
];

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
  prenatalTest, // İkili, üçlü, OGTT vb. tarama testleri
}

extension MilestoneCategoryX on MilestoneCategory {
  Color get color {
    switch (this) {
      case MilestoneCategory.folicAcid:    return const Color(0xFFEC4899);
      case MilestoneCategory.fertilization:return const Color(0xFF3B82F6);
      case MilestoneCategory.implantation: return const Color(0xFFE11D48);
      case MilestoneCategory.test:         return const Color(0xFF9333EA);
      case MilestoneCategory.organ:        return const Color(0xFF14B8A6);
      case MilestoneCategory.heartbeat:    return const Color(0xFFF97316);
      case MilestoneCategory.prenatalTest: return const Color(0xFF0369A1);
    }
  }

  String get emoji {
    switch (this) {
      case MilestoneCategory.folicAcid:    return '💊';
      case MilestoneCategory.fertilization:return '🥚';
      case MilestoneCategory.implantation: return '🌱';
      case MilestoneCategory.test:         return '🔬';
      case MilestoneCategory.organ:        return '🫀';
      case MilestoneCategory.heartbeat:    return '💓';
      case MilestoneCategory.prenatalTest: return '🧪';
    }
  }
}

class PregnancyMilestone {
  final String title;
  final String titleEn;
  final String description;
  final MilestoneCategory category;
  final int startDayOffset;
  final int endDayOffset;

  const PregnancyMilestone({
    required this.title,
    required this.titleEn,
    required this.description,
    required this.category,
    required this.startDayOffset,
    required this.endDayOffset,
  });

  Color get color => category.color;

  String getTitle(bool isEnglish) => isEnglish ? titleEn : title;
}

const List<PregnancyMilestone> kMilestones = [
  PregnancyMilestone(
    title: 'Folik asit kullanımı',
    titleEn: 'Folic acid use',
    description:
        'Bebeğin nöral tüpünün sağlıklı gelişimi için folik asit almak '
        'bu dönemde çok kritik. Doktorunun önerdiği dozu aksatma.',
    category: MilestoneCategory.folicAcid,
    startDayOffset: 0,
    endDayOffset: 90,
  ),
  PregnancyMilestone(
    title: 'Döllenme',
    titleEn: 'Fertilization',
    description: 'Sperm ve yumurta buluştu — yolculuk başladı!',
    category: MilestoneCategory.fertilization,
    startDayOffset: 13,
    endDayOffset: 15,
  ),
  PregnancyMilestone(
    title: 'Rahme tutunma',
    titleEn: 'Implantation',
    description: 'Döllenmiş yumurta rahim duvarına tutundu. Gebelik resmen başladı!',
    category: MilestoneCategory.implantation,
    startDayOffset: 20,
    endDayOffset: 24,
  ),
  PregnancyMilestone(
    title: 'Gebelik testi pozitif',
    titleEn: 'Positive pregnancy test',
    description: 'hCG hormonu testte görünecek kadar yükseldi.',
    category: MilestoneCategory.test,
    startDayOffset: 27,
    endDayOffset: 31,
  ),
  PregnancyMilestone(
    title: 'Organ gelişim dönemi',
    titleEn: 'Organ development period',
    description:
        'Bebeğin hayati organlarının temeli bu haftalarda atılıyor. '
        'İlaç ve beslenmene en çok dikkat etmen gereken dönem.',
    category: MilestoneCategory.organ,
    startDayOffset: 28,
    endDayOffset: 70,
  ),
  PregnancyMilestone(
    title: 'İlk kalp atışı',
    titleEn: 'First heartbeat',
    description: 'Minik kalp atmaya başladı! Ultrasonda duyulabilir.',
    category: MilestoneCategory.heartbeat,
    startDayOffset: 38,
    endDayOffset: 44,
  ),

  // ── Prenatal tarama testleri ─────────────────────────────────────────
  PregnancyMilestone(
    title: 'İlk trimester ultrason',
    titleEn: '1st trimester ultrasound',
    description:
        'Bebeğin canlılığı, kalp atışı ve gebelik haftası doğrulanır. '
        'Baş-popo mesafesi (CRL) ölçülür. 6–10. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 35,   // 6. hafta
    endDayOffset: 69,     // 10. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Kan testleri (1. grup)',
    titleEn: 'Blood tests (Group 1)',
    description:
        'Tam kan sayımı (CBC), kan grubu & Rh, indirekt Coombs, '
        'rubella IgG, toksoplazmoz, CMV, HIV, HBsAg, HCV, VDRL, '
        'idrar kültürü, TSH. 6–12. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 35,   // 6. hafta
    endDayOffset: 84,     // 12. hafta sonu
  ),
  PregnancyMilestone(
    title: 'İkili tarama testi',
    titleEn: 'First trimester screening',
    description:
        'PAPP-A, serbest β-hCG ve ense saydamlığı (NT) ölçümü. '
        'Down sendromu ve diğer kromozom anomalileri taranır. 11–14. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 70,   // 11. hafta
    endDayOffset: 97,     // 14. hafta sonu
  ),
  PregnancyMilestone(
    title: 'NIPT (Hücre dışı DNA)',
    titleEn: 'NIPT (Cell-free DNA)',
    description:
        'Anneden alınan kandan Down sendromu ve diğer trizomiler taranır. '
        'En ideal dönem 10–13. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 63,   // 10. hafta
    endDayOffset: 90,     // 13. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Üçlü / Dörtlü tarama',
    titleEn: 'Triple / Quad screening',
    description:
        'AFP, hCG, estriol (ve inhibin A) ölçülür. '
        'Nöral tüp defektleri ve kromozom anomalileri taranır. 15–18. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 98,   // 15. hafta
    endDayOffset: 125,    // 18. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Detaylı ultrason (Anomali taraması)',
    titleEn: 'Detailed ultrasound (Anomaly scan)',
    description:
        'Bebeğin tüm organları, yapısal anomaliler ve cinsiyet incelenir. '
        '18–22. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 119,  // 18. hafta
    endDayOffset: 153,    // 22. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Şeker yükleme testi (OGTT)',
    titleEn: 'Glucose tolerance test (OGTT)',
    description:
        '75 g oral glikoz tolerans testi. Gestasyonel diyabet taranır. '
        '24–28. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 161,  // 24. hafta
    endDayOffset: 196,    // 28. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Anti-D & 2. Rh taraması',
    titleEn: 'Anti-D & 2nd Rh screening',
    description:
        'Rh(-) annelere Anti-D immünoglobulin uygulanır. '
        'İkinci Rh antikor taraması yapılır. 28. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 189,  // 28. hafta
    endDayOffset: 196,
  ),
  PregnancyMilestone(
    title: '3. Trimester ultrason',
    titleEn: '3rd trimester ultrasound',
    description:
        'Fetal biyometri, amniyon sıvı miktarı ve bebeğin büyümesi '
        'değerlendirilir. 32–38. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 217,  // 32. hafta
    endDayOffset: 265,    // 38. hafta sonu
  ),
  PregnancyMilestone(
    title: 'NST (Non-stres test)',
    titleEn: 'NST (Non-stress test)',
    description:
        'Bebeğin kalp atış hızı ve hareketleri izlenir. '
        '36. haftadan itibaren rutin uygulanır.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 245,  // 36. hafta
    endDayOffset: 280,
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

/// Verilen 7 günlük satır aralığında BAŞLAYAN milestone'ları döndürür.
/// Takvim hafta-etiket bandı için kullanılır.
List<PregnancyMilestone> milestonesStartingInRow(
    DateTime rowStart, DateTime? lmp) {
  if (lmp == null) return const [];
  final d0 = DateTime(lmp.year, lmp.month, lmp.day);
  final rowStartOffset = rowStart.difference(d0).inDays;
  final rowEndOffset = rowStartOffset + 6;
  return kMilestones
      .where((m) =>
          m.startDayOffset >= rowStartOffset &&
          m.startDayOffset <= rowEndOffset)
      .toList();
}

int? pregnancyWeekForDate(DateTime date, DateTime? lmp) {
  if (lmp == null) return null;
  final d0 = DateTime(lmp.year, lmp.month, lmp.day);
  final d1 = DateTime(date.year, date.month, date.day);
  final days = d1.difference(d0).inDays;
  if (days < 0 || days > 280) return null; // SAT öncesi veya 40. hafta sonrası → işaretsiz
  final week = (days ~/ 7) + 1;
  return week.clamp(1, 40);
}

// ─────────────────────────────────────────────
// Hafta olayları (takvim milestone etiketleri)
// ─────────────────────────────────────────────

class WeekEvent {
  final int week;
  final String emoji;
  final String title;
  final String detail;
  final String titleEn;
  final String detailEn;
  final Color color;

  const WeekEvent({
    required this.week,
    required this.emoji,
    required this.title,
    required this.detail,
    required this.titleEn,
    required this.detailEn,
    required this.color,
  });

  String getTitle(bool isEnglish) => isEnglish ? titleEn : title;
  String getDetail(bool isEnglish) => isEnglish ? detailEn : detail;
}

const List<WeekEvent> kWeekEvents = [
  // ── Erken gebelik ─────────────────────────────────────────────────────
  WeekEvent(week: 2,  emoji: '🌸', title: 'Yumurtlama dönemi',      detail: 'Yumurtalık yumurtayı serbest bırakmaya hazırlanıyor. Döllenme için en uygun dönem yaklaşıyor.',           titleEn: 'Ovulation period',           detailEn: 'The ovary is preparing to release an egg. The optimal time for conception is approaching.',           color: Color(0xFFDB2777)),
  WeekEvent(week: 3,  emoji: '🥚', title: 'Yumurtlama & Döllenme', detail: 'Yumurtlama gerçekleşiyor (SAT\'tan ~14 gün sonra). Sperm ile buluşursa döllenme başlar — yeni bir hayat!', titleEn: 'Ovulation & Fertilization', detailEn: 'Ovulation occurs (~14 days after LMP). If sperm are present, fertilization begins — a new life!', color: Color(0xFFEA580C)),
  WeekEvent(week: 4,  emoji: '🌱', title: 'Rahme tutunma',          detail: 'Döllenmiş yumurta rahim duvarına tutunuyor. hCG hormonu salgılanmaya başladı.',                            titleEn: 'Implantation',               detailEn: 'The fertilized egg is attaching to the uterine wall. hCG hormone secretion has begun.',            color: Color(0xFFE11D48)),
  WeekEvent(week: 5,  emoji: '🔬', title: 'Test pozitif!',          detail: 'İlk adet gecikmesi bu hafta. Ev gebelik testi artık pozitif sonuç verebilir!',                             titleEn: 'Positive test!',             detailEn: 'First missed period this week. A home pregnancy test may now show a positive result!',             color: Color(0xFF7C3AED)),
  WeekEvent(week: 6,  emoji: '💓', title: 'İlk kalp atışı',         detail: 'Bebeğin minik kalbi atmaya başlıyor — ultrasonda duyulabilir!',                                            titleEn: 'First heartbeat',            detailEn: "Baby's tiny heart is starting to beat — detectable on ultrasound!",                               color: Color(0xFFF97316)),
  WeekEvent(week: 8,  emoji: '🫀', title: 'Tüm organlar başladı',   detail: 'Tüm hayati organların temeli bu haftada atılıyor.',                                                         titleEn: 'All organs begun',           detailEn: 'The foundation of all vital organs is being laid this week.',                                     color: Color(0xFF14B8A6)),
  WeekEvent(week: 10, emoji: '👶', title: 'Fetüs dönemi',           detail: 'Artık embriyo değil, fetüs! Yüz hatları belirginleşiyor.',                                                  titleEn: 'Fetus stage',                detailEn: "No longer an embryo, now a fetus! Facial features are becoming more defined.",                    color: Color(0xFF9333EA)),
  WeekEvent(week: 12, emoji: '🎉', title: '1. Trimester sonu',      detail: 'Düşük riski önemli ölçüde azaldı. İkili tarama testi zamanı.',                                             titleEn: 'End of 1st trimester',       detailEn: 'Miscarriage risk has dropped significantly. Time for the first trimester screening.',             color: Color(0xFF7C3AED)),
  WeekEvent(week: 14, emoji: '🌟', title: '2. Trimester başladı',   detail: 'En rahat dönem başlıyor. Mide bulantısı genellikle geçer.',                                                 titleEn: '2nd trimester begins',       detailEn: 'The most comfortable period begins. Morning sickness usually fades.',                             color: Color(0xFF0891B2)),
  WeekEvent(week: 16, emoji: '👂', title: 'Bebek duyuyor',          detail: 'Bebek sesleri duyabilir — ona şarkı söyle!',                                                                titleEn: 'Baby can hear',              detailEn: 'Baby can hear sounds — sing to them!',                                                            color: Color(0xFF059669)),
  WeekEvent(week: 18, emoji: '🤸', title: 'İlk hareketler',         detail: 'İlk kez hamile annelerde bebek hareketleri bu hafta hissedilebilir.',                                       titleEn: 'First movements',            detailEn: 'First-time mothers may feel baby movements for the first time this week.',                        color: Color(0xFFD97706)),
  WeekEvent(week: 20, emoji: '🩺', title: 'Detaylı ultrason',       detail: 'Cinsiyet öğrenilebilir! Anomali taraması ve detaylı ultrason zamanı.',                                      titleEn: 'Detailed ultrasound',        detailEn: "Gender can be revealed! Anomaly scan and detailed ultrasound time.",                              color: Color(0xFF3B82F6)),
  WeekEvent(week: 24, emoji: '🏥', title: 'Yaşayabilirlik eşiği',  detail: 'Bu haftadan itibaren bebek yoğun bakım desteğiyle hayatta kalabilir.',                                      titleEn: 'Viability threshold',       detailEn: 'From this week, the baby could survive outside the womb with intensive care support.',            color: Color(0xFF6366F1)),
  WeekEvent(week: 28, emoji: '📅', title: '3. Trimester başladı',   detail: 'Son dönem! Doğum hazırlıklarına başlama zamanı.',                                                           titleEn: '3rd trimester begins',       detailEn: 'Final stretch! Time to start birth preparations.',                                                color: Color(0xFFEC4899)),
  WeekEvent(week: 32, emoji: '😴', title: 'Uyku-uyanıklık döngüsü',detail: 'Bebek düzenli uyku ve uyanıklık döngüleri oluşturdu.',                   titleEn: 'Sleep-wake cycles',          detailEn: 'Baby has established regular sleep and wake cycles.',                   color: Color(0xFF8B5CF6)),
  WeekEvent(week: 36, emoji: '🔜', title: 'Erken term',             detail: 'Bebek "erken term" kabul edilir. Doğum çantası hazır olmalı!',           titleEn: 'Early term',                 detailEn: 'Baby is considered "early term". Hospital bag should be ready!',        color: Color(0xFF0D9488)),
  WeekEvent(week: 37, emoji: '✅', title: 'Tam term',               detail: 'Bebek "tam term" — doğum her an başlayabilir!',                          titleEn: 'Full term',                  detailEn: 'Baby is "full term" — birth can begin at any time!',                   color: Color(0xFF16A34A)),
  WeekEvent(week: 40, emoji: '🎊', title: 'Tahmini doğum günü',     detail: 'Tahmini doğum tarihi! Bebeklerin %4–5\'i bu tarihte doğar.',             titleEn: 'Estimated due date',         detailEn: "Estimated due date! Only about 4–5% of babies are born on this exact day.",                    color: Color(0xFFDC2626)),
];

/// Verilen tarih bir hafta olayının ilk günüyse o WeekEvent'i döndürür.
WeekEvent? weekEventForDate(DateTime date, DateTime? lmp) {
  if (lmp == null) return null;
  final d0 = DateTime(lmp.year, lmp.month, lmp.day);
  final d1 = DateTime(date.year, date.month, date.day);
  final days = d1.difference(d0).inDays;
  if (days < 0 || days % 7 != 0) return null; // sadece haftanın ilk günü
  final week = (days ~/ 7) + 1;
  try {
    return kWeekEvents.firstWhere((e) => e.week == week);
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────
// Burç hesaplama
// ─────────────────────────────────────────────

class ZodiacInfo {
  final String name;
  final String nameEn;
  final String emoji;
  final String dateRange;
  final String dateRangeEn;

  const ZodiacInfo(this.name, this.nameEn, this.emoji, this.dateRange, this.dateRangeEn);

  String getName(bool isEnglish) => isEnglish ? nameEn : name;
  String getDateRange(bool isEnglish) => isEnglish ? dateRangeEn : dateRange;
}

ZodiacInfo zodiacForDate(DateTime date, {bool isEnglish = false}) {
  final m = date.month;
  final d = date.day;

  if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) {
    return const ZodiacInfo('Koç',      'Aries',       '♈', '21 Mar – 19 Nis', 'Mar 21 – Apr 19');
  }
  if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) {
    return const ZodiacInfo('Boğa',     'Taurus',      '♉', '20 Nis – 20 May', 'Apr 20 – May 20');
  }
  if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) {
    return const ZodiacInfo('İkizler',  'Gemini',      '♊', '21 May – 20 Haz', 'May 21 – Jun 20');
  }
  if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) {
    return const ZodiacInfo('Yengeç',   'Cancer',      '♋', '21 Haz – 22 Tem', 'Jun 21 – Jul 22');
  }
  if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) {
    return const ZodiacInfo('Aslan',    'Leo',         '♌', '23 Tem – 22 Ağu', 'Jul 23 – Aug 22');
  }
  if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) {
    return const ZodiacInfo('Başak',    'Virgo',       '♍', '23 Ağu – 22 Eyl', 'Aug 23 – Sep 22');
  }
  if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) {
    return const ZodiacInfo('Terazi',   'Libra',       '♎', '23 Eyl – 22 Eki', 'Sep 23 – Oct 22');
  }
  if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) {
    return const ZodiacInfo('Akrep',    'Scorpio',     '♏', '23 Eki – 21 Kas', 'Oct 23 – Nov 21');
  }
  if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) {
    return const ZodiacInfo('Yay',      'Sagittarius', '♐', '22 Kas – 21 Ara', 'Nov 22 – Dec 21');
  }
  if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) {
    return const ZodiacInfo('Oğlak',    'Capricorn',   '♑', '22 Ara – 19 Oca', 'Dec 22 – Jan 19');
  }
  if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) {
    return const ZodiacInfo('Kova',     'Aquarius',    '♒', '20 Oca – 18 Şub', 'Jan 20 – Feb 18');
  }
  return const ZodiacInfo('Balık',     'Pisces',      '♓', '19 Şub – 20 Mar', 'Feb 19 – Mar 20');
}
