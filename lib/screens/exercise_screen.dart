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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final exercises = _exercisesForMode(mode, _trimester, isEn);

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

  List<ExerciseData> _exercisesForMode(AppMode mode, int trimester, bool isEn) {
    switch (mode) {
      case AppMode.reglTakip:
        return _reglExercises(isEn);
      case AppMode.hamileTakip:
        switch (trimester) {
          case 1: return _trimester1Exercises(isEn);
          case 2: return _trimester2Exercises(isEn);
          case 3: return _trimester3Exercises(isEn);
          default: return _trimester1Exercises(isEn);
        }
      case AppMode.hamilleKalma:
        return _fertilityExercises(isEn);
    }
  }

  // ── Regl egzersizleri ──
  List<ExerciseData> _reglExercises(bool isEn) => [
    ExerciseData(
      name: isEn ? 'Bow Pose' : 'Yay Pozu',
      description: isEn
          ? 'Stretches the abdominal muscles, eases cramps.'
          : 'Karın kaslarını esnetir, krampları hafifletir.',
      benefits: isEn
          ? ['Cramp pain', 'Abdominal tension', 'Back pain', 'Stress']
          : ['Kramp ağrısı', 'Karın gerginliği', 'Sırt ağrısı', 'Stres'],
      steps: isEn
          ? [
              'Lie face down, arms at your sides',
              'Bend your knees and bring heels toward hips',
              'Hold your ankles with your hands',
              'Exhale and lift chest and legs off the floor',
              'Hold 20–30 sec, release',
            ]
          : [
              'Yüz üstü yat, kollar yanında',
              'Dizleri büküp topukları kalçaya yaklaştır',
              'Ellerinle ayak bileklerini tut',
              'Nefes verirken gövdeyi ve bacakları yerden kaldır',
              '20–30 sn tut, salın',
            ],
      type: ExerciseType.bow,
    ),
    ExerciseData(
      name: isEn ? 'Child\'s Pose' : 'Çocuk Pozu',
      description: isEn
          ? 'Relaxes the lower back and abdominal muscles.'
          : 'Alt sırt ve karın kaslarını gevşetir.',
      benefits: isEn
          ? ['Lower back pain', 'Abdominal cramps', 'Mental calm', 'Tension']
          : ['Alt sırt ağrısı', 'Karın krampı', 'Zihin rahatlaması', 'Gerginlik'],
      steps: isEn
          ? [
              'Kneel and sit back on your heels',
              'Fold forward, extending your arms ahead',
              'Rest your forehead on the floor',
              'Breathe deeply, relax a little more with each breath',
              'Stay for 1–2 minutes',
            ]
          : [
              'Diz üstü otur, topukların üstüne çök',
              'Kolları öne uzatarak öne eğil',
              'Alnını yere koy',
              'Derin nefes al, her nefeste biraz daha gevşe',
              '1–2 dakika bekle',
            ],
      type: ExerciseType.child,
    ),
    ExerciseData(
      name: isEn ? 'Downward-Facing Dog' : 'Aşağı Bakan Köpek',
      description: isEn
          ? 'Stretches the whole body, boosts circulation.'
          : 'Tüm vücudu esnetir, kan dolaşımını artırır.',
      benefits: isEn
          ? ['Headache', 'Back pain', 'Fatigue', 'Circulation']
          : ['Baş ağrısı', 'Sırt ağrısı', 'Yorgunluk', 'Kan dolaşımı'],
      steps: isEn
          ? [
              'Start on all fours',
              'Tuck your toes and lift your knees off the floor',
              'Push your hips up into an inverted V',
              'Try to press your heels to the floor',
              'Hold for 5 breaths, repeat',
            ]
          : [
              'Dörtnala pozisyona geç',
              'Parmak uçlarına bas, dizleri yerden kaldır',
              'Kalçayı yukarı iterek ters V oluştur',
              'Topukları yere basmaya çalış',
              '5 nefes tut, tekrarla',
            ],
      type: ExerciseType.downDog,
    ),
    ExerciseData(
      name: isEn ? 'Reclining Goddess' : 'Yatarak Tanrıça',
      description: isEn
          ? 'Relaxes the hips and pelvic area.'
          : 'Kalça ve pelvik bölgeyi rahatlatır.',
      benefits: isEn
          ? ['Pelvic pain', 'Hip tension', 'Inner thighs', 'Relaxation']
          : ['Pelvik ağrı', 'Kalça gerginliği', 'İç uyluk', 'Rahatlama'],
      steps: isEn
          ? [
              'Lie on your back, bend knees and bring soles together',
              'Let your knees fall open to the sides',
              'Open your arms out, palms facing up',
              'Close your eyes, breathe deeply',
              'Stay still for 2–3 minutes',
            ]
          : [
              'Sırt üstü uzan, dizleri büküp ayak tabanlarını birleştir',
              'Dizlerin yana doğru düşmesine izin ver',
              'Kolları iki yana aç, avuçlar yukarı',
              'Gözleri kapat, derin nefes al',
              '2–3 dakika hareketsiz kal',
            ],
      type: ExerciseType.recliningGoddess,
    ),
    ExerciseData(
      name: isEn ? 'Legs Up the Wall' : 'Bacaklar Duvarda',
      description: isEn
          ? 'Reduces swelling and pain.'
          : 'Şişliği ve ağrıyı azaltır.',
      benefits: isEn
          ? ['Leg swelling', 'Fatigue', 'Lower back pain', 'Circulation']
          : ['Bacak şişliği', 'Yorgunluk', 'Bel ağrısı', 'Kan dolaşımı'],
      steps: isEn
          ? [
              'Lie on your side close to a wall',
              'Swing your legs up and rest them on the wall',
              'Open your arms to the sides, relax',
              'Keep your legs as straight as possible',
              'Stay for 5–10 minutes',
            ]
          : [
              'Duvara yakın yan uzan',
              'Bacakları yukarı kaldırıp duvara daya',
              'Kolları iki yana aç, rahatla',
              'Bacakları mümkün olduğunca dik tut',
              '5–10 dakika bekle',
            ],
      type: ExerciseType.legsUpWall,
    ),
    ExerciseData(
      name: isEn ? 'Camel Pose' : 'Deve Pozu',
      description: isEn
          ? 'Stretches the abdomen and pelvic area.'
          : 'Karın ve pelvik bölgeyi esnetir.',
      benefits: isEn
          ? ['Abdominal cramps', 'Pelvic opening', 'Spine flexibility', 'Energy']
          : ['Karın krampı', 'Pelvik açılım', 'Omurga esnekliği', 'Enerji'],
      steps: isEn
          ? [
              'Kneel upright',
              'Place hands on your lower back, elbows back',
              'Open your chest and let your head drop back',
              'If comfortable, reach your hands to your heels',
              'Hold 20–30 sec, come back slowly',
            ]
          : [
              'Diz üstünde dik otur',
              'Elleri bele koy, dirsekler arkada',
              'Göğsü öne açarken başı geriye at',
              'İleri gidebilirsen elleri topuklara götür',
              '20–30 sn tut, yavaşça dön',
            ],
      type: ExerciseType.camel,
    ),
    ExerciseData(
      name: isEn ? 'Butterfly Pose' : 'Kelebek Pozu',
      description: isEn
          ? 'Stretches the inner thighs and groin.'
          : 'İç uylukları ve kasığı esnetir.',
      benefits: isEn
          ? ['Pelvic tension', 'Inner thighs', 'Cramps', 'Circulation']
          : ['Pelvik gerginlik', 'İç uyluk', 'Kramp', 'Dolaşım'],
      steps: isEn
          ? [
              'Sit and bring the soles of your feet together',
              'Draw your heels toward your groin',
              'Clasp your hands over your feet',
              'Keep your spine tall, let knees and groin sink down',
              'Hold 1–2 min, flutter knees like a butterfly',
            ]
          : [
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
  List<ExerciseData> _trimester1Exercises(bool isEn) => [
    ExerciseData(
      name: isEn ? 'Seated Cat-Cow' : 'Oturan Kedi-İnek',
      description: isEn
          ? 'Mobilizes the spine, eases nausea.'
          : 'Omurgayı mobilize eder, bulantıyı azaltır.',
      benefits: isEn
          ? ['Back pain', 'Nausea', 'Spine', 'Flexibility']
          : ['Sırt ağrısı', 'Bulantı', 'Omurga', 'Esneklik'],
      steps: isEn
          ? [
              'Sit comfortably cross-legged',
              'Inhale, open your chest and lift your head slightly',
              'Exhale, round your back and tuck your chin toward chest',
              'Repeat slowly and smoothly with your breath',
              'Do 8–10 repetitions',
            ]
          : [
              'Bağdaş kurarak rahat bir şekilde otur',
              'Nefes alırken göğsü öne aç, başı hafifçe yukarı kaldır',
              'Nefes verirken sırtı yuvarla, çeneyi göğse yaklaştır',
              'Yavaş ve akıcı şekilde nefese bağlı tekrarla',
              '8–10 tekrar yap',
            ],
      type: ExerciseType.oturanKediInek,
    ),
    ExerciseData(
      name: isEn ? 'Side Body Stretch' : 'Yan Vücut Esnetme',
      description: isEn
          ? 'Makes space for the growing uterus, stretches side muscles.'
          : 'Büyüyen rahme alan açar, yan kasları esnetir.',
      benefits: isEn
          ? ['Side pain', 'Flexibility', 'Relaxation', 'Breath']
          : ['Yan ağrı', 'Esneklik', 'Rahatlama', 'Nefes'],
      steps: isEn
          ? [
              'Sit upright cross-legged',
              'Place one hand on the floor, reach the other arm overhead to the opposite side',
              'Feel the stretch along your side',
              'Hold for 3 breaths',
              'Switch sides and repeat',
            ]
          : [
              'Bağdaş kurarak dik otur',
              'Bir elini yere koy, diğer kolunu başın üzerinden karşı yana uzat',
              'Yan tarafta esneme hissini yakala',
              '3 nefes boyunca bekle',
              'Diğer tarafa geç ve tekrarla',
            ],
      type: ExerciseType.yanVucutEstretme,
    ),
    ExerciseData(
      name: isEn ? 'Easy Pose & Neck Movements' : 'Kolay Poz ve Boyun Hareketi',
      description: isEn
          ? 'Reduces neck and shoulder tension, calms the mind.'
          : 'Boyun ve omuz gerginliğini azaltır, zihni sakinleştirir.',
      benefits: isEn
          ? ['Neck tension', 'Shoulder relief', 'Stress', 'Focus']
          : ['Boyun gerginliği', 'Omuz rahatlaması', 'Stres', 'Odak'],
      steps: isEn
          ? [
              'Sit upright in Sukhasana (easy pose)',
              'Slowly turn your head right, then left',
              'Gently lower your head forward and back',
              'Finally tilt your head side to side, ears toward shoulders',
              'Give 3–4 breaths in each direction',
            ]
          : [
              'Sukhasana (kolay poz) pozisyonunda dik otur',
              'Başı yavaşça sağa, sonra sola çevir',
              'Başı öne ve arkaya nazikçe indir',
              'Son olarak başı iki yana yatırarak kulakları omuzlara yaklaştır',
              'Her yöne 3–4 nefes ver',
            ],
      type: ExerciseType.kolayPozBoyun,
    ),
    ExerciseData(
      name: isEn ? 'Thread the Needle' : 'İğne İpliğinden Geçirme',
      description: isEn
          ? 'Opens tension in the back and shoulders, gently twists the spine.'
          : 'Sırt ve omuzlardaki gerginliği açar, omurgayı nazikçe döndürür.',
      benefits: isEn
          ? ['Upper back pain', 'Shoulder flexibility', 'Spine mobility', 'Relaxation']
          : ['Üst sırt ağrısı', 'Omuz esnekliği', 'Omurga mobilitesi', 'Rahatlama'],
      steps: isEn
          ? [
              'Come to all fours (hands under shoulders, knees under hips)',
              'Reach your right arm under the left arm toward the floor',
              'Rest your right shoulder and cheek on the floor or a pillow',
              'Your left hand can reach forward or support your lower back',
              'Stay 5 breaths, switch sides',
            ]
          : [
              'Dörtnala pozisyona geç (eller omuz, dizler kalça altında)',
              'Sağ kolu sol kolun altından yere doğru uzat',
              'Sağ omuz ve yanağı yere ya da yastığa yasla',
              'Sol el öne uzanabilir ya da bele destek verebilir',
              '5 nefes kal, taraf değiştir',
            ],
      type: ExerciseType.igneIpliktenGecirme,
    ),
    ExerciseData(
      name: isEn ? 'Downward Dog (Bent Knees)' : 'Aşağıya Bakan Köpek (Dizler Bükülmüş)',
      description: isEn
          ? 'Lengthens the spine and energizes without pressing on the abdomen.'
          : 'Omurgayı uzatır, karın bölgesine baskı yapmadan enerji verir.',
      benefits: isEn
          ? ['Back pain', 'Fatigue', 'Circulation', 'Energy']
          : ['Sırt ağrısı', 'Yorgunluk', 'Kan dolaşımı', 'Enerji'],
      steps: isEn
          ? [
              'Come to all fours',
              'Keep knees slightly bent and push your hips up',
              'Heels can lift; focus on lengthening your back',
              'Let your head hang freely between your arms',
              'Stay 5 breaths, come back slowly',
            ]
          : [
              'Dörtnala pozisyona geç',
              'Dizleri hafifçe bükülü tutarak kalçayı yukarı it',
              'Topuklar yerden kalkabilir, sırtı uzatmaya odaklan',
              'Başı kollar arasında serbest bırak',
              '5 nefes kal, yavaşça geri gel',
            ],
      type: ExerciseType.asagiBakanKopek,
    ),
    ExerciseData(
      name: isEn ? 'Low Lunge (Back Knee Down)' : 'Alçak Hamle (Arka Diz Yere)',
      description: isEn
          ? 'Improves hip flexibility, opens the legs.'
          : 'Kalça esnekliğini artırır, bacakları açar.',
      benefits: isEn
          ? ['Hip flexibility', 'Leg strength', 'Pelvic opening', 'Balance']
          : ['Kalça esnekliği', 'Bacak gücü', 'Pelvik açılım', 'Denge'],
      steps: isEn
          ? [
              'Step your right foot forward, knee bent 90 degrees',
              'Lower your left knee to the floor, add a towel or pillow if needed',
              'Sink your hips down slowly, hands on your front knee',
              'Keep your chest tall, lengthen your back',
              'Stay 5 breaths, switch sides',
            ]
          : [
              'Sağ ayağı öne al, diz 90 derece bükülü olacak şekilde',
              'Sol dizi yere indir, gerekirse altına havlu ya da yastık koy',
              'Kalçayı yavaşça aşağı indir, ellerini ön dizin üstüne koy',
              'Göğsü dik tut, sırtını uzat',
              '5 nefes kal, taraf değiştir',
            ],
      type: ExerciseType.alcakHamle,
    ),
    ExerciseData(
      name: isEn ? 'Triangle Pose (Modified)' : 'Üçgen Duruşu (Değiştirilmiş)',
      description: isEn
          ? 'Lengthens the side body, strengthens the legs.'
          : 'Yan vücudu uzatır, bacakları güçlendirir.',
      benefits: isEn
          ? ['Side muscles', 'Leg strength', 'Balance', 'Flexibility']
          : ['Yan kaslar', 'Bacak gücü', 'Denge', 'Esneklik'],
      steps: isEn
          ? [
              'Step your feet wide, right toes forward, left toes slightly in',
              'Open your arms to the sides at shoulder height',
              'Lean sideways, resting your right hand on your leg or a block',
              'Reach your left arm up, keep your chest open',
              'Stay 3–5 breaths, switch sides',
            ]
          : [
              'Ayakları geniş aç, sağ ayak parmakları öne, sol parmaklar hafif içe',
              'Kolları yana aç, omuz hizasında',
              'Sağ eli sağ bacağa ya da bloğa yaslayarak yan eğil',
              'Sol kolu yukarı uzat, göğsü açık tut',
              '3–5 nefes kal, taraf değiştir',
            ],
      type: ExerciseType.ucgenDurusuDegistirilmis,
    ),
    ExerciseData(
      name: isEn ? 'Seated Forward Fold (Wide Legs)' : 'Oturarak Öne Katlanma (Geniş Bacaklı)',
      description: isEn
          ? 'Stretches inner thighs and back, supports digestion.'
          : 'İç uyluk ve sırtı esnetir, sindirime destek olur.',
      benefits: isEn
          ? ['Inner thighs', 'Back flexibility', 'Digestion', 'Relaxation']
          : ['İç uyluk', 'Sırt esnekliği', 'Sindirim', 'Rahatlama'],
      steps: isEn
          ? [
              'Sit on the floor, open your legs comfortably wide',
              'Lengthen your spine, walk your hands forward',
              'Fold forward slowly, leaving room for your belly',
              'Rest on a cushion or block if needed',
              'Breathe deeply for 5 breaths',
            ]
          : [
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
  List<ExerciseData> _trimester2Exercises(bool isEn) => [
    ExerciseData(
      name: isEn ? 'Mountain Pose + Arm Circles' : 'Dağ Duruşu + Kol Çevirme',
      description: isEn
          ? 'Improves posture, opens shoulder tension.'
          : 'Duruşu düzeltir, omuz gerginliğini açar.',
      benefits: isEn
          ? ['Posture', 'Shoulder tension', 'Balance', 'Energy']
          : ['Duruş', 'Omuz gerginliği', 'Denge', 'Enerji'],
      steps: isEn
          ? [
              'Stand feet hip-width apart, parallel',
              'Lengthen your spine, roll shoulders back and down',
              'Raise arms up from the sides, join them overhead',
              'Exhale and lower your arms slowly',
              'Do 5–8 reps with your breath',
            ]
          : [
              'Ayakları kalça genişliğinde aç, paralel tut',
              'Omurgayı uzat, omuzları geriye ve aşağı indir',
              'Kolları yanlardan yukarı kaldır, başın üstünde birleştir',
              'Nefes verirken kolları yavaşça aşağı indir',
              '5–8 tekrar nefese bağlı yap',
            ],
      type: ExerciseType.dagDurusuKolCevirme,
    ),
    ExerciseData(
      name: isEn ? 'Chair Pose (Utkatasana)' : 'Sandalye Duruşu (Utkatasana)',
      description: isEn
          ? 'Strengthens the leg and hip muscles.'
          : 'Bacak ve kalça kaslarını güçlendirir.',
      benefits: isEn
          ? ['Leg strength', 'Balance', 'Hips', 'Birth prep']
          : ['Bacak gücü', 'Denge', 'Kalça', 'Doğuma hazırlık'],
      steps: isEn
          ? [
              'Stand with feet hip-width apart',
              'Reach your arms forward, you can hold a block',
              'Bend your knees and lower as if sitting in a chair',
              'Keep your back tall, don\'t clench your belly',
              'Stay 5 breaths, rise slowly',
            ]
          : [
              'Ayakları kalça genişliğinde aç',
              'Kolları öne uzat, bir blok tutabilirsin',
              'Dizleri bükerek sandalyeye oturur gibi aşağı in',
              'Sırtı dik tut, karnı çok sıkma',
              '5 nefes kal, yavaşça doğrul',
            ],
      type: ExerciseType.sandakyeDurusu,
    ),
    ExerciseData(
      name: isEn ? 'Warrior I (Front Knee Bent)' : 'Savaşçı I (Ön Diz Bükülmüş)',
      description: isEn
          ? 'Strengthens the legs, stretches the hips.'
          : 'Bacakları güçlendirir, kalça esnetir.',
      benefits: isEn
          ? ['Leg strength', 'Hip flexibility', 'Balance', 'Posture']
          : ['Bacak gücü', 'Kalça esnekliği', 'Denge', 'Duruş'],
      steps: isEn
          ? [
              'Step one foot forward, the other back (back heel slightly in)',
              'Bend your front knee 90 degrees and lower your hips',
              'Reach your arms up, relax your shoulders',
              'Keep your chest tall and facing forward',
              'Stay 5 breaths, switch sides',
            ]
          : [
              'Bir ayağı öne, diğerini geriye al (arka topuk hafif içe)',
              'Ön dizi 90 derece bükerek kalçayı aşağı indir',
              'Kolları yukarı uzat, omuzları rahat bırak',
              'Göğsü öne doğru dik tut',
              '5 nefes kal, taraf değiştir',
            ],
      type: ExerciseType.savasci1,
    ),
    ExerciseData(
      name: isEn ? 'Warrior II to Reverse Warrior' : 'Savaşçı II\'den Ters Savaşçıya',
      description: isEn
          ? 'Stretches the side muscles and spine.'
          : 'Yan kasları ve omurgayı esnetir.',
      benefits: isEn
          ? ['Side muscles', 'Balance', 'Strength', 'Spine']
          : ['Yan kaslar', 'Denge', 'Güç', 'Omurga'],
      steps: isEn
          ? [
              'Come to Warrior II, front knee bent',
              'Inhale, reach the front arm up, back arm slides down the back leg',
              'Keep your chest open, lean gently to the side',
              'Your gaze can follow the top hand',
              'Stay 3–5 breaths, switch sides',
            ]
          : [
              'Savaşçı II pozisyonuna geç, ön diz bükülü',
              'Nefes alırken ön kolu yukarı uzat, arka kol arka bacağa kayar',
              'Göğsü açık tut, yana doğru hafifçe eğil',
              'Başı yukarıdaki ele bakabilir',
              '3–5 nefes kal, taraf değiştir',
            ],
      type: ExerciseType.tersSavasci2,
    ),
    ExerciseData(
      name: isEn ? 'Wide-Legged Forward Fold' : 'Geniş Bacaklı Öne Doğru Katlanma',
      description: isEn
          ? 'Stretches inner thighs and back, makes room for the belly.'
          : 'İç uyluk ve sırtı esnetir, karna yer açar.',
      benefits: isEn
          ? ['Inner thighs', 'Back flexibility', 'Pelvic space', 'Relaxation']
          : ['İç uyluk', 'Sırt esnekliği', 'Pelvik alan', 'Rahatlama'],
      steps: isEn
          ? [
              'Step your feet wide, toes slightly in',
              'Place hands on your hips, lengthen your spine',
              'Fold forward slowly from the hips',
              'Place hands on the floor or blocks, leave room for the belly',
              'Stay 5 breaths, rise slowly',
            ]
          : [
              'Ayakları geniş aç, parmaklar hafif içe',
              'Elleri bele koy, omurgayı uzat',
              'Kalçadan öne doğru yavaşça eğil',
              'Elleri yere ya da bloklara koy, karın için yer bırak',
              '5 nefes kal, yavaşça kalk',
            ],
      type: ExerciseType.genisBacakliOneEgilme,
    ),
    ExerciseData(
      name: isEn ? 'Goddess Squat (Malasana)' : 'Tanrıça Çömelmesi (Malasana)',
      description: isEn
          ? 'Opens the pelvic floor, prepares for birth.'
          : 'Pelvik tabanı açar, doğuma hazırlar.',
      benefits: isEn
          ? ['Pelvic floor', 'Birth prep', 'Hip opening', 'Strength']
          : ['Pelvik taban', 'Doğuma hazırlık', 'Kalça açılımı', 'Güç'],
      steps: isEn
          ? [
              'Step your feet wide, toes pointing out',
              'Squat down to sit on a block',
              'Bring hands to Namaste at chest height',
              'Gently press your knees out with your elbows',
              'Stay 5–10 breaths, rise slowly',
            ]
          : [
              'Ayakları geniş aç, parmaklar dışa dönük',
              'Bir blok üstüne oturacak şekilde çömel',
              'Elleri göğüs hizasında Namaste yap',
              'Dirseklerle dizleri hafifçe dışa it',
              '5–10 nefes kal, yavaşça kalk',
            ],
      type: ExerciseType.tanricaComelmesi,
    ),
    ExerciseData(
      name: isEn ? 'Side Angle Pose (Parsvakonasana)' : 'Yan Açı Pozu (Parsvakonasana)',
      description: isEn
          ? 'Lengthens the side body, strengthens legs and hips.'
          : 'Yan vücudu uzatır, bacakları ve kalçayı güçlendirir.',
      benefits: isEn
          ? ['Side flexibility', 'Leg strength', 'Hip opening', 'Posture']
          : ['Yan esneklik', 'Bacak gücü', 'Kalça açılımı', 'Duruş'],
      steps: isEn
          ? [
              'Come to Warrior II',
              'Rest your front forearm on your front knee or a block',
              'Reach your back arm overhead, side body in one line',
              'Open your chest toward the ceiling',
              'Stay 3–5 breaths, switch sides',
            ]
          : [
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
  List<ExerciseData> _trimester3Exercises(bool isEn) => [
    ExerciseData(
      name: isEn ? 'Neck & Shoulder Movements' : 'Boyun ve Omuz Hareketleri',
      description: isEn
          ? 'Opens shoulder and neck tension, relaxes the upper back.'
          : 'Omuz ve boyun gerginliğini açar, üst sırtı rahatlatır.',
      benefits: isEn
          ? ['Neck tension', 'Shoulder pain', 'Upper back', 'Relaxation']
          : ['Boyun gerginliği', 'Omuz ağrısı', 'Üst sırt', 'Rahatlama'],
      steps: isEn
          ? [
              'Sit upright cross-legged or on a cushion',
              'Slowly turn your head side to side, then tilt to the sides',
              'Lift your shoulders toward your ears, roll them back and down',
              'Circle your shoulders in both directions',
              'Do 5–8 reps with your breath',
            ]
          : [
              'Bağdaş kurarak ya da bir yastık üstünde dik otur',
              'Başı yavaşça sağa-sola çevir, sonra yanlara yatır',
              'Omuzları kulaklara doğru kaldır, geriye ve aşağı indir',
              'Her iki yönde omuzları daire şeklinde çevir',
              'Nefes eşliğinde 5–8 tekrar yap',
            ],
      type: ExerciseType.boyunOmuzHareketleri,
    ),
    ExerciseData(
      name: isEn ? 'Belly Breathing on a Bolster' : 'Destek Yastığında Karın Nefesi',
      description: isEn
          ? 'Opens the diaphragm, strengthens the bond between baby and mother.'
          : 'Diyaframı açar, bebek ve anne arasındaki bağı güçlendirir.',
      benefits: isEn
          ? ['Breath capacity', 'Calm', 'Oxygen flow', 'Stress']
          : ['Nefes kapasitesi', 'Sakinlik', 'Oksijen akışı', 'Stres'],
      steps: isEn
          ? [
              'Sit cross-legged on a bolster',
              'Place your hands on your belly, back tall',
              'Inhale deeply through your nose, let your belly expand',
              'Exhale slowly through your mouth, belly draws in',
              'Repeat 5–10 breath cycles',
            ]
          : [
              'Destek yastığı üstünde bağdaş kurarak otur',
              'Elleri karnın üstüne koy, sırt dik',
              'Burundan derin nefes al, karın şişsin',
              'Ağızdan yavaşça ver, karın içe çekilsin',
              '5–10 nefes döngüsü tekrarla',
            ],
      type: ExerciseType.destekYastigiNefes,
    ),
    ExerciseData(
      name: isEn ? 'Seated Side Stretch' : 'Oturarak Yanlara Esneme',
      description: isEn
          ? 'Opens the side body, expands breathing space.'
          : 'Yan vücudu açar, nefes alanını genişletir.',
      benefits: isEn
          ? ['Side flexibility', 'Breath', 'Upper back', 'Relaxation']
          : ['Yan esneklik', 'Nefes', 'Üst sırt', 'Rahatlama'],
      steps: isEn
          ? [
              'Sit upright cross-legged',
              'Place one hand on the floor, reach the other arm overhead to the opposite side',
              'Feel the stretch along your side body',
              'Hold for 3–4 breaths',
              'Switch sides, repeat',
            ]
          : [
              'Bağdaş kurarak dik otur',
              'Bir elini yere koy, diğer kolunu başın üzerinden karşı yana uzat',
              'Yan vücudun esnediğini hisset',
              '3–4 nefes kal',
              'Diğer tarafa geç, tekrarla',
            ],
      type: ExerciseType.oturarakYanlaraEsneme,
    ),
    ExerciseData(
      name: isEn ? 'Wide-Knee Child\'s Pose (Balasana)' : 'Dizleri Geniş Çocuk Pozu (Balasana)',
      description: isEn
          ? 'Makes room for the belly, relaxes the back and hips.'
          : 'Karna yer açar, sırt ve kalçayı rahatlatır.',
      benefits: isEn
          ? ['Back pain', 'Hips', 'Relaxation', 'Breath']
          : ['Sırt ağrısı', 'Kalça', 'Rahatlama', 'Nefes'],
      steps: isEn
          ? [
              'Kneel and open your knees wide',
              'Keep your big toes touching',
              'Place a pillow or block in front, rest your chest on it',
              'Reach your arms forward or rest them beside your head',
              'Stay 1–2 minutes with deep breaths',
            ]
          : [
              'Diz üstü otur, dizleri geniş aç',
              'Ayak başparmakları birleşik kalsın',
              'Önüne yastık ya da blok koy, göğsü üstüne yasla',
              'Kolları öne uzat ya da başın iki yanında dinlendir',
              '1–2 dakika derin nefesle kal',
            ],
      type: ExerciseType.dizlerAcikCocukPozu,
    ),
    ExerciseData(
      name: isEn ? 'Supported Squat (Wall)' : 'Destekli Çömelme (Duvar)',
      description: isEn
          ? 'Opens the pelvic floor, prepares the birth canal.'
          : 'Pelvik tabanı açar, doğum kanalını hazırlar.',
      benefits: isEn
          ? ['Birth prep', 'Pelvic opening', 'Leg strength', 'Relaxation']
          : ['Doğuma hazırlık', 'Pelvik açılım', 'Bacak gücü', 'Rahatlama'],
      steps: isEn
          ? [
              'Rest your back against a wall, feet slightly wider than shoulders',
              'Slide down the wall, bend your knees, sit like a chair',
              'Back against the wall, knees over your toes',
              'Breathe deeply, relax your pelvic floor',
              'Stay 5–10 breaths, rise slowly',
            ]
          : [
              'Sırtını duvara daya, ayakları omuz genişliğinden biraz geniş aç',
              'Duvardan kayarak dizleri bük, sandalye gibi otur',
              'Sırtı duvara yaslı, dizler ayak parmakları hizasında',
              'Derin nefes al, pelvik tabanı gevşet',
              '5–10 nefes kal, yavaşça kalk',
            ],
      type: ExerciseType.destekliComelme,
    ),
    ExerciseData(
      name: isEn ? 'Figure-Four Stretch (Lying)' : 'Dörtlü Esneme (Yatarak)',
      description: isEn
          ? 'Stretches the hips and sciatic area, eases lower back pain.'
          : 'Kalça ve siyatik bölgesini esnetir, bel ağrısını azaltır.',
      benefits: isEn
          ? ['Hip flexibility', 'Sciatica', 'Lower back pain', 'Relaxation']
          : ['Kalça esnekliği', 'Siyatik', 'Bel ağrısı', 'Rahatlama'],
      steps: isEn
          ? [
              'Lie on your back, knees bent, feet on the floor',
              'Place your right ankle over your left knee (figure 4)',
              'Hold behind your left thigh, gently draw toward you',
              'Feel the stretch on the outside of your right hip',
              'Stay 5 breaths, switch sides',
            ]
          : [
              'Sırt üstü uzan, dizleri bük, ayaklar yerde',
              'Sağ ayak bileğini sol dizin üstüne koy (4 şekli)',
              'Sol uyluğun arkasından tut, nazikçe kendine doğru çek',
              'Sağ kalçanın dışında esneme hisset',
              '5 nefes kal, taraf değiştir',
            ],
      type: ExerciseType.dortluEsneme,
    ),
    ExerciseData(
      name: isEn ? 'Hip Circles on a Ball' : 'Top Üzerinde Kalça Çevirme',
      description: isEn
          ? 'Guides the baby into position, eases lower back pain.'
          : 'Bebeği doğru pozisyona yönlendirir, bel ağrısını azaltır.',
      benefits: isEn
          ? ['Lower back pain', 'Baby position', 'Pelvic relief', 'Circulation']
          : ['Bel ağrısı', 'Bebek pozisyonu', 'Pelvik rahatlama', 'Dolaşım'],
      steps: isEn
          ? [
              'Sit on a birth ball, feet planted on the floor',
              'Slowly draw circles with your hips',
              '10 circles clockwise',
              '10 circles counter-clockwise',
              'Then move in a figure-eight (8) shape',
            ]
          : [
              'Doğum topuna otur, ayaklar yerde sabit',
              'Kalçayla yavaş yavaş daire çiz',
              'Saat yönünde 10 daire',
              'Ters yönde 10 daire',
              'Sonra sekiz (8) şeklinde hareketlendir',
            ],
      type: ExerciseType.topUzerindeKalcaDaireleri,
    ),
    ExerciseData(
      name: isEn ? 'Wall-Supported Downward Dog' : 'Duvara Destekli Aşağıya Bakan Köpek',
      description: isEn
          ? 'Lengthens the back, opens the spine, no pressure on the abdomen.'
          : 'Sırtı uzatır, omurgayı açar, karın bölgesine baskı yapmaz.',
      benefits: isEn
          ? ['Back pain', 'Spine', 'Shoulder flexibility', 'Relaxation']
          : ['Sırt ağrısı', 'Omurga', 'Omuz esnekliği', 'Rahatlama'],
      steps: isEn
          ? [
              'Stand facing a wall, place your palms on it at shoulder height',
              'Walk back with small steps, hinge your torso forward',
              'Form an "L" shape with arms and back in one line',
              'Let your head hang freely between your arms',
              'Stay 5–8 breaths, walk back slowly',
            ]
          : [
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
  List<ExerciseData> _fertilityExercises(bool isEn) => [
    ExerciseData(
      name: isEn ? 'Reclining Goddess' : 'Yatarak Tanrıça',
      description: isEn
          ? 'Activates the pelvic floor muscles.'
          : 'Pelvik taban kaslarını aktive eder.',
      benefits: isEn
          ? ['Pelvic floor', 'Fertility', 'Hormone balance', 'Relaxation']
          : ['Pelvik taban', 'Doğurganlık', 'Hormon dengesi', 'Rahatlama'],
      steps: isEn
          ? [
              'Lie on your back',
              'Bend your knees and bring the soles of your feet together',
              'Inhale deeply and relax your pelvic floor',
              'Exhale and gently engage it',
              'Do 10 repetitions',
            ]
          : [
              'Sırt üstü uzan',
              'Dizleri büküp ayak tabanlarını birleştir',
              'Derin nefes alırken pelvik tabanı gevşet',
              'Nefes verirken hafifçe kas',
              '10 tekrar yap',
            ],
      type: ExerciseType.recliningGoddess,
    ),
    ExerciseData(
      name: isEn ? 'Butterfly Pose' : 'Kelebek Pozu',
      description: isEn
          ? 'Opens the pelvic area, boosts circulation.'
          : 'Pelvik bölgeyi açar, kan dolaşımını artırır.',
      benefits: isEn
          ? ['Pelvic opening', 'Circulation', 'Fertility', 'Tension']
          : ['Pelvik açılım', 'Kan dolaşımı', 'Doğurganlık', 'Gerilim'],
      steps: isEn
          ? [
              'Sit and bring the soles of your feet together',
              'Draw your heels toward your groin',
              'Keep your spine tall',
              'With each breath, let your groin open a little more',
              'Stay 2–3 minutes',
            ]
          : [
              'Otur, ayak tabanlarını birleştir',
              'Topukları kasığa çek',
              'Omurgayı dik tut',
              'Her nefeste kasıkların biraz daha açılmasına izin ver',
              '2–3 dakika kal',
            ],
      type: ExerciseType.butterfly,
    ),
    ExerciseData(
      name: isEn ? 'Downward-Facing Dog' : 'Aşağı Bakan Köpek',
      description: isEn
          ? 'Supports hormonal balance, reduces stress.'
          : 'Hormonal dengeyi destekler, stresi azaltır.',
      benefits: isEn
          ? ['Hormone balance', 'Stress', 'Circulation', 'Energy']
          : ['Hormon dengesi', 'Stres', 'Kan dolaşımı', 'Enerji'],
      steps: isEn
          ? [
              'Come to all fours',
              'Push your hips up into an inverted V',
              'Breathe deeply, let your head hang free',
              'Try to press your heels to the floor',
              'Hold for 5–8 breaths',
            ]
          : [
              'Dörtnala pozisyona geç',
              'Kalçayı yukarı iterek ters V oluştur',
              'Derin nefes al, kafayı serbest bırak',
              'Topukları yere basmaya çalış',
              '5–8 nefes tut',
            ],
      type: ExerciseType.downDog,
    ),
    ExerciseData(
      name: isEn ? 'Legs Up the Wall' : 'Bacaklar Duvarda',
      description: isEn
          ? 'Increases blood flow to the pelvic area.'
          : 'Pelvik bölgeye kan akışını artırır.',
      benefits: isEn
          ? ['Pelvic blood flow', 'Fertility', 'Fatigue', 'Relaxation']
          : ['Pelvik kan akışı', 'Doğurganlık', 'Yorgunluk', 'Rahatlama'],
      steps: isEn
          ? [
              'Lie on your side close to a wall',
              'Rest your legs up against the wall',
              'Open your arms to the sides, close your eyes',
              'Breathe deeply, feel warmth in the pelvis',
              'Stay for 10 minutes',
            ]
          : [
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
