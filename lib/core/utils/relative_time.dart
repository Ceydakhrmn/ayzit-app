// =============================================
// core/utils/relative_time.dart
// Lightweight relative time formatter with TR/EN/DE/FR/ES support.
// Avoids external deps (no timeago package).
// =============================================

class RelativeTime {
  RelativeTime._();

  static String format(DateTime time, {String locale = 'tr'}) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return _now(locale);
    if (diff.inMinutes < 60) return _minutes(diff.inMinutes, locale);
    if (diff.inHours < 24) return _hours(diff.inHours, locale);
    if (diff.inDays < 7) return _days(diff.inDays, locale);
    if (diff.inDays < 30) return _weeks((diff.inDays / 7).floor(), locale);
    if (diff.inDays < 365) return _months((diff.inDays / 30).floor(), locale);
    return _years((diff.inDays / 365).floor(), locale);
  }

  static String _now(String l) {
    switch (l) {
      case 'en': return 'just now';
      case 'fr': return "à l'instant";
      case 'de': return 'gerade eben';
      case 'es': return 'ahora mismo';
      default:   return 'az önce';
    }
  }

  static String _minutes(int n, String l) {
    switch (l) {
      case 'en': return '$n min ago';
      case 'fr': return 'il y a $n min';
      case 'de': return 'vor $n Min.';
      case 'es': return 'hace $n min';
      default:   return '$n dk önce';
    }
  }

  static String _hours(int n, String l) {
    switch (l) {
      case 'en': return '${n}h ago';
      case 'fr': return 'il y a ${n}h';
      case 'de': return 'vor $n Std.';
      case 'es': return 'hace ${n}h';
      default:   return '$n sa önce';
    }
  }

  static String _days(int n, String l) {
    switch (l) {
      case 'en': return '${n}d ago';
      case 'fr': return 'il y a ${n}j';
      case 'de': return 'vor $n T.';
      case 'es': return 'hace ${n}d';
      default:   return '$n gün önce';
    }
  }

  static String _weeks(int n, String l) {
    switch (l) {
      case 'en': return '${n}w ago';
      case 'fr': return 'il y a ${n}sem';
      case 'de': return 'vor $n Wo.';
      case 'es': return 'hace ${n}sem';
      default:   return '$n hf önce';
    }
  }

  static String _months(int n, String l) {
    switch (l) {
      case 'en': return '${n}mo ago';
      case 'fr': return 'il y a ${n}mois';
      case 'de': return 'vor $n Mon.';
      case 'es': return 'hace ${n}mes';
      default:   return '$n ay önce';
    }
  }

  static String _years(int n, String l) {
    switch (l) {
      case 'en': return '${n}y ago';
      case 'fr': return 'il y a ${n}an';
      case 'de': return 'vor $n J.';
      case 'es': return 'hace ${n}a';
      default:   return '$n yıl önce';
    }
  }
}
