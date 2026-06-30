// =============================================
// core/theme/app_colors.dart
// Brand color tokens — light + dark shared
// =============================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFC084FC);
  static const Color primaryDark = Color(0xFF5B21B6);

  // ── Backgrounds ──
  static const Color bgLight = Color(0xFFEDE8F8);
  static const Color bgDark = Color(0xFF1A1035);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1B26);
  static const Color cardDark = Color(0xFF24202E);

  // ── Background Gradients ──
  static const List<Color> bgGradientLight = [
    Color(0xFFEDE8F8),
    Color(0xFFE0EAFA),
    Color(0xFFEAE4F7),
  ];
  static const List<Color> bgGradientDark = [
    Color(0xFF1A1035),
    Color(0xFF1E1540),
    Color(0xFF12203A),
  ];

  // ── Text ──
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // ── Semantic ──
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF97316);
  static const Color likeRed = Color(0xFFEF4444);

  // ── Dividers / borders ──
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF2D2A37);
}
