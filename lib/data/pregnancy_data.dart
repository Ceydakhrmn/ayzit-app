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

  // ── Prenatal tarama testleri ─────────────────────────────────────────
  PregnancyMilestone(
    title: 'İlk trimester ultrason',
    description:
        'Bebeğin canlılığı, kalp atışı ve gebelik haftası doğrulanır. '
        'Baş-popo mesafesi (CRL) ölçülür. 6–10. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 35,   // 6. hafta
    endDayOffset: 69,     // 10. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Kan testleri (1. grup)',
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
    description:
        'PAPP-A, serbest β-hCG ve ense saydamlığı (NT) ölçümü. '
        'Down sendromu ve diğer kromozom anomalileri taranır. 11–14. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 70,   // 11. hafta
    endDayOffset: 97,     // 14. hafta sonu
  ),
  PregnancyMilestone(
    title: 'NIPT (Hücre dışı DNA)',
    description:
        'Anneden alınan kandan Down sendromu ve diğer trizomiler taranır. '
        'En ideal dönem 10–13. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 63,   // 10. hafta
    endDayOffset: 90,     // 13. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Üçlü / Dörtlü tarama',
    description:
        'AFP, hCG, estriol (ve inhibin A) ölçülür. '
        'Nöral tüp defektleri ve kromozom anomalileri taranır. 15–18. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 98,   // 15. hafta
    endDayOffset: 125,    // 18. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Detaylı ultrason (Anomali taraması)',
    description:
        'Bebeğin tüm organları, yapısal anomaliler ve cinsiyet incelenir. '
        '18–22. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 119,  // 18. hafta
    endDayOffset: 153,    // 22. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Şeker yükleme testi (OGTT)',
    description:
        '75 g oral glikoz tolerans testi. Gestasyonel diyabet taranır. '
        '24–28. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 161,  // 24. hafta
    endDayOffset: 196,    // 28. hafta sonu
  ),
  PregnancyMilestone(
    title: 'Anti-D & 2. Rh taraması',
    description:
        'Rh(-) annelere Anti-D immünoglobulin uygulanır. '
        'İkinci Rh antikor taraması yapılır. 28. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 189,  // 28. hafta
    endDayOffset: 196,
  ),
  PregnancyMilestone(
    title: '3. Trimester ultrason',
    description:
        'Fetal biyometri, amniyon sıvı miktarı ve bebeğin büyümesi '
        'değerlendirilir. 32–38. hafta.',
    category: MilestoneCategory.prenatalTest,
    startDayOffset: 217,  // 32. hafta
    endDayOffset: 265,    // 38. hafta sonu
  ),
  PregnancyMilestone(
    title: 'NST (Non-stres test)',
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
  final Color color;

  const WeekEvent({
    required this.week,
    required this.emoji,
    required this.title,
    required this.detail,
    required this.color,
  });
}

const List<WeekEvent> kWeekEvents = [
  // ── Erken gebelik ─────────────────────────────────────────────────────
  WeekEvent(week: 2,  emoji: '🌸', title: 'Yumurtlama dönemi',      detail: 'Yumurtalık yumurtayı serbest bırakmaya hazırlanıyor. Döllenme için en uygun dönem yaklaşıyor.',           color: Color(0xFFDB2777)),
  WeekEvent(week: 3,  emoji: '🥚', title: 'Yumurtlama & Döllenme', detail: 'Yumurtlama gerçekleşiyor (SAT\'tan ~14 gün sonra). Sperm ile buluşursa döllenme başlar — yeni bir hayat!', color: Color(0xFFEA580C)),
  WeekEvent(week: 4,  emoji: '🌱', title: 'Rahme tutunma',          detail: 'Döllenmiş yumurta rahim duvarına tutunuyor. hCG hormonu salgılanmaya başladı.',                            color: Color(0xFFE11D48)),
  WeekEvent(week: 5,  emoji: '🔬', title: 'Test pozitif!',          detail: 'İlk adet gecikmesi bu hafta. Ev gebelik testi artık pozitif sonuç verebilir!',                             color: Color(0xFF7C3AED)),
  WeekEvent(week: 6,  emoji: '💓', title: 'İlk kalp atışı',         detail: 'Bebeğin minik kalbi atmaya başlıyor — ultrasonda duyulabilir!',                                            color: Color(0xFFF97316)),
  WeekEvent(week: 8,  emoji: '🫀', title: 'Tüm organlar başladı',   detail: 'Tüm hayati organların temeli bu haftada atılıyor.',                                                         color: Color(0xFF14B8A6)),
  WeekEvent(week: 10, emoji: '👶', title: 'Fetüs dönemi',           detail: 'Artık embriyo değil, fetüs! Yüz hatları belirginleşiyor.',                                                  color: Color(0xFF9333EA)),
  WeekEvent(week: 12, emoji: '🎉', title: '1. Trimester sonu',      detail: 'Düşük riski önemli ölçüde azaldı. İkili tarama testi zamanı.',                                             color: Color(0xFF7C3AED)),
  WeekEvent(week: 14, emoji: '🌟', title: '2. Trimester başladı',   detail: 'En rahat dönem başlıyor. Mide bulantısı genellikle geçer.',                                                 color: Color(0xFF0891B2)),
  WeekEvent(week: 16, emoji: '👂', title: 'Bebek duyuyor',          detail: 'Bebek sesleri duyabilir — ona şarkı söyle!',                                                                color: Color(0xFF059669)),
  WeekEvent(week: 18, emoji: '🤸', title: 'İlk hareketler',         detail: 'İlk kez hamile annelerde bebek hareketleri bu hafta hissedilebilir.',                                       color: Color(0xFFD97706)),
  WeekEvent(week: 20, emoji: '🩺', title: 'Detaylı ultrason',       detail: 'Cinsiyet öğrenilebilir! Anomali taraması ve detaylı ultrason zamanı.',                                      color: Color(0xFF3B82F6)),
  WeekEvent(week: 24, emoji: '🏥', title: 'Yaşayabilirlik eşiği',  detail: 'Bu haftadan itibaren bebek yoğun bakım desteğiyle hayatta kalabilir.',                                      color: Color(0xFF6366F1)),
  WeekEvent(week: 28, emoji: '📅', title: '3. Trimester başladı',   detail: 'Son dönem! Doğum hazırlıklarına başlama zamanı.',                                                           color: Color(0xFFEC4899)),
  WeekEvent(week: 32, emoji: '😴', title: 'Uyku-uyanıklık döngüsü',detail: 'Bebek düzenli uyku ve uyanıklık döngüleri oluşturdu.',                   color: Color(0xFF8B5CF6)),
  WeekEvent(week: 36, emoji: '🔜', title: 'Erken term',             detail: 'Bebek "erken term" kabul edilir. Doğum çantası hazır olmalı!',           color: Color(0xFF0D9488)),
  WeekEvent(week: 37, emoji: '✅', title: 'Tam term',               detail: 'Bebek "tam term" — doğum her an başlayabilir!',                          color: Color(0xFF16A34A)),
  WeekEvent(week: 40, emoji: '🎊', title: 'Tahmini doğum günü',     detail: 'Tahmini doğum tarihi! Bebeklerin %4–5\'i bu tarihte doğar.',             color: Color(0xFFDC2626)),
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
  final String emoji;
  final String dateRange;

  const ZodiacInfo(this.name, this.emoji, this.dateRange);
}

ZodiacInfo zodiacForDate(DateTime date) {
  final m = date.month;
  final d = date.day;

  if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) {
    return const ZodiacInfo('Koç',      '♈', '21 Mar – 19 Nis');
  }
  if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) {
    return const ZodiacInfo('Boğa',     '♉', '20 Nis – 20 May');
  }
  if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) {
    return const ZodiacInfo('İkizler',  '♊', '21 May – 20 Haz');
  }
  if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) {
    return const ZodiacInfo('Yengeç',   '♋', '21 Haz – 22 Tem');
  }
  if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) {
    return const ZodiacInfo('Aslan',    '♌', '23 Tem – 22 Ağu');
  }
  if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) {
    return const ZodiacInfo('Başak',    '♍', '23 Ağu – 22 Eyl');
  }
  if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) {
    return const ZodiacInfo('Terazi',   '♎', '23 Eyl – 22 Eki');
  }
  if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) {
    return const ZodiacInfo('Akrep',    '♏', '23 Eki – 21 Kas');
  }
  if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) {
    return const ZodiacInfo('Yay',      '♐', '22 Kas – 21 Ara');
  }
  if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) {
    return const ZodiacInfo('Oğlak',   '♑', '22 Ara – 19 Oca');
  }
  if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) {
    return const ZodiacInfo('Kova',     '♒', '20 Oca – 18 Şub');
  }
  return const ZodiacInfo('Balık',     '♓', '19 Şub – 20 Mar');
}
