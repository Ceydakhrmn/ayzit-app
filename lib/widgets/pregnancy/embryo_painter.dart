// =============================================
// widgets/pregnancy/embryo_painter.dart
// Bebeğin gebelik aşamasına göre değişen gelişim çizimi.
//
// 8 aşama:
//   1) döllenme (sperm + yumurta)       — hft 1-2
//   2) hücre kümesi (morula)            — hft 3-4
//   3) yelkovan embriyo (C şekli)       — hft 5-6
//   4) erken fetüs (baş + tomurcuklar)  — hft 7-8
//   5) fetüs                            — hft 9-10
//   6) dolgun fetüs                     — hft 11-12
//   7) olgun fetüs                      — hft 13-28
//   8) tam dönem (baş aşağı)            — hft 29-40
//
// Gradient cilt tonu, gerçekçi yüz detayları, göbek bağı,
// amniyon sıvısı arka plan parıltısı ve süzülme animasyonu.
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
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _EmbryoPainter(widget.stage, _ctrl),
        ),
      ),
    );
  }
}

class _EmbryoPainter extends CustomPainter {
  final EmbryoStage stage;
  final Animation<double> anim;
  _EmbryoPainter(this.stage, this.anim) : super(repaint: anim);

  // ── Renk sabitleri ──────────────────────────────────────────────
  static const _skinLight  = Color(0xFFFDE8D8);
  static const _skin        = Color(0xFFF5C5A0);
  static const _skinMid    = Color(0xFFEAA87A);
  static const _skinDark   = Color(0xFFD4895A);
  static const _detail     = Color(0xFF8B4513);
  static const _hair        = Color(0xFF6D4C41);
  static const _lip         = Color(0xFFD47F7F);
  static const _teal        = Color(0xFF4DB6AC);
  static const _blush       = Color(0x55F48FB1);

  // ── Temel paint yardımcıları ────────────────────────────────────
  Paint _flat(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  Paint _line(Color c, double w) => Paint()
    ..color = c
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Radial gradient ile dolu boyama — 3D derinlik için.
  Paint _grad(Rect r, List<Color> cs, {Alignment center = Alignment.topLeft}) {
    return Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        center: center,
        radius: 1.0,
        colors: cs,
      ).createShader(r);
  }

  Paint _skinGrad(Rect r) => _grad(
        r,
        [_skinLight, _skin, _skinMid],
        center: const Alignment(-0.45, -0.45),
      );

  // ── Animasyon ──────────────────────────────────────────────────
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100.0;
    canvas.save();
    canvas.scale(s);

    final bob = sin(anim.value * 2 * pi);
    // yumuşak süzülme
    canvas.translate(0, bob * 2.2);
    // hafif nefes alma
    canvas.translate(50, 50);
    canvas.scale(1 + bob * 0.025);
    canvas.translate(-50, -50);

    switch (stage) {
      case EmbryoStage.fertilization:
        _fertilization(canvas);
        break;
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
        _drawBaby(canvas, scale: 0.68);
        break;
      case EmbryoStage.plumpFetus:
        _drawBaby(canvas, scale: 0.84);
        break;
      case EmbryoStage.matureFetus:
        _drawBaby(canvas, scale: 1.0, chubby: false);
        break;
      case EmbryoStage.fullTerm:
        _drawBaby(canvas, scale: 1.18, chubby: true, headDown: true);
        break;
    }
    canvas.restore();
  }

  // ════════════════════════════════════════════════════════════════
  // 1–2. Hafta: Döllenme
  // ════════════════════════════════════════════════════════════════
  void _fertilization(Canvas canvas) {
    // Ambiyan ışık halkası
    final halo = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x33F6C6A8), Color(0x00F6C6A8)],
      ).createShader(Rect.fromCircle(center: const Offset(56, 52), radius: 44));
    canvas.drawCircle(const Offset(56, 52), 44, halo);

    const eggC = Offset(60, 52);
    // Zona pellucida (dış zar)
    canvas.drawCircle(eggC, 27,
        _flat(const Color(0xFFFFECE0)));
    canvas.drawCircle(eggC, 27,
        _line(const Color(0xFFEAC0A0), 1.5));
    // Yumurta gövdesi — gradient
    final er = Rect.fromCircle(center: eggC, radius: 21);
    canvas.drawCircle(eggC, 21, _skinGrad(er));
    // Parlama
    canvas.drawCircle(eggC.translate(-7, -7), 7,
        _flat(const Color(0xAAFFFFFF)));
    // Çekirdek
    canvas.drawCircle(eggC, 8,
        _flat(_skinDark.withValues(alpha: 0.45)));
    canvas.drawCircle(eggC, 4,
        _flat(_skinLight.withValues(alpha: 0.55)));

    // Arka plan soluk spermler
    _drawSperm(canvas, const Offset(20, 30), 0.50, 0.28);
    _drawSperm(canvas, const Offset(16, 72), -0.45, 0.28);
    // Ana sperm
    _drawSperm(canvas, const Offset(32, 53), 0.0, 1.0);

    // Döllenme parıltısı
    canvas.drawCircle(const Offset(41, 53), 6,
        _flat(const Color(0x99FFE082)));
  }

  void _drawSperm(Canvas canvas, Offset c, double tilt, double op) {
    final col = _teal.withValues(alpha: op);
    // Oval kafa
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 14, height: 10),
      _flat(col),
    );
    canvas.drawCircle(c.translate(-2.5, -2.5), 2.5,
        _flat(Colors.white.withValues(alpha: op * 0.8)));
    final t = c.dy + tilt * 14;
    final tail = Path()
      ..moveTo(c.dx - 7, c.dy)
      ..quadraticBezierTo(
          c.dx - 16, c.dy - 7 + tilt * 8, c.dx - 24, t)
      ..quadraticBezierTo(
          c.dx - 31, t + 8, c.dx - 38, t - 2 + tilt * 4);
    canvas.drawPath(tail, _line(col, 2.6));
  }

  // ════════════════════════════════════════════════════════════════
  // 3–4. Hafta: Morula / Hücre kümesi
  // ════════════════════════════════════════════════════════════════
  void _cellCluster(Canvas canvas) {
    final halo = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x33F6C6A8), Color(0x00F6C6A8)],
      ).createShader(Rect.fromCircle(center: const Offset(50, 50), radius: 44));
    canvas.drawCircle(const Offset(50, 50), 44, halo);

    const cells = [
      Offset(50, 42), Offset(41, 50), Offset(59, 50),
      Offset(45, 58), Offset(55, 58), Offset(50, 52),
      Offset(38, 43), Offset(62, 43),
    ];
    for (final c in cells) {
      final r = Rect.fromCircle(center: c, radius: 10);
      canvas.drawCircle(c, 10, _skinGrad(r));
      canvas.drawCircle(c, 10,
          _line(_skinDark.withValues(alpha: 0.25), 1));
      canvas.drawCircle(c.translate(-2.5, -2.5), 3.5,
          _flat(const Color(0xAAFFFFFF)));
      canvas.drawCircle(c, 4,
          _flat(_skinMid.withValues(alpha: 0.4)));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // 5–6. Hafta: C-şekilli embriyo + ilk kalp atışı
  // ════════════════════════════════════════════════════════════════
  void _tadpole(Canvas canvas) {
    // Amniyon arka plan parıltısı
    canvas.drawCircle(const Offset(52, 54), 44,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0x18B3E5FC), Color(0x00B3E5FC)],
          ).createShader(
              Rect.fromCircle(center: const Offset(52, 54), radius: 44)));

    final bodyR = Rect.fromLTWH(22, 22, 54, 60);
    final body = Path()
      ..moveTo(58, 28)
      ..quadraticBezierTo(82, 36, 74, 58)
      ..quadraticBezierTo(68, 78, 50, 80)
      ..quadraticBezierTo(40, 81, 38, 72)
      ..quadraticBezierTo(46, 68, 48, 56)
      ..quadraticBezierTo(40, 50, 42, 38)
      ..quadraticBezierTo(46, 26, 58, 28)
      ..close();
    canvas.drawPath(body, _skinGrad(bodyR));
    canvas.drawPath(body, _line(_skinDark.withValues(alpha: 0.3), 1.5));

    // Nöral tüp çizgisi (omurga taslağı)
    canvas.drawLine(const Offset(56, 34), const Offset(54, 58),
        _line(_skinDark.withValues(alpha: 0.15), 3));

    // Göz noktası
    canvas.drawCircle(const Offset(60, 43), 5.5, _flat(_detail));
    canvas.drawCircle(const Offset(60, 43), 2.5, _flat(const Color(0xFF1A1A1A)));
    canvas.drawCircle(const Offset(58.5, 41.5), 2, _flat(Colors.white));

    // Kalp parıltısı
    canvas.drawCircle(const Offset(56, 57), 5,
        _flat(const Color(0x88F4511E)));
    canvas.drawCircle(const Offset(56, 57), 2.5,
        _flat(const Color(0xCCF4511E)));
  }

  // ════════════════════════════════════════════════════════════════
  // 7–8. Hafta: Erken fetüs
  // ════════════════════════════════════════════════════════════════
  void _earlyFetus(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 52), 44,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0x18B3E5FC), Color(0x00B3E5FC)],
          ).createShader(
              Rect.fromCircle(center: const Offset(50, 52), radius: 44)));

    // Gövde
    final bodyR = Rect.fromLTWH(34, 44, 38, 42);
    final body = Path()
      ..moveTo(54, 46)
      ..quadraticBezierTo(74, 52, 70, 68)
      ..quadraticBezierTo(66, 84, 50, 83)
      ..quadraticBezierTo(40, 82, 42, 67)
      ..quadraticBezierTo(44, 54, 54, 46)
      ..close();
    canvas.drawPath(body, _skinGrad(bodyR));
    canvas.drawPath(body, _line(_skinDark.withValues(alpha: 0.25), 1.5));

    // Kol tomurcuğu
    canvas.drawLine(const Offset(46, 62), const Offset(34, 67),
        _line(_skin, 8));
    canvas.drawCircle(const Offset(32, 67), 5, _flat(_skin));

    // Bacak tomurcuğu
    canvas.drawLine(const Offset(57, 76), const Offset(54, 89),
        _line(_skin, 9));
    canvas.drawCircle(const Offset(54, 90), 5, _flat(_skin));

    // Büyük baş — gradient
    const headC = Offset(44, 35);
    final headR = Rect.fromCircle(center: headC, radius: 23);
    canvas.drawCircle(headC, 23, _skinGrad(headR));
    canvas.drawCircle(headC, 23,
        _line(_skinDark.withValues(alpha: 0.2), 1.5));

    // Büyük bebek gözü (açık — bu dönemde gözler henüz gelişiyor)
    canvas.drawCircle(const Offset(37, 36), 5, _flat(_detail));
    canvas.drawCircle(const Offset(37, 36), 3, _flat(const Color(0xFF1A1A1A)));
    canvas.drawCircle(const Offset(35.5, 34.5), 1.8, _flat(Colors.white));

    // Küçük burun taslağı
    canvas.drawCircle(const Offset(42, 42), 2, _flat(_skinDark.withValues(alpha: 0.4)));

    // Kulak taslağı
    canvas.drawCircle(const Offset(64, 38), 5, _flat(_skin));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(64, 38), width: 5, height: 7),
      _flat(_skinMid.withValues(alpha: 0.4)),
    );

    // Kalp parıltısı
    canvas.drawCircle(const Offset(55, 62), 4.5,
        _flat(const Color(0x88F4511E)));
  }

  // ════════════════════════════════════════════════════════════════
  // 9+ Hafta: Sevimli ama gerçekçi kıvrılmış bebek
  // ════════════════════════════════════════════════════════════════
  void _drawBaby(
    Canvas canvas, {
    required double scale,
    bool chubby = false,
    bool headDown = false,
  }) {
    canvas.save();

    if (headDown) {
      canvas.translate(0, 104);
      canvas.scale(1, -1);
    }
    canvas.translate(50, 52);
    canvas.scale(scale * 0.92);
    canvas.translate(-50, -52);

    // ── Amniyon sıvısı parıltısı ────────────────────────────────
    canvas.drawCircle(const Offset(50, 52), 50,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0x1AB3E5FC), Color(0x00B3E5FC)],
          ).createShader(
              Rect.fromCircle(center: const Offset(50, 52), radius: 50)));

    final headC = const Offset(38, 35);
    final headR = chubby ? 27.0 : 24.0;
    final torsoC = const Offset(54, 62);
    final torsoW = chubby ? 40.0 : 36.0;
    final torsoH = chubby ? 42.0 : 38.0;

    // ── Gövde ──────────────────────────────────────────────────
    final torsoRect = Rect.fromCenter(
        center: torsoC, width: torsoW, height: torsoH);
    canvas.drawOval(torsoRect, _skinGrad(torsoRect));

    // Popo yuvarlağı
    final buttR = chubby ? 18.0 : 15.0;
    final buttC = Offset(68, torsoC.dy + 5);
    final buttRect = Rect.fromCircle(center: buttC, radius: buttR);
    canvas.drawCircle(buttC, buttR, _skinGrad(buttRect));

    // Gövde gölgesi (derinlik)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(torsoC.dx + 4, torsoC.dy + 8),
          width: 28,
          height: 16),
      _flat(_skinDark.withValues(alpha: 0.18)),
    );

    // ── Bacaklar (karnına çekili fetal pozisyon) ──────────────
    final legW = chubby ? 17.0 : 15.0;
    final legPaint = Paint()
      ..color = _skin
      ..strokeWidth = legW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final calfPaint = Paint()
      ..color = _skin
      ..strokeWidth = legW - 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Uyluk
    final thigh = Path()
      ..moveTo(65, 74)
      ..quadraticBezierTo(50, 80, 40, 65);
    canvas.drawPath(thigh, legPaint);

    // Baldır
    final calf = Path()
      ..moveTo(40, 65)
      ..quadraticBezierTo(35, 55, 45, 48);
    canvas.drawPath(calf, calfPaint);

    // Ayak — oval + parmak çizgileri
    final footC = const Offset(47, 46);
    final footRect =
        Rect.fromCenter(center: footC, width: 16, height: 10);
    canvas.drawOval(footRect, _skinGrad(footRect));
    // Parmak arası çizgiler
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(42.5 + i * 3.0, 42.5),
        Offset(42.5 + i * 3.0, 49.5),
        _line(_skinDark.withValues(alpha: 0.22), 1.2),
      );
    }

    // ── Baş ───────────────────────────────────────────────────
    final headRect = Rect.fromCircle(center: headC, radius: headR);
    canvas.drawCircle(headC, headR, _skinGrad(headRect));

    // Kulak
    final earC = Offset(headC.dx + headR - 3, headC.dy + 5);
    final earRect = Rect.fromCircle(center: earC, radius: 6.5);
    canvas.drawCircle(earC, 6.5, _skinGrad(earRect));
    canvas.drawOval(
      Rect.fromCenter(center: earC, width: 5, height: 7),
      _flat(_skinDark.withValues(alpha: 0.2)),
    );

    // ── Kol (bebeğin yüzünün önünde) ────────────────────────
    final armPaint = Paint()
      ..color = _skin
      ..strokeWidth = chubby ? 14.0 : 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final arm = Path()
      ..moveTo(51, 56)
      ..quadraticBezierTo(40, 57, 32, 47);
    canvas.drawPath(arm, armPaint);

    // El (kapalı yumruk)
    final handC = const Offset(30, 45);
    final handR = chubby ? 8.5 : 7.5;
    final handRect = Rect.fromCircle(center: handC, radius: handR);
    canvas.drawCircle(handC, handR, _skinGrad(handRect));
    // Parmak çizgileri
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(25.5 + i * 3.0, 41.5),
        Offset(25.5 + i * 3.0, 48.5),
        _line(_skinDark.withValues(alpha: 0.22), 1.2),
      );
    }

    // ── Yüz ──────────────────────────────────────────────────
    // Kapalı gözler (huzurlu uyku yayı)
    _closedEye(canvas, Offset(headC.dx - 7, headC.dy + 2));
    _closedEye(canvas, Offset(headC.dx + 6, headC.dy + 2));

    // Göz kapağı / üst çizgi vurgusu
    _eyebrow(canvas, Offset(headC.dx - 7, headC.dy - 3));
    _eyebrow(canvas, Offset(headC.dx + 6, headC.dy - 3));

    // Burun — küçük yuvarlak uçlu
    final nosePath = Path()
      ..moveTo(headC.dx - 3.5, headC.dy + 9)
      ..quadraticBezierTo(headC.dx, headC.dy + 13, headC.dx + 3.5, headC.dy + 9);
    canvas.drawPath(nosePath,
        _line(_skinDark.withValues(alpha: 0.38), 2.0));
    canvas.drawCircle(Offset(headC.dx - 3.5, headC.dy + 9), 1.6,
        _flat(_skinDark.withValues(alpha: 0.28)));
    canvas.drawCircle(Offset(headC.dx + 3.5, headC.dy + 9), 1.6,
        _flat(_skinDark.withValues(alpha: 0.28)));

    // Dudaklar — yay şekli
    final upperLip = Path()
      ..moveTo(headC.dx - 6, headC.dy + 17)
      ..quadraticBezierTo(headC.dx - 2, headC.dy + 14, headC.dx, headC.dy + 16)
      ..quadraticBezierTo(headC.dx + 2, headC.dy + 14, headC.dx + 6, headC.dy + 17);
    canvas.drawPath(upperLip, _line(_lip.withValues(alpha: 0.6), 1.8));

    final lowerLip = Path()
      ..moveTo(headC.dx - 6, headC.dy + 17)
      ..quadraticBezierTo(headC.dx, headC.dy + 22, headC.dx + 6, headC.dy + 17);
    canvas.drawPath(lowerLip, _line(_lip.withValues(alpha: 0.55), 1.8));

    // Yanak pembesi
    canvas.drawCircle(Offset(headC.dx - 13, headC.dy + 11), 5.5,
        _flat(_blush));
    canvas.drawCircle(Offset(headC.dx + 13, headC.dy + 11), 5.5,
        _flat(_blush));

    // ── Saç tutamı (dolgun aşamalardan itibaren) ──────────────
    if (chubby || scale >= 0.9) {
      _drawHair(canvas, headC, headR, dense: chubby);
    }

    // ── Göbek bağı (ince, soluk) ──────────────────────────────
    final cordPath = Path()
      ..moveTo(torsoC.dx - 4, torsoC.dy - torsoH / 2 + 2)
      ..quadraticBezierTo(
          torsoC.dx + 12, torsoC.dy - 22, torsoC.dx + 8, torsoC.dy - 32);
    canvas.drawPath(cordPath,
        _line(const Color(0x66D4895A), 2.8));

    canvas.restore();
  }

  // ── Kapalı göz yayı ────────────────────────────────────────────
  void _closedEye(Canvas canvas, Offset c) {
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 4.5),
      pi + 0.3,
      pi - 0.6,
      false,
      _line(_detail, 2.2),
    );
  }

  // ── Hafif kaş çizgisi ──────────────────────────────────────────
  void _eyebrow(Canvas canvas, Offset c) {
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 4),
      pi + 0.5,
      pi - 1.0,
      false,
      _line(_detail.withValues(alpha: 0.35), 1.4),
    );
  }

  // ── Saç ────────────────────────────────────────────────────────
  void _drawHair(Canvas canvas, Offset headC, double headR,
      {bool dense = false}) {
    final hairPaint = _line(_hair, dense ? 4.5 : 3.5);
    // Ana tutam
    final h1 = Path()
      ..moveTo(headC.dx - 2, headC.dy - headR + 3)
      ..quadraticBezierTo(
          headC.dx + 6, headC.dy - headR - 10, headC.dx + 18, headC.dy - headR + 5);
    canvas.drawPath(h1, hairPaint);
    // Yan tutam
    final h2 = Path()
      ..moveTo(headC.dx - 16, headC.dy - headR + 9)
      ..quadraticBezierTo(
          headC.dx - 8, headC.dy - headR - 6, headC.dx + 2, headC.dy - headR + 4);
    canvas.drawPath(h2, _line(_hair, dense ? 3.5 : 2.5));
    if (dense) {
      // Üçüncü tutam
      final h3 = Path()
        ..moveTo(headC.dx + 8, headC.dy - headR + 2)
        ..quadraticBezierTo(
            headC.dx + 18, headC.dy - headR - 7, headC.dx + 26, headC.dy - headR + 8);
      canvas.drawPath(h3, _line(_hair, 3.0));
    }
  }

  @override
  bool shouldRepaint(covariant _EmbryoPainter old) => old.stage != stage;
}
