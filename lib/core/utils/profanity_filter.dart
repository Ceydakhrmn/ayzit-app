// =============================================
// core/utils/profanity_filter.dart
// Client-side profanity check. The actual word list lives in Firestore
// (config/profanityList) and is loaded via ProfanityService. This utility
// operates on any list provided to it.
// =============================================

import 'package:characters/characters.dart';

class ProfanityFilter {
  ProfanityFilter._();

  /// Lowercase + strip common TR/EN diacritics so substring matching is
  /// resilient to simple obfuscations like "SiKtir" → "siktir".
  static String _normalize(String input) {
    const map = {
      'â': 'a', 'ä': 'a', 'á': 'a', 'à': 'a',
      'é': 'e', 'ê': 'e', 'ë': 'e', 'è': 'e',
      'í': 'i', 'ï': 'i', 'î': 'i', 'ì': 'i', 'ı': 'i',
      'ó': 'o', 'ö': 'o', 'ô': 'o', 'ò': 'o',
      'ú': 'u', 'ü': 'u', 'û': 'u', 'ù': 'u',
      'ç': 'c', 'ş': 's', 'ğ': 'g',
      'ñ': 'n',
    };
    final lower = input.toLowerCase();
    final buf = StringBuffer();
    for (final ch in lower.characters) {
      buf.write(map[ch] ?? ch);
    }
    return buf.toString();
  }

  /// Returns the first matched bad word, or null if clean.
  static String? firstMatch(String input, List<String> badWords) {
    if (input.isEmpty || badWords.isEmpty) return null;
    final n = _normalize(input);
    for (final word in badWords) {
      final w = _normalize(word).trim();
      if (w.isEmpty) continue;
      if (n.contains(w)) return word;
    }
    return null;
  }

  /// True if any bad word is present in [input].
  static bool contains(String input, List<String> badWords) {
    return firstMatch(input, badWords) != null;
  }
}
