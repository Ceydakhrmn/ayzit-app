// =============================================
// screens/pregnancy/sunflower_painter.dart
//
// Programmatic 2D-vector ay çiçeği painter that grows over the 40-week
// pregnancy.  Drawn entirely in Flutter — no Lottie, no PNG assets.
//
//   • Pot position and stem origin are FIXED constants → millimetric
//     consistency across all weeks.
//   • `weekProgress` is a fractional double (1.0..40.0) so the parent can
//     smoothly tween between weeks (e.g. 5.7 means partway from week 5→6).
//
// Stage roadmap:
//   PHASE 1  (weeks 1-12)   ✓ implemented — seed → sprout → 2 leaves
//   PHASE 2  (weeks 13-27)  ☐ TODO — thicker stem, heart leaves, bud
//   PHASE 3  (weeks 28-34)  ☐ TODO — sepals open, petals form sun
//   PHASE 4  (weeks 35-40)  ☐ TODO — Fibonacci disk, head bows, seed drops
//
// Until later phases land, weeks 13+ display the week-12 state.
// =============================================

import 'dart:math';

import 'package:flutter/material.dart';

class SunflowerPainter extends CustomPainter {
  /// Continuous week — 1.0 .. 40.0.  Use a fractional value while tweening
  /// between two integer weeks so the growth looks smooth.
  final double weekProgress;

  /// 0..1 — how far the "fall" of the ripe seed at week 40 has progressed.
  /// Phase 4 will animate this; in phases 1-3 it stays at 0.
  final double seedDrop;

  SunflowerPainter({required this.weekProgress, this.seedDrop = 0});

  // ───────────────────────── colour palette ─────────────────────────
  static const _potBody       = Color(0xFF8D6E63);
  static const _potRim        = Color(0xFFA1887F);
  static const _potShadow     = Color(0xFF6D4C41);
  static const _soil          = Color(0xFF5D4037);
  static const _soilDark      = Color(0xFF3E2723);
  static const _stemGreen     = Color(0xFF558B2F);
  static const _stemDark      = Color(0xFF33691E);
  static const _leafGreen     = Color(0xFF7CB342);
  static const _leafVein      = Color(0xFF558B2F);
  static const _seedShell     = Color(0xFF6D4C41);
  static const _seedHighlight = Color(0xFFA98274);

  // ───────────────────────── virtual canvas ─────────────────────────
  // The painter draws into a fixed virtual coordinate space and then
  // contains-fits to the actual size, anchored to the bottom.  This keeps
  // every week's pot/stem origin pixel-perfectly identical.
  static const double _vw          = 360;
  static const double _vh          = 720;
  static const double _centerX     = 180;
  static const double _potTopY     = 590; // top inner edge of pot
  static const double _potBottomY  = 678;
  static const double _potTopHalfW = 64;  // half-width at top
  static const double _potBotHalfW = 50;  // half-width at bottom
  static const double _stemBaseY   = _potTopY - 2; // stem sprouts here

  @override
  void paint(Canvas canvas, Size size) {
    // Map virtual canvas → real size, contained, bottom-anchored.
    final s = min(size.width / _vw, size.height / _vh);
    final dx = (size.width - _vw * s) / 2;
    final dy = size.height - _vh * s;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s);

    final w = weekProgress.clamp(1.0, 40.0);

    // Always-on layers (consistency rule)
    _drawPot(canvas);
    _drawSoil(canvas);

    // ───── PHASE 1: weeks 1-12 ─────
    if (w < 5) {
      _drawSubterraneanSeed(canvas, w);
    } else {
      // Cap stage-1 visuals at week 12 until later phases are added.
      _drawSproutStage(canvas, w.clamp(5.0, 12.0));
    }

    // PHASE 2-4 will be drawn here in later commits.

    canvas.restore();
  }

  // ───────────────────────── pot ─────────────────────────
  void _drawPot(Canvas canvas) {
    // Trapezoidal body
    final body = Path()
      ..moveTo(_centerX - _potTopHalfW, _potTopY)
      ..lineTo(_centerX + _potTopHalfW, _potTopY)
      ..lineTo(_centerX + _potBotHalfW, _potBottomY)
      ..lineTo(_centerX - _potBotHalfW, _potBottomY)
      ..close();
    canvas.drawPath(body, Paint()..color = _potBody);

    // Right-side soft shadow for subtle 3D feel
    final shadow = Path()
      ..moveTo(_centerX + _potTopHalfW - 14, _potTopY)
      ..lineTo(_centerX + _potTopHalfW, _potTopY)
      ..lineTo(_centerX + _potBotHalfW, _potBottomY)
      ..lineTo(_centerX + _potBotHalfW - 12, _potBottomY)
      ..close();
    canvas.drawPath(
      shadow,
      Paint()..color = _potShadow.withValues(alpha: 0.45),
    );

    // Rim highlight (a flat band on top of the pot opening)
    final rim = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _centerX - _potTopHalfW - 4,
        _potTopY - 8,
        (_potTopHalfW + 4) * 2,
        12,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rim, Paint()..color = _potRim);
    // Rim inner shadow
    canvas.drawLine(
      Offset(_centerX - _potTopHalfW - 2, _potTopY + 1),
      Offset(_centerX + _potTopHalfW + 2, _potTopY + 1),
      Paint()
        ..color = _potShadow.withValues(alpha: 0.4)
        ..strokeWidth = 1.2,
    );
  }

  // ───────────────────────── soil ─────────────────────────
  void _drawSoil(Canvas canvas) {
    // Soil dome inside the pot rim
    final p = Path()
      ..moveTo(_centerX - _potTopHalfW + 2, _potTopY)
      ..quadraticBezierTo(
        _centerX, _potTopY - 4,
        _centerX + _potTopHalfW - 2, _potTopY,
      )
      ..lineTo(_centerX + _potTopHalfW - 2, _potTopY + 6)
      ..lineTo(_centerX - _potTopHalfW + 2, _potTopY + 6)
      ..close();
    canvas.drawPath(p, Paint()..color = _soil);

    // A few flecks for texture (deterministic — same every frame)
    final fleck = Paint()..color = _soilDark;
    canvas.drawCircle(Offset(_centerX - 28, _potTopY - 1), 1.4, fleck);
    canvas.drawCircle(Offset(_centerX - 8,  _potTopY - 2), 1.0, fleck);
    canvas.drawCircle(Offset(_centerX + 14, _potTopY - 1), 1.2, fleck);
    canvas.drawCircle(Offset(_centerX + 36, _potTopY),     1.0, fleck);
  }

  // ───────────────────────── PHASE 1 ─────────────────────────
  /// Weeks 1-5: seed embedded in soil, glow intensifies as it nears germination.
  void _drawSubterraneanSeed(Canvas canvas, double week) {
    final t = ((week - 1) / 4).clamp(0.0, 1.0);
    final cx = _centerX;
    final cy = _potTopY + 14; // just below soil dome

    // Glow halo behind the seed (radial gradient)
    final glowR = 18 + 18 * t;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 213, 79, 0.55 * (0.4 + 0.6 * t)),
          const Color.fromRGBO(255, 213, 79, 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: glowR));
    canvas.drawCircle(Offset(cx, cy), glowR, glow);

    // Seed (almond shape, slight tilt)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-pi / 14);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 12, height: 18),
      Paint()..color = _seedShell,
    );
    // Highlight crescent
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-1.5, -3), width: 3.5, height: 7),
      Paint()..color = _seedHighlight,
    );
    canvas.restore();

    // Tiny radiating dashes near germination (week 4+)
    if (t > 0.6) {
      final r = (t - 0.6) / 0.4;
      final dash = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.55 * r)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final a = i * pi / 3 + pi / 12;
        final r0 = glowR * 0.7;
        final r1 = glowR * 0.92;
        canvas.drawLine(
          Offset(cx + cos(a) * r0, cy + sin(a) * r0),
          Offset(cx + cos(a) * r1, cy + sin(a) * r1),
          dash,
        );
      }
    }
  }

  /// Weeks 5-12: sprout breaks soil, stem grows, two oval leaves emerge.
  void _drawSproutStage(Canvas canvas, double week) {
    final stageT = ((week - 5) / 7).clamp(0.0, 1.0); // 0 at w=5, 1 at w=12

    // Soil crack mark (week 5+)
    final crackPaint = Paint()
      ..color = _soilDark
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(_centerX - 5, _potTopY - 2),
      Offset(_centerX + 4, _potTopY - 1),
      crackPaint,
    );

    // Stem grows from 0 → 95 px over weeks 5..12
    final stemHeight = _lerp(6, 95, stageT);
    final tipX = _centerX + sin(stageT * pi * 0.6) * 1.2; // very subtle lean
    final tipY = _stemBaseY - stemHeight;

    final stemPath = Path()
      ..moveTo(_centerX, _stemBaseY)
      ..quadraticBezierTo(
        _centerX + 0.5, _stemBaseY - stemHeight * 0.55,
        tipX, tipY,
      );

    // Slight stem outline (darker) for depth
    canvas.drawPath(
      stemPath,
      Paint()
        ..color = _stemDark
        ..strokeWidth = 3.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      stemPath,
      Paint()
        ..color = _stemGreen
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Tiny tip cap at the apex (rounded leaf-tip look while stem is growing)
    canvas.drawCircle(
      Offset(tipX, tipY),
      1.6,
      Paint()..color = _stemGreen,
    );

    // Two oval leaves emerge from week 8, fully formed by week 12
    if (week >= 8) {
      final leafT = ((week - 8) / 4).clamp(0.0, 1.0);
      final leafLen = _lerp(5, 22, leafT);
      // Leaves attach at ~55% up the stem
      final attachY = _stemBaseY - stemHeight * 0.55;
      final attachX = _centerX + 0.3;

      _drawOvalLeaf(canvas, Offset(attachX, attachY),
          length: leafLen, angleDeg: -32, mirror: false);
      _drawOvalLeaf(canvas, Offset(attachX, attachY - 4),
          length: leafLen * 0.95, angleDeg: 30, mirror: true);
    }
  }

  void _drawOvalLeaf(Canvas canvas, Offset origin,
      {required double length,
      required double angleDeg,
      required bool mirror}) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angleDeg * pi / 180);
    if (mirror) canvas.scale(-1, 1);

    final l = length;
    final w = l * 0.55;

    // Leaf blade — pointed oval (almond)
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w * 0.7, -l * 0.25, w * 0.9, -l * 0.55)
      ..quadraticBezierTo(w * 0.55, -l * 0.85, 0, -l)
      ..quadraticBezierTo(-w * 0.05, -l * 0.6, 0, 0)
      ..close();

    // Outline
    canvas.drawPath(
      leaf,
      Paint()
        ..color = _leafVein
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
    // Fill
    canvas.drawPath(leaf, Paint()..color = _leafGreen);

    // Centre vein
    final vein = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w * 0.25, -l * 0.5, w * 0.45, -l * 0.85);
    canvas.drawPath(
      vein,
      Paint()
        ..color = _leafVein
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  // ───────────────────────── helpers ─────────────────────────
  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant SunflowerPainter old) =>
      old.weekProgress != weekProgress || old.seedDrop != seedDrop;
}
