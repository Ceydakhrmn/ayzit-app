// =============================================
// widgets/pregnancy/baby_stage_image.dart
//
// Hafta numarasına göre PNG tabanlı bebek gelişim görseli.
// assets/images/baby_stages/ klasöründeki PNG'leri yükler,
// üstüne yumuşak yüzme + nefes animasyonu uygular.
//
// PNG bulunamazsa otomatik olarak EmbryoIcon (CustomPainter)
// fallback'ine geçer.
//
// Mevcut dosya haritası:
//   week_1.png           (hft 1)
//   week_2.png           (hft 2)
//   week_3.png           (hft 3)
//   week_4.png           (hft 4)
//   week_5.png           (hft 5)
//   week_6:7.png         (hft 6-7)
//   week_8:9.png         (hft 8-9)
//   week_10.png          (hft 10)
//   week_11:16.png       (hft 11-16)
//   week_17:28.png       (hft 17-28)
//   week_29:36.png       (hft 29-36)
//   week_37:40.png       (hft 37-40)
// =============================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/pregnancy_data.dart';
import 'embryo_painter.dart';

String _pathForWeek(int week) {
  if (week == 1)  return 'assets/images/baby_stages/week_1.png';
  if (week == 2)  return 'assets/images/baby_stages/week_2.png';
  if (week == 3)  return 'assets/images/baby_stages/week_3.png';
  if (week == 4)  return 'assets/images/baby_stages/week_4.png';
  if (week == 5)  return 'assets/images/baby_stages/week_5.png';
  if (week <= 7)  return 'assets/images/baby_stages/week_6:7.png';
  if (week <= 9)  return 'assets/images/baby_stages/week_8:9.png';
  if (week == 10) return 'assets/images/baby_stages/week_10.png';
  if (week <= 16) return 'assets/images/baby_stages/week_11:16.png';
  if (week <= 28) return 'assets/images/baby_stages/week_17:28.png';
  if (week <= 36) return 'assets/images/baby_stages/week_29:36.png';
  return              'assets/images/baby_stages/week_37:40.png';
}

// Animasyonsuz statik bebek gelişim görseli.
class BabyStageImage extends StatelessWidget {
  final int week;
  final double size;

  const BabyStageImage({
    super.key,
    required this.week,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final w = week.clamp(1, 40);
    final stage = embryoStageForWeek(w);
    final path = _pathForWeek(w);
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, st) => EmbryoIcon(stage: stage, size: size),
      ),
    );
  }
}

class AnimatedBabyStage extends StatefulWidget {
  final int week;
  final double size;

  const AnimatedBabyStage({
    super.key,
    required this.week,
    this.size = 140,
  });

  @override
  State<AnimatedBabyStage> createState() => _AnimatedBabyStageState();
}

class _AnimatedBabyStageState extends State<AnimatedBabyStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final week = widget.week.clamp(1, 40);
    final stage = embryoStageForWeek(week);
    final path = _pathForWeek(week);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final bob = sin(_ctrl.value * 2 * pi);
        return Transform.translate(
          offset: Offset(0, bob * 3.0),
          child: Transform.scale(
            scale: 1.0 + bob * 0.022,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, st) => EmbryoIcon(
            stage: stage,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}
