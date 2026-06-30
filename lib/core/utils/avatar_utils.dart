// =============================================
// core/utils/avatar_utils.dart
// Deterministic avatar color + initial from a seed (uid or username)
// =============================================

import 'package:flutter/material.dart';

class AvatarUtils {
  AvatarUtils._();

  // Stable pastel-ish palette for avatars
  static const List<Color> _palette = [
    Color(0xFF7C3AED), // primary purple
    Color(0xFFEC4899), // pink
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFEAB308), // yellow
    Color(0xFF22C55E), // green
    Color(0xFF14B8A6), // teal
    Color(0xFF3B82F6), // blue
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFA855F7), // fuchsia
    Color(0xFFD946EF), // magenta
  ];

  /// Returns a deterministic color based on a seed string.
  static Color colorFromSeed(String seed) {
    if (seed.isEmpty) return _palette.first;
    final hash = seed.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
    return _palette[hash % _palette.length];
  }

  /// Returns the uppercase first letter of a display name / username.
  /// Empty string falls back to "?".
  static String initial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim().characters.first.toUpperCase();
  }
}
