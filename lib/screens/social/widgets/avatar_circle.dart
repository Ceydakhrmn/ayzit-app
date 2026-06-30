// =============================================
// screens/social/widgets/avatar_circle.dart
// Reusable circular avatar: first letter of a seed string on a
// deterministic background color.
// =============================================

import 'package:flutter/material.dart';

import '../../../core/utils/avatar_utils.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.seed,
    required this.label,
    this.size = 40,
    this.anonymous = false,
  });

  /// Seed used to derive the color deterministically.
  final String seed;

  /// Text used to derive the initial (usually the display name).
  final String label;

  final double size;
  final bool anonymous;

  @override
  Widget build(BuildContext context) {
    if (anonymous) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade500,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.visibility_off_outlined,
          color: Colors.white,
          size: size * 0.5,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AvatarUtils.colorFromSeed(seed),
        shape: BoxShape.circle,
      ),
      child: Text(
        AvatarUtils.initial(label),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
