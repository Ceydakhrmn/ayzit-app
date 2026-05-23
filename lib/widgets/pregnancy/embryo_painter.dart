// =============================================
// widgets/pregnancy/embryo_painter.dart
// Bebeğin gebelik aşamasına göre değişen siluet çizimi.
// 6 aşama: hücre topu → kuyruklu embriyo → erken fetüs →
//          fetüs → dolgun fetüs → doğuma hazır bebek.
// 10. haftadan itibaren kıvrılmış, sevimli bir bebek figürü çizilir.
// Figür yumuşakça süzülür ve "nefes alır" (hafif animasyon).
// 100x100 sanal tuvalde çizer, gerçek boyuta orantılı ölçeklenir.
// =============================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/pregnancy_data.dart';

class EmbryoIcon extends StatefulWidget {
  final EmbryoStage stage;
  final double size;
  const EmbryoIcon({super.key, required this.stage, this.size = 96});

  @override
  State<EmbryoIcon> createState() => _EmbryoIconState();
}

class _EmbryoIconState extends State<EmbryoIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Yumuşak, sürekli süzülme döngüsü.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _EmbryoPainter(widget.stage, _controller),
        ),
      ),
    );
  }
}

class _EmbryoPainter extends CustomPainter {
  final EmbryoStage stage;
  final Animation<double> anim;
  _EmbryoPainter(this.stage, this.anim) : super(repaint: anim);

  // Cilt tonları
  static const _skin = Color(0xFFF6C6A8);
  static const _skinDark = Color(0xFFE0A988);
  static const _skinLight = Color(0xFFFCDDC8);
  static const _detail = Color(0xFF7A4A38);
  static const _hair = Color(0xFF6D4C41);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100.0;
    canvas.save();
    canvas.scale(s);

    // Yumuşak süzülme + nefes alma animasyonu.
    final bob = sin(anim.value * 2 * pi);
    canvas.translate(0, bob * 2.5);
    canvas.translate(50, 50);
    canvas.scale(1 + bob * 0.03);
    canvas.translate(-50, -50);

    switch (stage) {
      case EmbryoStage.cellCluster:
        _cellCluster(canvas);
        break;
      case EmbryoStage.embryoTadpole:
        _tadpole(canvas);
        break;
      case EmbryoStage.earlyFetus:
        _drawBaby(canvas, scale: 0.78);
        break;
      case EmbryoStage.fetus:
        _drawBaby(canvas, scale: 1.0);
        break;
      case EmbryoStage.plumpFetus:
        _drawBaby(canvas, scale: 1.12, chubby: true);
        break;
      case EmbryoStage.fullTerm:
        _drawBaby(canvas, scale: 1.24, chubby: true);
        break;
    }
    canvas.restore();
  }

  Paint _fill(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // ── 1-4. hafta: hücre topu (morula) ──
  void _cellCluster(Canvas canvas) {
    final halo = Paint()
      ..shader = const RadialGradient(colors: [
        Color(0x33F6C6A8),
        Color(0x00F6C6A8),
      ]).createShader(Rect.fromCircle(center: const Offset(50, 50), radius: 44));
    canvas.drawCircle(const Offset(50, 50), 44, halo);
    const cells = [
      Offset(50, 44), Offset(42, 52), Offset(58, 52),
      Offset(46, 60), Offset(56, 60), Offset(50, 53),
      Offset(40, 44), Offset(60, 44),
    ];
    for (final c in cells) {
      canvas.drawCircle(c, 9, _fill(_skin));
      canvas.drawCircle(c.translate(-2.5, -2.5), 3, _fill(_skinLight));
    }
  }

  // ── 5-9. hafta: kuyruklu embriyo ──
  void _tadpole(Canvas canvas) {
    final body = Path()
      ..moveTo(58, 30)
      ..quadraticBezierTo(82, 38, 74, 60)
      ..quadraticBezierTo(68, 78, 50, 80)
      ..quadraticBezierTo(40, 81, 38, 72)
      ..quadraticBezierTo(46, 70, 48, 58)
      ..quadraticBezierTo(40, 52, 42, 40)
      ..quadraticBezierTo(46, 28, 58, 30)
      ..close();
    canvas.drawPath(body, _fill(_skin));
    canvas.drawPath(body, _stroke(_skinDark, 2));
    // göz noktası
    canvas.drawCircle(const Offset(60, 44), 5, _fill(_detail));
    canvas.drawCircle(const Offset(58.5, 42.5), 1.6, _fill(Colors.white));
    // kalp parıltısı
    canvas.drawCircle(const Offset(56, 58), 4, _fill(const Color(0x66F4511E)));
  }

  // ── 10+ hafta: kıvrılmış, sevimli bebek ──
  void _drawBaby(Canvas canvas, {required double scale, bool chubby = false}) {
    canvas.save();
    canvas.translate(50, 52);
    canvas.scale(scale * 0.95);
    canvas.translate(-50, -52);

    // yumuşak ışık halkası
    final halo = Paint()
      ..shader = const RadialGradient(colors: [
        Color(0x22F6C6A8),
        Color(0x00F6C6A8),
      ]).createShader(Rect.fromCircle(center: const Offset(50, 52), radius: 50));
    canvas.drawCircle(const Offset(50, 52), 50, halo);

    final skin = _fill(_skin);
    final headC = const Offset(39, 37);
    final r = chubby ? 25.0 : 22.0;

    // ---- gövde ----
    final torso = const Offset(53, 61);
    final tw = chubby ? 52.0 : 46.0;
    final th = chubby ? 49.0 : 44.0;
    canvas.drawOval(
        Rect.fromCenter(center: torso, width: tw, height: th), skin);

    // popo
    canvas.drawCircle(const Offset(66, 67), chubby ? 17 : 15, skin);

    // hafif gölge (derinlik için)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(56, 70), width: 34, height: 18),
      _fill(_skinDark.withValues(alpha: 0.35)),
    );

    // ---- bacaklar (karına çekili) ----
    final legW = chubby ? 17.0 : 15.0;
    final thigh = Path()
      ..moveTo(64, 73)
      ..quadraticBezierTo(52, 77, 42, 64);
    canvas.drawPath(thigh, _stroke(_skin, legW));
    final calf = Path()
      ..moveTo(42, 64)
      ..quadraticBezierTo(38, 54, 47, 49);
    canvas.drawPath(calf, _stroke(_skin, legW - 3));
    // minik ayak
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(49, 47), width: 13, height: 9),
        skin);

    // ---- baş ----
    canvas.drawCircle(headC, r, skin);

    // kulak
    canvas.drawCircle(Offset(headC.dx + r - 4, headC.dy + 4), 5.5, skin);

    // ---- kol (yüze yaslı) ----
    final arm = Path()
      ..moveTo(50, 56)
      ..quadraticBezierTo(40, 57, 33, 47);
    canvas.drawPath(arm, _stroke(_skin, chubby ? 13 : 11));
    canvas.drawCircle(const Offset(31, 45), chubby ? 7 : 6, skin); // el

    // ---- yüz (huzurlu, uykuda) ----
    _closedEye(canvas, const Offset(30, 36));
    _closedEye(canvas, const Offset(42, 37));
    // burun
    canvas.drawCircle(const Offset(35.5, 42), 1.5, _fill(_detail));
    // gülümseme
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(36, 46), radius: 4),
      0.15, 2.8, false, _stroke(_detail, 1.8),
    );
    // yanak
    canvas.drawCircle(
        const Offset(28, 44), 4.5, _fill(const Color(0x55F48FB1)));

    // ---- saç tutamı ----
    final hair = Path()
      ..moveTo(headC.dx, headC.dy - r + 3)
      ..quadraticBezierTo(
          headC.dx + 7, headC.dy - r - 8, headC.dx + 15, headC.dy - r + 5);
    canvas.drawPath(hair, _stroke(_hair, 4));

    canvas.restore();
  }

  // Kapalı, huzurlu göz (⌒ şekli)
  void _closedEye(Canvas canvas, Offset c) {
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 4),
      3.34, 2.6, false, _stroke(_detail, 2),
    );
  }

  @override
  bool shouldRepaint(covariant _EmbryoPainter old) => old.stage != stage;
}
