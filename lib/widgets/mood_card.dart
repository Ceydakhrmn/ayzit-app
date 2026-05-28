import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';

class MoodOption {
  final String key;
  final String emoji;
  final String label;
  final List<String> suggestions;

  const MoodOption({
    required this.key,
    required this.emoji,
    required this.label,
    required this.suggestions,
  });
}

const List<MoodOption> kMoods = [
  MoodOption(
    key: 'happy',
    emoji: '😊',
    label: 'Mutlu',
    suggestions: [
      'Bu enerjiyi sevdiklerinle paylaş 💛',
      'Güzel bir şey planlamak için harika bir gün! 🌸',
      'Minnettar olduğun 3 şeyi not al 📝',
      'Kendin için küçük bir ödül al, bunu hak ediyorsun 🎁',
      'Sevdiğin birine sürpriz bir mesaj at 💌',
      'Bu mutluluğu günlüğüne yaz, yarın okumak güzel olur 🌟',
      'Yeni bir şey denemek için mükemmel bir an ✨',
      'Kendine özel küçük bir ritüel oluştur, her mutlu günde tekrarla 🌼',
    ],
  ),
  MoodOption(
    key: 'calm',
    emoji: '😌',
    label: 'Sakin',
    suggestions: [
      'Kısa bir meditasyon dene, 5 dakika yeter 🧘',
      'Sevdiğin bir kitabı aç, sayfaları çevir 📖',
      'Doğada kısa bir yürüyüş seni daha da dinginleştirir 🌿',
      'Hafif bir müzik eşliğinde sadece otur ve nefes al 🎵',
      'Bu huzuru bir günlük yazısına dökmek ister misin? 🖊️',
      'Bitkilerin veya çiçeklerin arasında vakit geç 🌱',
      'Sıcak bir içecekle pencere kenarına geç, manzaraya bak ☕',
      'Yavaş bir yoga seansı için ideal bir an 🕊️',
    ],
  ),
  MoodOption(
    key: 'tired',
    emoji: '😴',
    label: 'Yorgun',
    suggestions: [
      '20 dakikalık kısa bir uyku mucizeler yaratır 💤',
      'Sıcak bir çay veya kahve iç, nefes al ☕',
      'Bu gece erken yatmayı planla, vücudun şükredecek 🌙',
      'Bugün yapılacaklar listeni en aza indir, sadece önemlileri tut 📋',
      'Ayaklarını uzat, gözlerini kapat — 10 dakika bile yetişir 🛋️',
      'Hafif bir müzik aç, sadece dinle ve dinlen 🎶',
      'Vücuduna iyi gelecek besleyici bir şeyler ye 🥗',
      'Ekranlardan uzaklaş, gözlerini dinlendir 👁️',
    ],
  ),
  MoodOption(
    key: 'sad',
    emoji: '😢',
    label: 'Üzgün',
    suggestions: [
      'Sevdiğin biriyle konuşmak iyi gelebilir 🫂',
      'Kendine nazik ol, bugün sadece var olmak yeterli 🤍',
      'Güzel bir müzik listesi aç, duyguları akmasına izin ver 🎵',
      'Dışarı çık, taze hava ve hareket ruh halini değiştirir 🌤️',
      'Kendine sıcak bir içecek hazırla, bir battaniyeye sarın 🍵',
      'Ağlamak istersen ağla — duygularını serbest bırakmak iyileştirir 💧',
      'Seni güldüren eski fotoğraflara bak 📸',
      'Bu da geçecek — her karanlığın sabahı var ☀️',
    ],
  ),
  MoodOption(
    key: 'anxious',
    emoji: '😰',
    label: 'Endişeli',
    suggestions: [
      '4-7-8 nefes tekniği dene: 4 al, 7 tut, 8\'de bırak 🌬️',
      'Seni endişelendireni kağıda dök, zihnini boşalt 📝',
      'Kontrol edebildiğin tek şeye odaklan: şu anki adım 🦶',
      '5-4-3-2-1 tekniği: 5 şey gör, 4 dokun, 3 duy, 2 kokla, 1 tat 👁️',
      'Kısa bir yürüyüş kaygıyı eritir, hava almak için dışarı çık 🌳',
      'Endişelerini büyük ve küçük diye ikiye ayır, küçüklerden başla 📊',
      'Sıcak bir duş veya banyo sinir sistemini sakinleştirir 🚿',
      'Şu an gerçekten tehlikede değilsin — zihnine bunu hatırlat 💙',
    ],
  ),
  MoodOption(
    key: 'angry',
    emoji: '😤',
    label: 'Sinirli',
    suggestions: [
      'Hızlı bir yürüyüş veya egzersiz bu enerjiyi dönüştürür 🏃',
      'Soğuk su iç, yüzünü yıka, derin nefes al 💧',
      'Müzik aç, dans et — ciddi durmak zorunda değilsin 🎶',
      'Duygularını kağıda yaz, kimseye göstermek zorunda değilsin 📝',
      'Birkaç dakika yalnız kal, tepki vermeden önce nefes al 🌬️',
      'Fiziksel bir aktivite dene: koş, atla, yastığa vur 🥊',
      'Bu his geçici — kendine biraz süre tanı ⏳',
      'Ne hissettiğini anlamaya çalış, öfkenin altında ne var? 🔍',
    ],
  ),
  MoodOption(
    key: 'energetic',
    emoji: '⚡',
    label: 'Enerjik',
    suggestions: [
      'Ertelediğin o görevi bugün bitir, tam zamanı! ✅',
      'Yeni bir şey öğrenmek için harika bir gün 🚀',
      'Bu enerjiyi egzersizle taçlandır 💪',
      'Uzun süredir yapmak istediğin o planı hayata geçir 🗺️',
      'Odanı veya çalışma alanını yeniden düzenle 🏠',
      'Yeni bir tarif dene, mutfakta yaratıcı ol 👨‍🍳',
      'Birini arayıp buluşma planı yap 📞',
      'Hedeflerine bir adım daha yaklaş, liste yap 🎯',
    ],
  ),
  MoodOption(
    key: 'sensitive',
    emoji: '🥺',
    label: 'Hassas',
    suggestions: [
      'Kendine ekstra nazik ol, sınırlarını koru 🌷',
      'Sıcak bir duş veya banyo zihnini rahatlatır 🛁',
      'Sevdiğin bir film veya dizi izle, kendine şefkat göster 🌸',
      'Bugün "hayır" demek tamamen geçerli bir seçenek 🛡️',
      'Sevdiğin birinin sesini duymak iyi gelebilir 🫶',
      'Kendine karşı en iyi arkadaşın gibi davran 💜',
      'Doğayla vakit geç, toprak ve yeşil sakinleştirir 🌿',
      'Hassasiyetin bir zayıflık değil, derinliğin göstergesi 🌊',
    ],
  ),
];

MoodOption? moodByKey(String key) {
  try {
    return kMoods.firstWhere((m) => m.key == key);
  } catch (_) {
    return null;
  }
}

String _localizedMoodLabel(String key, {bool isEn = false}) {
  if (!isEn) return kMoods.firstWhere((m) => m.key == key, orElse: () => kMoods.first).label;
  switch (key) {
    case 'happy':     return 'Happy';
    case 'calm':      return 'Calm';
    case 'tired':     return 'Tired';
    case 'sad':       return 'Sad';
    case 'anxious':   return 'Anxious';
    case 'angry':     return 'Angry';
    case 'energetic': return 'Energetic';
    case 'sensitive': return 'Sensitive';
    default:          return key;
  }
}

class MoodCard extends StatefulWidget {
  const MoodCard({super.key});

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  String? _hoveredKey;
  String? _suggestion;
  int? _lastSuggestionIndex;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CycleProvider>();
    final selectedDay = provider.selectedDay;
    final targetDay = selectedDay ?? DateTime.now();
    final currentMood = provider.moodForDay(targetDay);
    final isEn = !AppLocalizations.of(context)!.isTurkish;

    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              const Icon(Icons.mood, size: 16, color: Color(0xFF7C3AED)),
              const SizedBox(width: 6),
              Text(
                isEn ? 'Mood' : 'Ruh Hali',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                selectedDay == null ? (isEn ? 'Today' : 'Bugün') : '${targetDay.day}/${targetDay.month}',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Emoji seçici
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kMoods.map((mood) {
              final isSelected = mood.key == currentMood;
              final isHovered = mood.key == _hoveredKey;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveredKey = mood.key),
                onExit: (_) => setState(() => _hoveredKey = null),
                child: GestureDetector(
                  onTap: () {
                    final newMood = isSelected ? '' : mood.key;
                    provider.saveMood(targetDay, newMood);
                    if (newMood.isNotEmpty) {
                      final suggestions = mood.suggestions;
                      int index;
                      if (suggestions.length == 1) {
                        index = 0;
                      } else {
                        do {
                          index = Random().nextInt(suggestions.length);
                        } while (index == _lastSuggestionIndex);
                      }
                      setState(() {
                        _suggestion = suggestions[index];
                        _lastSuggestionIndex = index;
                      });
                    } else {
                      setState(() {
                        _suggestion = null;
                        _lastSuggestionIndex = null;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6D28D9)
                          : isHovered
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected || isHovered
                            ? const Color(0xFF6D28D9)
                            : const Color(0xFFDDD6FE),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mood.emoji,
                          style: TextStyle(fontSize: isHovered ? 18 : 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _localizedMoodLabel(mood.key, isEn: isEn),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected || isHovered
                                ? Colors.white
                                : const Color(0xFF6D28D9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Öneri
          if (_suggestion != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _suggestion!,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
