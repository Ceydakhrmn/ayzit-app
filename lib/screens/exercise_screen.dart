import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';
import '../widgets/exercise_card.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _trimester = 1;
  bool _warningExpanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final mode = provider.appMode;
    final exercises = _exercisesForMode(mode, _trimester);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = !AppLocalizations.of(context)!.isTurkish;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık satırı ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _titleForMode(mode, isEn: isEn),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                // Uyarı butonu — sadece hamileTakip modunda
                if (mode == AppMode.hamileTakip)
                  GestureDetector(
                    onTap: () => setState(() => _warningExpanded = !_warningExpanded),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _warningExpanded
                            ? const Color(0xFFFBBF24)
                            : (isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFF7ED)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFBBF24),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: _warningExpanded
                            ? Colors.white
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Trimester seçici (hamileTakip) — başlığın hemen altında tam genişlik ──
          if (mode == AppMode.hamileTakip) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TrimesterPicker(
                selected: _trimester,
                onChanged: (t) => setState(() => _trimester = t),
              ),
            ),
          ],

          // ── Alt başlık (regl / doğurganlık) ──
          if (mode != AppMode.hamileTakip)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                _subtitleForMode(mode, isEn: isEn),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white.withValues(alpha: 0.55) : Colors.black45,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ── Açılır uyarı paneli ──
          if (mode == AppMode.hamileTakip && _warningExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: const _PregnancyWarningCard(),
            ),

          // ── Egzersiz listesi ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => ExerciseCard(data: exercises[index]),
            ),
          ),
        ],
      ),
    );
  }

  String _titleForMode(AppMode mode, {bool isEn = false}) {
    switch (mode) {
      case AppMode.reglTakip:    return isEn ? 'Period Exercises' : 'Regl Dönemi Egzersizleri';
      case AppMode.hamileTakip:  return isEn ? 'Pregnancy Exercises' : 'Hamilelik Egzersizleri';
      case AppMode.hamilleKalma: return isEn ? 'Fertility Exercises' : 'Doğurganlık Egzersizleri';
    }
  }

  String _subtitleForMode(AppMode mode, {bool isEn = false}) {
    switch (mode) {
      case AppMode.reglTakip:    return isEn ? 'Gentle movements to ease cramps' : 'Sancıları azaltmaya yardımcı hafif hareketler';
      case AppMode.hamileTakip:  return '';
      case AppMode.hamilleKalma: return isEn ? 'Pelvic floor and circulation support' : 'Pelvik taban ve kan dolaşımını destekleyen hareketler';
    }
  }

  List<ExerciseData> _exercisesForMode(AppMode mode, int trimester) {
    switch (mode) {
      case AppMode.reglTakip:
        return _reglExercises();
      case AppMode.hamileTakip:
        switch (trimester) {
          case 1: return _trimester1Exercises();
          case 2: return _trimester2Exercises();
          case 3: return _trimester3Exercises();
          default: return _trimester1Exercises();
        }
      case AppMode.hamilleKalma:
        return _fertilityExercises();
    }
  }

  // ── Regl egzersizleri ──
  List<ExerciseData> _reglExercises() => [
    ExerciseData(
      name: 'Yay Pozu',
      description: 'Karın kaslarını esnetir, krampları hafifletir.',
      benefits: ['Kramp ağrısı', 'Karın gerginliği', 'Sırt ağrısı', 'Stres'],
      steps: [
        'Yüz üstü yat, kollar yanında',
        'Dizleri büküp topukları kalçaya yaklaştır',
        'Ellerinle ayak bileklerini tut',
        'Nefes verirken gövdeyi ve bacakları yerden kaldır',
        '20–30 sn tut, salın',
      ],
      type: ExerciseType.bow,
    ),
    ExerciseData(
      name: 'Çocuk Pozu',
      description: 'Alt sırt ve karın kaslarını gevşetir.',
      benefits: ['Alt sırt ağrısı', 'Karın krampı', 'Zihin rahatlaması', 'Gerginlik'],
      steps: [
        'Diz üstü otur, topukların üstüne çök',
        'Kolları öne uzatarak öne eğil',
        'Alnını yere koy',
        'Derin nefes al, her nefeste biraz daha gevşe',
        '1–2 dakika bekle',
      ],
      type: ExerciseType.child,
    ),
    ExerciseData(
      name: 'Aşağı Bakan Köpek',
      description: 'Tüm vücudu esnetir, kan dolaşımını artırır.',
      benefits: ['Baş ağrısı', 'Sırt ağrısı', 'Yorgunluk', 'Kan dolaşımı'],
      steps: [
        'Dörtnala pozisyona geç',
        'Parmak uçlarına bas, dizleri yerden kaldır',
        'Kalçayı yukarı iterek ters V oluştur',
        'Topukları yere basmaya çalış',
        '5 nefes tut, tekrarla',
      ],
      type: ExerciseType.downDog,
    ),
    ExerciseData(
      name: 'Yatarak Tanrıça',
      description: 'Kalça ve pelvik bölgeyi rahatlatır.',
      benefits: ['Pelvik ağrı', 'Kalça gerginliği', 'İç uyluk', 'Rahatlama'],
      steps: [
        'Sırt üstü uzan, dizleri büküp ayak tabanlarını birleştir',
        'Dizlerin yana doğru düşmesine izin ver',
        'Kolları iki yana aç, avuçlar yukarı',
        'Gözleri kapat, derin nefes al',
        '2–3 dakika hareketsiz kal',
      ],
      type: ExerciseType.recliningGoddess,
    ),
    ExerciseData(
      name: 'Bacaklar Duvarda',
      description: 'Şişliği ve ağrıyı azaltır.',
      benefits: ['Bacak şişliği', 'Yorgunluk', 'Bel ağrısı', 'Kan dolaşımı'],
      steps: [
        'Duvara yakın yan uzan',
        'Bacakları yukarı kaldırıp duvara daya',
        'Kolları iki yana aç, rahatla',
        'Bacakları mümkün olduğunca dik tut',
        '5–10 dakika bekle',
      ],
      type: ExerciseType.legsUpWall,
    ),
    ExerciseData(
      name: 'Deve Pozu',
      description: 'Karın ve pelvik bölgeyi esnetir.',
      benefits: ['Karın krampı', 'Pelvik açılım', 'Omurga esnekliği', 'Enerji'],
      steps: [
        'Diz üstünde dik otur',
        'Elleri bele koy, dirsekler arkada',
        'Göğsü öne açarken başı geriye at',
        'İleri gidebilirsen elleri topuklara götür',
        '20–30 sn tut, yavaşça dön',
      ],
      type: ExerciseType.camel,
    ),
    ExerciseData(
      name: 'Kelebek Pozu',
      description: 'İç uylukları ve kasığı esnetir.',
      benefits: ['Pelvik gerginlik', 'İç uyluk', 'Kramp', 'Dolaşım'],
      steps: [
        'Otur, ayak tabanlarını birleştir',
        'Topukları kasığa çek',
        'Elleri ayakların üstünde kilitle',
        'Omurgayı dik tut, diz ve kasığı aşağı bırak',
        '1–2 dk tut, dizleri kelebek gibi salla',
      ],
      type: ExerciseType.butterfly,
    ),
  ];

  // ── 1. Trimester ──
  List<ExerciseData> _trimester1Exercises() => [
    ExerciseData(
      name: 'Oturan Kedi-İnek',
      description: 'Omurgayı mobilize eder, bulantıyı azaltır.',
      benefits: ['Sırt ağrısı', 'Bulantı', 'Omurga', 'Esneklik'],
      steps: [
        'Bağdaş kurarak rahat bir şekilde otur',
        'Nefes alırken göğsü öne aç, başı hafifçe yukarı kaldır',
        'Nefes verirken sırtı yuvarla, çeneyi göğse yaklaştır',
        'Yavaş ve akıcı şekilde nefese bağlı tekrarla',
        '8–10 tekrar yap',
      ],
      type: ExerciseType.oturanKediInek,
    ),
    ExerciseData(
      name: 'Yan Vücut Esnetme',
      description: 'Büyüyen rahme alan açar, yan kasları esnetir.',
      benefits: ['Yan ağrı', 'Esneklik', 'Rahatlama', 'Nefes'],
      steps: [
        'Bağdaş kurarak dik otur',
        'Bir elini yere koy, diğer kolunu başın üzerinden karşı yana uzat',
        'Yan tarafta esneme hissini yakala',
        '3 nefes boyunca bekle',
        'Diğer tarafa geç ve tekrarla',
      ],
      type: ExerciseType.yanVucutEstretme,
    ),
    ExerciseData(
      name: 'Kolay Poz ve Boyun Hareketi',
      description: 'Boyun ve omuz gerginliğini azaltır, zihni sakinleştirir.',
      benefits: ['Boyun gerginliği', 'Omuz rahatlaması', 'Stres', 'Odak'],
      steps: [
        'Sukhasana (kolay poz) pozisyonunda dik otur',
        'Başı yavaşça sağa, sonra sola çevir',
        'Başı öne ve arkaya nazikçe indir',
        'Son olarak başı iki yana yatırarak kulakları omuzlara yaklaştır',
        'Her yöne 3–4 nefes ver',
      ],
      type: ExerciseType.kolayPozBoyun,
    ),
    ExerciseData(
      name: 'İğne İpliğinden Geçirme',
      description: 'Sırt ve omuzlardaki gerginliği açar, omurgayı nazikçe döndürür.',
      benefits: ['Üst sırt ağrısı', 'Omuz esnekliği', 'Omurga mobilitesi', 'Rahatlama'],
      steps: [
        'Dörtnala pozisyona geç (eller omuz, dizler kalça altında)',
        'Sağ kolu sol kolun altından yere doğru uzat',
        'Sağ omuz ve yanağı yere ya da yastığa yasla',
        'Sol el öne uzanabilir ya da bele destek verebilir',
        '5 nefes kal, taraf değiştir',
      ],
      type: ExerciseType.igneIpliktenGecirme,
    ),
    ExerciseData(
      name: 'Aşağıya Bakan Köpek (Dizler Bükülmüş)',
      description: 'Omurgayı uzatır, karın bölgesine baskı yapmadan enerji verir.',
      benefits: ['Sırt ağrısı', 'Yorgunluk', 'Kan dolaşımı', 'Enerji'],
      steps: [
        'Dörtnala pozisyona geç',
        'Dizleri hafifçe bükülü tutarak kalçayı yukarı it',
        'Topuklar yerden kalkabilir, sırtı uzatmaya odaklan',
        'Başı kollar arasında serbest bırak',
        '5 nefes kal, yavaşça geri gel',
      ],
      type: ExerciseType.asagiBakanKopek,
    ),
    ExerciseData(
      name: 'Alçak Hamle (Arka Diz Yere)',
      description: 'Kalça esnekliğini artırır, bacakları açar.',
      benefits: ['Kalça esnekliği', 'Bacak gücü', 'Pelvik açılım', 'Denge'],
      steps: [
        'Sağ ayağı öne al, diz 90 derece bükülü olacak şekilde',
        'Sol dizi yere indir, gerekirse altına havlu ya da yastık koy',
        'Kalçayı yavaşça aşağı indir, ellerini ön dizin üstüne koy',
        'Göğsü dik tut, sırtını uzat',
        '5 nefes kal, taraf değiştir',
      ],
      type: ExerciseType.alcakHamle,
    ),
    ExerciseData(
      name: 'Üçgen Duruşu (Değiştirilmiş)',
      description: 'Yan vücudu uzatır, bacakları güçlendirir.',
      benefits: ['Yan kaslar', 'Bacak gücü', 'Denge', 'Esneklik'],
      steps: [
        'Ayakları geniş aç, sağ ayak parmakları öne, sol parmaklar hafif içe',
        'Kolları yana aç, omuz hizasında',
        'Sağ eli sağ bacağa ya da bloğa yaslayarak yan eğil',
        'Sol kolu yukarı uzat, göğsü açık tut',
        '3–5 nefes kal, taraf değiştir',
      ],
      type: ExerciseType.ucgenDurusuDegistirilmis,
    ),
    ExerciseData(
      name: 'Oturarak Öne Katlanma (Geniş Bacaklı)',
      description: 'İç uyluk ve sırtı esnetir, sindirime destek olur.',
      benefits: ['İç uyluk', 'Sırt esnekliği', 'Sindirim', 'Rahatlama'],
      steps: [
        'Yere otur, bacakları rahat edecek kadar geniş aç',
        'Omurgayı uzat, elleri öne doğru yürüt',
        'Karın için yer bırakarak yavaşça öne eğil',
        'Gerekirse bir minder ya da blok üstüne yaslan',
        '5 nefes derin derin bekle',
      ],
      type: ExerciseType.oturarakOneKatlanmaGenis,
    ),
  ];

  // ── 2. Trimester ──
  List<ExerciseData> _trimester2Exercises() => [
    ExerciseData(
      name: 'Dağ Duruşu + Kol Çevirme',
      description: 'Duruşu düzeltir, omuz gerginliğini açar.',
      benefits: ['Duruş', 'Omuz gerginliği', 'Denge', 'Enerji'],
      steps: [
        'Ayakları kalça genişliğinde aç, paralel tut',
        'Omurgayı uzat, omuzları geriye ve aşağı indir',
        'Kolları yanlardan yukarı kaldır, başın üstünde birleştir',
        'Nefes verirken kolları yavaşça aşağı indir',
        '5–8 tekrar nefese bağlı yap',
      ],
      type: ExerciseType.dagDurusuKolCevirme,
    ),
    ExerciseData(
      name: 'Sandalye Duruşu (Utkatasana)',
      description: 'Bacak ve kalça kaslarını güçlendirir.',
      benefits: ['Bacak gücü', 'Denge', 'Kalça', 'Doğuma hazırlık'],
      steps: [
        'Ayakları kalça genişliğinde aç',
        'Kolları öne uzat, bir blok tutabilirsin',
        'Dizleri bükerek sandalyeye oturur gibi aşağı in',
        'Sırtı dik tut, karnı çok sıkma',
        '5 nefes kal, yavaşça doğrul',
      ],
      type: ExerciseType.sandakyeDurusu,
    ),
    ExerciseData(
      name: 'Savaşçı I (Ön Diz Bükülmüş)',
      description: 'Bacakları güçlendirir, kalça esnetir.',
      benefits: ['Bacak gücü', 'Kalça esnekliği', 'Denge', 'Duruş'],
      steps: [
        'Bir ayağı öne, diğerini geriye al (arka topuk hafif içe)',
        'Ön dizi 90 derece bükerek kalçayı aşağı indir',
        'Kolları yukarı uzat, omuzları rahat bırak',
        'Göğsü öne doğru dik tut',
        '5 nefes kal, taraf değiştir',
      ],
      type: ExerciseType.savasci1,
    ),
    ExerciseData(
      name: 'Savaşçı II\'den Ters Savaşçıya',
      description: 'Yan kasları ve omurgayı esnetir.',
      benefits: ['Yan kaslar', 'Denge', 'Güç', 'Omurga'],
      steps: [
        'Savaşçı II pozisyonuna geç, ön diz bükülü',
        'Nefes alırken ön kolu yukarı uzat, arka kol arka bacağa kayar',
        'Göğsü açık tut, yana doğru hafifçe eğil',
        'Başı yukarıdaki ele bakabilir',
        '3–5 nefes kal, taraf değiştir',
      ],
      type: ExerciseType.tersSavasci2,
    ),
    ExerciseData(
      name: 'Geniş Bacaklı Öne Doğru Katlanma',
      description: 'İç uyluk ve sırtı esnetir, karna yer açar.',
      benefits: ['İç uyluk', 'Sırt esnekliği', 'Pelvik alan', 'Rahatlama'],
      steps: [
        'Ayakları geniş aç, parmaklar hafif içe',
        'Elleri bele koy, omurgayı uzat',
        'Kalçadan öne doğru yavaşça eğil',
        'Elleri yere ya da bloklara koy, karın için yer bırak',
        '5 nefes kal, yavaşça kalk',
      ],
      type: ExerciseType.genisBacakliOneEgilme,
    ),
    ExerciseData(
      name: 'Tanrıça Çömelmesi (Malasana)',
      description: 'Pelvik tabanı açar, doğuma hazırlar.',
      benefits: ['Pelvik taban', 'Doğuma hazırlık', 'Kalça açılımı', 'Güç'],
      steps: [
        'Ayakları geniş aç, parmaklar dışa dönük',
        'Bir blok üstüne oturacak şekilde çömel',
        'Elleri göğüs hizasında Namaste yap',
        'Dirseklerle dizleri hafifçe dışa it',
        '5–10 nefes kal, yavaşça kalk',
      ],
      type: ExerciseType.tanricaComelmesi,
    ),
    ExerciseData(
      name: 'Yan Açı Pozu (Parsvakonasana)',
      description: 'Yan vücudu uzatır, bacakları ve kalçayı güçlendirir.',
      benefits: ['Yan esneklik', 'Bacak gücü', 'Kalça açılımı', 'Duruş'],
      steps: [
        'Savaşçı II pozisyonuna geç',
        'Ön kolu ön dize ya da bloğa yasla',
        'Arka kolu başın üzerinden uzat, yan vücut tek bir çizgi',
        'Göğsü tavana doğru aç',
        '3–5 nefes kal, taraf değiştir',
      ],
      type: ExerciseType.yanAciPozu,
    ),
  ];

  // ── 3. Trimester ──
  List<ExerciseData> _trimester3Exercises() => [
    ExerciseData(
      name: 'Boyun ve Omuz Hareketleri',
      description: 'Omuz ve boyun gerginliğini açar, üst sırtı rahatlatır.',
      benefits: ['Boyun gerginliği', 'Omuz ağrısı', 'Üst sırt', 'Rahatlama'],
      steps: [
        'Bağdaş kurarak ya da bir yastık üstünde dik otur',
        'Başı yavaşça sağa-sola çevir, sonra yanlara yatır',
        'Omuzları kulaklara doğru kaldır, geriye ve aşağı indir',
        'Her iki yönde omuzları daire şeklinde çevir',
        'Nefes eşliğinde 5–8 tekrar yap',
      ],
      type: ExerciseType.boyunOmuzHareketleri,
    ),
    ExerciseData(
      name: 'Destek Yastığında Karın Nefesi',
      description: 'Diyaframı açar, bebek ve anne arasındaki bağı güçlendirir.',
      benefits: ['Nefes kapasitesi', 'Sakinlik', 'Oksijen akışı', 'Stres'],
      steps: [
        'Destek yastığı üstünde bağdaş kurarak otur',
        'Elleri karnın üstüne koy, sırt dik',
        'Burundan derin nefes al, karın şişsin',
        'Ağızdan yavaşça ver, karın içe çekilsin',
        '5–10 nefes döngüsü tekrarla',
      ],
      type: ExerciseType.destekYastigiNefes,
    ),
    ExerciseData(
      name: 'Oturarak Yanlara Esneme',
      description: 'Yan vücudu açar, nefes alanını genişletir.',
      benefits: ['Yan esneklik', 'Nefes', 'Üst sırt', 'Rahatlama'],
      steps: [
        'Bağdaş kurarak dik otur',
        'Bir elini yere koy, diğer kolunu başın üzerinden karşı yana uzat',
        'Yan vücudun esnediğini hisset',
        '3–4 nefes kal',
        'Diğer tarafa geç, tekrarla',
      ],
      type: ExerciseType.oturarakYanlaraEsneme,
    ),
    ExerciseData(
      name: 'Dizleri Geniş Çocuk Pozu (Balasana)',
      description: 'Karna yer açar, sırt ve kalçayı rahatlatır.',
      benefits: ['Sırt ağrısı', 'Kalça', 'Rahatlama', 'Nefes'],
      steps: [
        'Diz üstü otur, dizleri geniş aç',
        'Ayak başparmakları birleşik kalsın',
        'Önüne yastık ya da blok koy, göğsü üstüne yasla',
        'Kolları öne uzat ya da başın iki yanında dinlendir',
        '1–2 dakika derin nefesle kal',
      ],
      type: ExerciseType.dizlerAcikCocukPozu,
    ),
    ExerciseData(
      name: 'Destekli Çömelme (Duvar)',
      description: 'Pelvik tabanı açar, doğum kanalını hazırlar.',
      benefits: ['Doğuma hazırlık', 'Pelvik açılım', 'Bacak gücü', 'Rahatlama'],
      steps: [
        'Sırtını duvara daya, ayakları omuz genişliğinden biraz geniş aç',
        'Duvardan kayarak dizleri bük, sandalye gibi otur',
        'Sırtı duvara yaslı, dizler ayak parmakları hizasında',
        'Derin nefes al, pelvik tabanı gevşet',
        '5–10 nefes kal, yavaşça kalk',
      ],
      type: ExerciseType.destekliComelme,
    ),
    ExerciseData(
      name: 'Dörtlü Esneme (Yatarak)',
      description: 'Kalça ve siyatik bölgesini esnetir, bel ağrısını azaltır.',
      benefits: ['Kalça esnekliği', 'Siyatik', 'Bel ağrısı', 'Rahatlama'],
      steps: [
        'Sırt üstü uzan, dizleri bük, ayaklar yerde',
        'Sağ ayak bileğini sol dizin üstüne koy (4 şekli)',
        'Sol uyluğun arkasından tut, nazikçe kendine doğru çek',
        'Sağ kalçanın dışında esneme hisset',
        '5 nefes kal, taraf değiştir',
      ],
      type: ExerciseType.dortluEsneme,
    ),
    ExerciseData(
      name: 'Top Üzerinde Kalça Çevirme',
      description: 'Bebeği doğru pozisyona yönlendirir, bel ağrısını azaltır.',
      benefits: ['Bel ağrısı', 'Bebek pozisyonu', 'Pelvik rahatlama', 'Dolaşım'],
      steps: [
        'Doğum topuna otur, ayaklar yerde sabit',
        'Kalçayla yavaş yavaş daire çiz',
        'Saat yönünde 10 daire',
        'Ters yönde 10 daire',
        'Sonra sekiz (8) şeklinde hareketlendir',
      ],
      type: ExerciseType.topUzerindeKalcaDaireleri,
    ),
    ExerciseData(
      name: 'Duvara Destekli Aşağıya Bakan Köpek',
      description: 'Sırtı uzatır, omurgayı açar, karın bölgesine baskı yapmaz.',
      benefits: ['Sırt ağrısı', 'Omurga', 'Omuz esnekliği', 'Rahatlama'],
      steps: [
        'Duvarın önünde dur, avuç içlerini omuz hizasında duvara yasla',
        'Küçük adımlarla geriye yürü, gövdeyi öne eğ',
        'Kollar ve sırt tek çizgi olacak şekilde "L" şekli oluştur',
        'Başı kollar arasında serbest bırak',
        '5–8 nefes kal, yavaşça geri yürü',
      ],
      type: ExerciseType.duvaraDestekliKopek,
    ),
  ];

  // ── Doğurganlık egzersizleri ──
  List<ExerciseData> _fertilityExercises() => [
    ExerciseData(
      name: 'Yatarak Tanrıça',
      description: 'Pelvik taban kaslarını aktive eder.',
      benefits: ['Pelvik taban', 'Doğurganlık', 'Hormon dengesi', 'Rahatlama'],
      steps: [
        'Sırt üstü uzan',
        'Dizleri büküp ayak tabanlarını birleştir',
        'Derin nefes alırken pelvik tabanı gevşet',
        'Nefes verirken hafifçe kas',
        '10 tekrar yap',
      ],
      type: ExerciseType.recliningGoddess,
    ),
    ExerciseData(
      name: 'Kelebek Pozu',
      description: 'Pelvik bölgeyi açar, kan dolaşımını artırır.',
      benefits: ['Pelvik açılım', 'Kan dolaşımı', 'Doğurganlık', 'Gerilim'],
      steps: [
        'Otur, ayak tabanlarını birleştir',
        'Topukları kasığa çek',
        'Omurgayı dik tut',
        'Her nefeste kasıkların biraz daha açılmasına izin ver',
        '2–3 dakika kal',
      ],
      type: ExerciseType.butterfly,
    ),
    ExerciseData(
      name: 'Aşağı Bakan Köpek',
      description: 'Hormonal dengeyi destekler, stresi azaltır.',
      benefits: ['Hormon dengesi', 'Stres', 'Kan dolaşımı', 'Enerji'],
      steps: [
        'Dörtnala pozisyona geç',
        'Kalçayı yukarı iterek ters V oluştur',
        'Derin nefes al, kafayı serbest bırak',
        'Topukları yere basmaya çalış',
        '5–8 nefes tut',
      ],
      type: ExerciseType.downDog,
    ),
    ExerciseData(
      name: 'Bacaklar Duvarda',
      description: 'Pelvik bölgeye kan akışını artırır.',
      benefits: ['Pelvik kan akışı', 'Doğurganlık', 'Yorgunluk', 'Rahatlama'],
      steps: [
        'Duvara yakın yan uzan',
        'Bacakları duvara dayayarak yukarı kaldır',
        'Kolları yana aç, gözleri kapat',
        'Derin nefes al, pelvikte ısıyı hisset',
        '10 dakika kal',
      ],
      type: ExerciseType.legsUpWall,
    ),
  ];
}

// ── Trimester seçici widget ──
class _TrimesterPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _TrimesterPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2840) : const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3D2A5E) : const Color(0xFFD8B4FE),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [1, 2, 3].map((t) {
          final isSelected = selected == t;
          final weeks = isEn
              ? (t == 1 ? 'Wk 0–12' : t == 2 ? 'Wk 13–27' : 'Wk 28–40')
              : (t == 1 ? '0–12. hafta' : t == 2 ? '13–27. hafta' : '28–40. hafta');
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEn ? 'Trimester $t' : '$t. Trimester',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white54 : const Color(0xFF7C3AED)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weeks,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark ? Colors.white38 : const Color(0xFFA78BFA)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PregnancyWarningCard extends StatelessWidget {
  const _PregnancyWarningCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final riskyItems = isEn ? _riskyItemsEn : _riskyItemsTr;
    final emergencyItems = isEn ? _emergencyItemsEn : _emergencyItemsTr;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFBBF24),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn ? 'Risky Poses in Pregnancy' : 'Hamilelikte Riskli Pozlar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isEn
                ? 'Regardless of your stage of pregnancy, the following poses are considered risky:'
                : 'Hamileliğin hangi aşamasında olursan ol, aşağıdaki pozlar riskli kabul edilir:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...riskyItems.map((item) => _RiskyItem(text: item, isDark: isDark)),
          const SizedBox(height: 12),
          Divider(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFBBF24), height: 1),
          const SizedBox(height: 12),
          // Acil durum başlığı
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded, color: Color(0xFFEF4444), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'Stop exercise immediately and call your doctor if:'
                      : 'Egzersizi anında bırakıp doktorunu araman gereken durumlar:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...emergencyItems.map((item) => _BulletItem(text: item, isDark: isDark)),
          const SizedBox(height: 12),
          // Alt uyarı kutusu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF4C1D95) : const Color(0xFFC4B5FD),
              ),
            ),
            child: Text(
              isEn
                  ? '⚠️  Your body is the best guide. If a movement doesn\'t feel right, skip it. Always tell your instructor how many weeks pregnant you are!'
                  : '⚠️  En iyi rehber kendi vücudundur. Eğer bir hareket "doğru" hissettirmiyorsa, o hareketi yapma. Eğitmenine mutlaka kaç haftalık hamile olduğunu belirtmeyi unutma!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF5B21B6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _riskyItemsTr = [
    'a) Amuda Kalkma / Baş Üstü Duruş — Düşme riski ve yüksek tansiyon sebebiyle.',
    'b) Derin Geriye Eğilmeler (Deve Pozu vb.) — Karın kaslarını aşırı gerer.',
    'c) Karın Üstü Yatış — Bebeğe doğrudan baskı yapar.',
    'd) Derin Twistler (Bükülmeler) — Rahmi sıkıştırabilir.',
  ];

  static const _riskyItemsEn = [
    'a) Headstands / Inversions — Risk of falling and high blood pressure.',
    'b) Deep Backbends (Camel Pose etc.) — Overstretches the abdominal muscles.',
    'c) Lying on the Stomach — Puts direct pressure on the baby.',
    'd) Deep Twists — Can compress the uterus.',
  ];

  static const _emergencyItemsTr = [
    'Vajinal kanama veya sıvı gelişi.',
    'Şiddetli baş ağrısı veya baş dönmesi.',
    'Saatte 4\'ten fazla kasılma hissetmek.',
    'Baldırlarda aşırı ağrı veya ani şişlik.',
  ];

  static const _emergencyItemsEn = [
    'Vaginal bleeding or fluid leakage.',
    'Severe headache or dizziness.',
    'More than 4 contractions per hour.',
    'Severe calf pain or sudden swelling.',
  ];
}

class _RiskyItem extends StatelessWidget {
  final String text;
  final bool isDark;
  const _RiskyItem({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.block_rounded, size: 13, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black87,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final bool isDark;
  const _BulletItem({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black87,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
