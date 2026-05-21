// =============================================
// widgets/pregnancy/embryo_painter.dart
// Bebeğin gebelik aşamasına göre değişen siluet çizimi.
// 6 aşama: hücre topu → kuyruklu embriyo → erken fetüs →
//          fetüs → dolgun fetüs → doğuma hazır bebek.
// 100x100 sanal tuvalde çizer, gerçek boyuta orantılı ölçeklenir.
// =============================================

import 'package:flutter/material.dart';

import '../../data/pregnancy_data.dart';

class EmbryoIcon extends StatelessWidget {
  final EmbryoStage stage;
  final double size;
  const EmbryoIcon({super.key, required this.stage, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _EmbryoPainter(stage)),
    );
  }
}

class _EmbryoPainter extends CustomPainter {
  final EmbryoStage stage;
  _EmbryoPainter(this.stage);

  // Cilt tonları
  static const _skin = Color(0xFFF6C6A8);
  static const _skinDark = Color(0xFFE0A988);
  static const _skinLight = Color(0xFFFCDDC8);
  static const _detail = Color(0xFF8D5A44);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100.0;
    canvas.save();
    canvas.scale(s);
    switch (stage) {
      case EmbryoStage.cellCluster:
        _cellCluster(canvas);
        break;
      case EmbryoStage.embryoTadpole:
        _tadpole(canvas);
        break;
      case EmbryoStage.earlyFetus:
        _earlyFetus(canvas);
        break;
      case EmbryoStage.fetus:
        _fetus(canvas, scale: 1.0);
        break;
      case EmbryoStage.plumpFetus:
        _fetus(canvas, scale: 1.12);
        break;
      case EmbryoStage.fullTerm:
        _fetus(canvas, scale: 1.24, chubby: true);
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
    ..strokeCap = StrokeCap.round;

  // ── 1-4. hafta: hücre topu (morula) ──
  void _cellCluster(Canvas canvas) {
    final halo = Paint()
      ..shader = const RadialGradient(colors: [
        Color(0x33F6C6A8),
        Color(0x00F6C6A8),
      ]).createShader(Rect.fromCircle(center: const Offset(50, 50), radius: 44));
    canvas.drawCircle(const Offset(50, 50), 44, halo);
    final cells = [
      const Offset(50, 44), const Offset(42, 52), const Offset(58, 52),
      const Offset(46, 60), const Offset(56, 60), const Offset(50, 53),
      const Offset(40, 44), const Offset(60, 44),
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
      ..quadraticBezierTo(40, 81, 38, 72) // kuyruk ucu
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

  // ── 10-13. hafta: büyük başlı erken fetüs ──
  void _earlyFetus(Canvas canvas) {
    // gövde (kıvrık)
    final body = Path()
      ..moveTo(52, 48)
      ..quadraticBezierTo(74, 52, 70, 72)
      ..quadraticBezierTo(66, 86, 48, 84)
      ..quadraticBezierTo(36, 82, 40, 66)
      ..quadraticBezierTo(42, 54, 52, 48)
      ..close();
    canvas.drawPath(body, _fill(_skin));
    canvas.drawPath(body, _stroke(_skinDark, 2));
    // kol ve bacak tomurcukları
    canvas.drawLine(const Offset(46, 62), const Offset(34, 70), _stroke(_skin, 7));
    canvas.drawLine(const Offset(58, 74), const Offset(54, 88), _stroke(_skin, 8));
    // büyük baş
    canvas.drawCircle(const Offset(46, 40), 22, _fill(_skin));
    canvas.drawCircle(const Offset(46, 40), 22, _stroke(_skinDark, 2));
    // yüz
    canvas.drawCircle(const Offset(40, 42), 3.2, _fill(_detail));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(41, 49), radius: 4),
      0.2, 2.6, false, _stroke(_detail, 1.6));
  }

  // ── 14+ hafta: kıvrılmış bebek silueti ──
  void _fetus(Canvas canvas, {required double scale, bool chubby = false}) {
    canvas.save();
    canvas.translate(50, 52);
    canvas.scale(scale * 0.92);
    canvas.translate(-50, -52);

    // halo
    final halo = Paint()
      ..shader = const RadialGradient(colors: [
        Color(0x22F6C6A8),
        Color(0x00F6C6A8),
      ]).createShader(Rect.fromCircle(center: const Offset(50, 50), radius: 48));
    canvas.drawCircle(const Offset(50, 50), 48, halo);

    // gövde — kıvrık fasulye şekli
    final body = Path()
      ..moveTo(54, 40)
      ..quadraticBezierTo(78, 46, 74, 70)
      ..quadraticBezierTo(70, 90, 46, 88)
      ..quadraticBezierTo(28, 86, 32, 66)
      ..quadraticBezierTo(35, 50, 54, 40)
      ..close();
    canvas.drawPath(body, _fill(_skin));
    canvas.drawPath(body, _stroke(_skinDark, 2));

    // kol — göğüste kıvrık
    canvas.drawLine(const Offset(48, 56), const Offset(40, 68), _stroke(_skin, chubby ? 11 : 9));
    // bacaklar — karına çekili
    canvas.drawLine(const Offset(56, 74), const Offset(46, 86), _stroke(_skin, chubby ? 13 : 11));
    canvas.drawLine(const Offset(64, 70), const Offset(60, 86), _stroke(_skin, chubby ? 12 : 10));

    // baş
    final headR = chubby ? 23.0 : 21.0;
    canvas.drawCircle(const Offset(44, 34), headR, _fill(_skin));
    canvas.drawCircle(const Offset(44, 34), headR, _stroke(_skinDark, 2));
    // yanak ışığı
    canvas.drawCircle(const Offset(36, 40), 4, _fill(const Color(0x55F48FB1)));

    // yüz — huzurlu
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(37, 34), radius: 3.4),
      3.5, 2.3, false, _stroke(_detail, 1.8)); // sol göz (kapalı)
    canvas.drawCircle(const Offset(46, 35), 2.6, _fill(_detail)); // sağ göz
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(42, 43), radius: 4),
      0.25, 2.5, false, _stroke(_detail, 1.6)); // gülümseme

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EmbryoPainter old) => old.stage != stage;
}
