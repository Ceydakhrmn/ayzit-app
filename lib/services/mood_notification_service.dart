import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MoodNotificationService {
  MoodNotificationService._();
  static final MoodNotificationService instance = MoodNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Her mood için birden fazla mesaj — her seferinde rastgele seçilir
  static const Map<String, List<String>> _messages = {
    'happy': [
      'Harika görünüyorsun! Bu enerjiyi çevrene yaymaya ne dersin? ✨',
      'Gülümsemen günü aydınlatıyor! 🌸',
      'Mutlu anlar geçici değil, sen onları yaratıyorsun. Devam et! 🌟',
      'Bu neşeyi içinde taşı, günün geri kalanında işine yarayacak! 💛',
      'Bugün dünya biraz daha güzel, çünkü sen mutlusun! 🌼',
    ],
    'calm': [
      'Dinginliğin tadını çıkar. Bugün senin huzur günün. 🍃',
      'Zihnini dinlendirmek için harika bir an.',
      'İçindeki bu sessizliği koru, nadiren bulunur. 🕊️',
      'Sakin sular derin akar — bugün derin düşün! 💙',
      'Bu huzuru hak ettin, tadını çıkar. 🌙',
    ],
    'tired': [
      'Dinlenmek de verimliliğe dahildir. Kendine biraz vakit ayır. ✨',
      'Vücudunu dinle, o neye ihtiyacı olduğunu bilir.',
      'Biraz yavaşla, yarın için enerji biriktir. 🌙',
      'En üretken şey bazen sadece dinlenmek. Bugün öyle bir gün! 🛋️',
      'Yorgunken verilen molalar en değerli olanlardır. 💜',
    ],
    'sad': [
      'Her duygu geçicidir, kendine karşı nazik ol. Yanındayım. ❤️',
      'Bugün biraz yavaşlamak istersen bu çok normal.',
      'Bu gün de geçecek, söz. 🤍',
      'Kendine nazik ol bugün, en çok bunu hak ediyorsun. 🫂',
      'Bazen gökyüzünün ağlaması gerekir ki toprak yeşersin. 🌱',
    ],
    'anxious': [
      'Derin bir nefes al. Her şey adım adım çözülecek. 🌬️',
      'Kontrol edebileceklerine odaklan, gerisini akışa bırak.',
      'Şu an güvendesin, bir adım yeterli. 🌈',
      'Zihnin seni test ediyor ama sen her seferinde geçiyorsun. ✨',
      'Endişelerin seni küçültemez — sen onlardan büyüksün! 💪',
    ],
    'angry': [
      'Biraz temiz hava veya kısa bir yürüyüş iyi gelebilir mi? 🌿',
      'Hislerini anlıyorum, derin nefes alıp sakinleşmeyi dene.',
      'Bu enerjiyi bir yere akıt — egzersiz, müzik, yürüyüş… 🎵',
      'Bugün sınırlarını korumanın tam zamanı. 🛡️',
      'Duyguların ne kadar yoğun olursa, o kadar derin hissediyorsun. 💜',
    ],
    'energetic': [
      'Bu enerjiyle bugün her şeyi yapabilirsin! 🚀',
      'Sınırları zorlamaya hazır mısın? Harika bir gün seni bekliyor!',
      'Bugün en beklediğin işleri halletmenin tam zamanı! ⚡',
      'Enerjin zirvedeyken büyük adım at! 🏃‍♀️',
      'Bugün "sonra yaparım" deme — tam zamanı! ✅',
    ],
    'sensitive': [
      'Bugün kendine ekstra özen gösterme günü. Belki sıcak bir çay? ☕',
      'Duyguların çok değerli, onları kucakla.',
      'Hassasiyetin bir süper güç — derinlemesine hissediyorsun! 🌸',
      'Hassas kalpler en güçlü kalpler olur zamanla. 🫶',
      'Bugün sınırlarına saygı göster, kimse senden fazlasını bekleyemez. 🌷',
    ],
  };

  // Son gösterilen mesaj indexlerini takip et (aynı mesajın üst üste gelmesini önler)
  final Map<String, int> _lastShownIndex = {};

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  bool _appNotificationsEnabled = true;

  void setAppNotificationsEnabled(bool enabled) {
    _appNotificationsEnabled = enabled;
  }

  Future<void> showMoodNotification(
      String moodKey, String moodLabel, String moodEmoji) async {
    if (!_appNotificationsEnabled) return;
    await init();

    final messages = _messages[moodKey] ?? ['Bugün nasıl hissettiğini takip ediyorum. 💜'];
    final lastIndex = _lastShownIndex[moodKey];

    // Bir öncekinden farklı rastgele index seç
    int index;
    if (messages.length == 1) {
      index = 0;
    } else {
      do {
        index = Random().nextInt(messages.length);
      } while (index == lastIndex);
    }
    _lastShownIndex[moodKey] = index;

    final message = messages[index];

    final androidDetails = AndroidNotificationDetails(
      'mood_channel',
      'Ruh Hali Bildirimleri',
      channelDescription: 'Ruh haline göre kişisel mesajlar',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
      styleInformation: BigTextStyleInformation(message),
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      presentBadge: false,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      0,
      '$moodEmoji $moodLabel hissediyorsun',
      message,
      details,
    );
  }
}
