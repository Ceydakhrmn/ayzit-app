// =============================================
// widgets/pregnancy/fruit_painter.dart
// Bebeğin haftalık boyutunu temsil eden basit flat-vektör meyve/sebze
// çizimleri. 17 arketip — her gebelik haftası birine eşlenir.
// 100x100 sanal tuvalde çizer, gerçek boyuta orantılı ölçeklenir.
// =============================================

import 'package:flutter/material.dart';

import '../../data/pregnancy_data.dart';

class FruitIcon extends StatelessWidget {
  final FruitShape shape;
  final double size;
  const FruitIcon({super.key, required this.shape, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FruitPainter(shape)),
    );
  }
}

class _FruitPainter extends CustomPainter {
  final FruitShape shape;
  _FruitPainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    if (shape == FruitShape.none) return;
    // 100x100 sanal tuval → gerçek boyut.
    final s = size.width / 100.0;
    canvas.save();
    canvas.scale(s);
    switch (shape) {
      case FruitShape.none:
        break;
      case FruitShape.tinySeed:
        _seed(canvas);
        break;
      case FruitShape.smallRound:
        _smallRound(canvas);
        break;
      case FruitShape.raspberry:
        _raspberry(canvas);
        break;
      case FruitShape.strawberry:
        _strawberry(canvas);
        break;
      case FruitShape.citrus:
        _citrus(canvas);
        break;
      case FruitShape.apple:
        _apple(canvas);
        break;
      case FruitShape.avocado:
        _avocado(canvas);
        break;
      case FruitShape.pear:
        _pear(canvas);
        break;
      case FruitShape.pepper:
        _pepper(canvas);
        break;
      case FruitShape.banana:
        _banana(canvas);
        break;
      case FruitShape.carrot:
        _carrot(canvas);
        break;
      case FruitShape.longGreen:
        _longGreen(canvas);
        break;
      case FruitShape.corn:
        _corn(canvas);
        break;
      case FruitShape.leafy:
        _leafy(canvas);
        break;
      case FruitShape.eggplant:
        _eggplant(canvas);
        break;
      case FruitShape.melon:
        _melon(canvas);
        break;
      case FruitShape.watermelon:
        _watermelon(canvas);
        break;
    }
    canvas.restore();
  }

  Paint _fill(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  void _stem(Canvas canvas, Offset top, {Color c = const Color(0xFF6D8B3A)}) {
    canvas.drawLine(top, top.translate(6, -12), _stroke(c, 5));
  }

  void _leaf(Canvas canvas, Offset base, double dir) {
    final p = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx + 16 * dir, base.dy - 14, base.dx + 22 * dir, base.dy + 2)
      ..quadraticBezierTo(base.dx + 12 * dir, base.dy + 2, base.dx, base.dy);
    canvas.drawPath(p, _fill(const Color(0xFF7CB342)));
  }

  // ── Arketipler ──

  void _seed(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 52), width: 26, height: 18),
      _fill(const Color(0xFF5D4037)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(45, 48), width: 8, height: 5),
      _fill(const Color(0xFF8D6E63)),
    );
  }

  void _smallRound(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 54), 26, _fill(const Color(0xFF8E44AD)));
    canvas.drawCircle(const Offset(42, 46), 8, _fill(const Color(0xFFB57EDC)));
    _stem(canvas, const Offset(50, 30));
  }

  void _raspberry(Canvas canvas) {
    const c = Color(0xFFD81B60);
    const cl = Color(0xFFEC6A9C);
    final pts = [
      const Offset(42, 44), const Offset(58, 44),
      const Offset(36, 58), const Offset(50, 58), const Offset(64, 58),
      const Offset(43, 72), const Offset(57, 72),
    ];
    for (final p in pts) {
      canvas.drawCircle(p, 9, _fill(c));
      canvas.drawCircle(p.translate(-2.5, -2.5), 3, _fill(cl));
    }
    _leaf(canvas, const Offset(50, 36), -1);
    _leaf(canvas, const Offset(50, 36), 1);
  }

  void _strawberry(Canvas canvas) {
    final body = Path()
      ..moveTo(28, 44)
      ..quadraticBezierTo(34, 86, 50, 86)
      ..quadraticBezierTo(66, 86, 72, 44)
      ..quadraticBezierTo(50, 56, 28, 44)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFE53935)));
    final seed = _fill(const Color(0xFFFFE082));
    for (final p in [
      const Offset(43, 56), const Offset(57, 56),
      const Offset(50, 66), const Offset(40, 70), const Offset(60, 70),
    ]) {
      canvas.drawCircle(p, 2.2, seed);
    }
    // yeşil kaliks
    final cal = Path()
      ..moveTo(34, 44)
      ..lineTo(50, 32)
      ..lineTo(66, 44)
      ..quadraticBezierTo(50, 50, 34, 44)
      ..close();
    canvas.drawPath(cal, _fill(const Color(0xFF66BB6A)));
  }

  void _citrus(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 54), 28, _fill(const Color(0xFFFFC107)));
    canvas.drawCircle(const Offset(40, 44), 9, _fill(const Color(0xFFFFD966)));
    _stem(canvas, const Offset(50, 28));
    _leaf(canvas, const Offset(52, 28), 1);
  }

  void _apple(Canvas canvas) {
    final body = Path()
      ..addOval(Rect.fromCenter(center: const Offset(38, 56), width: 44, height: 50))
      ..addOval(Rect.fromCenter(center: const Offset(62, 56), width: 44, height: 50));
    canvas.drawPath(body, _fill(const Color(0xFFE53935)));
    canvas.drawCircle(const Offset(40, 46), 8, _fill(const Color(0xFFFF8A80)));
    canvas.drawLine(const Offset(50, 34), const Offset(52, 24), _stroke(const Color(0xFF6D4C41), 4));
    _leaf(canvas, const Offset(52, 28), 1);
  }

  void _avocado(Canvas canvas) {
    final body = Path()
      ..moveTo(50, 22)
      ..quadraticBezierTo(78, 40, 74, 64)
      ..quadraticBezierTo(70, 86, 50, 86)
      ..quadraticBezierTo(30, 86, 26, 64)
      ..quadraticBezierTo(22, 40, 50, 22)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFF558B2F)));
    final flesh = Path()
      ..moveTo(50, 34)
      ..quadraticBezierTo(66, 46, 64, 64)
      ..quadraticBezierTo(60, 78, 50, 78)
      ..quadraticBezierTo(40, 78, 36, 64)
      ..quadraticBezierTo(34, 46, 50, 34)
      ..close();
    canvas.drawPath(flesh, _fill(const Color(0xFFC5E1A5)));
    canvas.drawCircle(const Offset(50, 62), 10, _fill(const Color(0xFF8D6E63)));
  }

  void _pear(Canvas canvas) {
    final body = Path()
      ..addOval(Rect.fromCenter(center: const Offset(50, 64), width: 48, height: 52))
      ..addOval(Rect.fromCenter(center: const Offset(50, 40), width: 30, height: 34));
    canvas.drawPath(body, _fill(const Color(0xFFCDDC39)));
    canvas.drawCircle(const Offset(42, 56), 8, _fill(const Color(0xFFE6EE9C)));
    _stem(canvas, const Offset(50, 24));
  }

  void _pepper(Canvas canvas) {
    final body = Path()
      ..moveTo(30, 40)
      ..quadraticBezierTo(24, 78, 40, 84)
      ..quadraticBezierTo(50, 80, 60, 84)
      ..quadraticBezierTo(76, 78, 70, 40)
      ..quadraticBezierTo(50, 50, 30, 40)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFEF5350)));
    canvas.drawCircle(const Offset(40, 56), 7, _fill(const Color(0xFFFF8A80)));
    canvas.drawLine(const Offset(50, 40), const Offset(50, 26), _stroke(const Color(0xFF558B2F), 6));
  }

  void _banana(Canvas canvas) {
    final body = Path()
      ..moveTo(28, 30)
      ..quadraticBezierTo(34, 78, 78, 72)
      ..quadraticBezierTo(70, 64, 64, 60)
      ..quadraticBezierTo(40, 60, 38, 30)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFFFD54F)));
    canvas.drawLine(const Offset(30, 30), const Offset(34, 26), _stroke(const Color(0xFF6D4C41), 5));
  }

  void _carrot(Canvas canvas) {
    final body = Path()
      ..moveTo(38, 36)
      ..lineTo(62, 36)
      ..lineTo(52, 86)
      ..lineTo(48, 86)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFFB8C00)));
    final hl = _stroke(const Color(0xFFFFCC80), 2.5);
    canvas.drawLine(const Offset(44, 48), const Offset(56, 48), hl);
    canvas.drawLine(const Offset(46, 60), const Offset(54, 60), hl);
    for (final dx in [-12.0, 0.0, 12.0]) {
      _leaf(canvas, Offset(50 + dx * 0.3, 36), dx == 0 ? 1 : (dx < 0 ? -1 : 1));
    }
  }

  void _longGreen(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(50, 54), width: 30, height: 60),
      const Radius.circular(15),
    );
    canvas.drawRRect(r, _fill(const Color(0xFF7CB342)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(44, 50), width: 7, height: 36),
        const Radius.circular(4)),
      _fill(const Color(0xFFAED581)),
    );
    _stem(canvas, const Offset(50, 24));
  }

  void _corn(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(50, 56), width: 34, height: 56),
      const Radius.circular(17),
    );
    canvas.drawRRect(r, _fill(const Color(0xFFFFD54F)));
    final dot = _fill(const Color(0xFFFFB300));
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawCircle(Offset(40 + col * 10, 38 + row * 10), 3.2, dot);
      }
    }
    // yeşil yapraklar
    _leaf(canvas, const Offset(50, 30), -1);
    _leaf(canvas, const Offset(50, 30), 1);
  }

  void _leafy(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 56), 28, _fill(const Color(0xFF66BB6A)));
    final v = _stroke(const Color(0xFF388E3C), 2.5);
    canvas.drawArc(Rect.fromCircle(center: const Offset(50, 56), radius: 20), 0, 6.28, false, v);
    canvas.drawArc(Rect.fromCircle(center: const Offset(50, 56), radius: 11), 0, 6.28, false, v);
    canvas.drawCircle(const Offset(42, 48), 7, _fill(const Color(0xFFA5D6A7)));
  }

  void _eggplant(Canvas canvas) {
    final body = Path()
      ..moveTo(50, 30)
      ..quadraticBezierTo(80, 40, 74, 66)
      ..quadraticBezierTo(68, 88, 50, 88)
      ..quadraticBezierTo(32, 88, 30, 66)
      ..quadraticBezierTo(28, 42, 50, 30)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFF7E3FF2)));
    canvas.drawCircle(const Offset(42, 56), 8, _fill(const Color(0xFFB388FF)));
    final cal = Path()
      ..moveTo(38, 34)
      ..lineTo(50, 22)
      ..lineTo(62, 34)
      ..quadraticBezierTo(50, 40, 38, 34)
      ..close();
    canvas.drawPath(cal, _fill(const Color(0xFF558B2F)));
  }

  void _melon(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 54), 30, _fill(const Color(0xFF9CCC65)));
    final stripe = _stroke(const Color(0xFF689F38), 2.2);
    for (final dx in [-16.0, -6.0, 4.0, 14.0]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(50 + dx, 54), width: 26, height: 60),
        0, 6.28, false, stripe);
    }
    _stem(canvas, const Offset(50, 26));
  }

  void _watermelon(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 54), 32, _fill(const Color(0xFF388E3C)));
    for (final dx in [-18.0, -6.0, 6.0, 18.0]) {
      final p = Path()
        ..moveTo(50 + dx, 24)
        ..quadraticBezierTo(50 + dx * 1.3, 54, 50 + dx, 84);
      canvas.drawPath(p, _stroke(const Color(0xFF1B5E20), 5));
    }
    canvas.drawCircle(const Offset(40, 42), 8, _fill(const Color(0xFF66BB6A)));
    _stem(canvas, const Offset(50, 24));
  }

  @override
  bool shouldRepaint(covariant _FruitPainter old) => old.shape != shape;
}
