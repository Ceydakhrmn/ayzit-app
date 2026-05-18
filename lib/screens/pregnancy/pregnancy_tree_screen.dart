// =============================================
// screens/pregnancy/pregnancy_tree_screen.dart
//
// Lunora "Hamile Takip" home screen: instead of a calendar, the user sees
// a programmatically-painted ay çiçeği (sunflower) that grows alongside
// the pregnancy.  Drawn entirely in Flutter via SunflowerPainter — no
// Lottie, no PNG assets, perfect positional consistency.
//
//   • The plant is paused at the visual for the current week.  It grows
//     visibly when:
//       (a) the actual pregnancy week advances, or
//       (b) the user presses "Su Ver" (water) → grows 1 week forward
//       (smoothly tweened over 1 real second by _growController)
//   • Trimester boundaries:
//       1st trimester: weeks 1–12   →  seed → sprout → 2 leaves
//       2nd trimester: weeks 13–27  →  thick stem, heart leaves, bud
//       3rd trimester: weeks 28–40  →  flowering → Fibonacci → seed drop
//   • Care buttons (Su / Güneş / Sevgi) at the top — gamification overlay
//   • Soft sky-to-meadow gradient background, static clouds & butterflies
//   • LMP date picker is reached by tapping the week badge (no bottom bar)
// =============================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cycle_provider.dart';
import 'sunflower_painter.dart';

class PregnancyTreeScreen extends StatefulWidget {
  const PregnancyTreeScreen({super.key});

  @override
  State<PregnancyTreeScreen> createState() => _PregnancyTreeScreenState();
}

class _PregnancyTreeScreenState extends State<PregnancyTreeScreen>
    with TickerProviderStateMixin {
  static const int totalWeeks = 40;

  // Drives smooth tweening between weeks (value 0..1 → week 1..40).
  late final AnimationController _growController;

  // Drives the falling-seed animation at week 40 (value 0..1).
  late final AnimationController _seedDropController;

  // The week the tree is currently grown to.  Starts from the real
  // pregnancy week and increases when the user waters (capped at 40).
  int _displayedWeek = 1;
  bool _sunActive = false;
  bool _isGrowing = false; // true while the tree is mid-grow animation

  // Active overlay effects
  final List<_DropFx> _drops = [];
  final List<_BurstButterfly> _burstButterflies = [];

  // Persistent ambient butterflies — drawn STATICALLY (no per-frame rebuild).
  // Continuous 60fps animation here was the main source of UI jank.
  late final List<_AmbientButterfly> _ambient;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    // Continuous controller — value 0..1 maps linearly to week 1..40.
    // When the user waters, we animate it from currentWeek → currentWeek+1
    // over 1 real second so the painter draws a smooth growth tween.
    _growController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Falls the ripe seed at week 40 (Phase 4).
    _seedDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Two static ambient butterflies — perched, not animated
    _ambient = List.generate(2, (i) => _AmbientButterfly.random(_rng, i));

    // Seek to current week once mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cycle = context.read<CycleProvider>();
      if (!mounted) return;
      setState(() => _displayedWeek = cycle.pregnancyWeek);
      _growController.value = (_displayedWeek - 1) / (totalWeeks - 1);
    });
  }

  @override
  void dispose() {
    _growController.dispose();
    _seedDropController.dispose();
    super.dispose();
  }

  // ───────────────────────── animation control ─────────────────────────

  /// Snap the tree to a specific week (no animation, just position).
  void _seekToWeek(int week) {
    final w = week.clamp(1, totalWeeks);
    setState(() => _displayedWeek = w);
    _growController.value = (w - 1) / (totalWeeks - 1);
  }

  /// Smoothly grow from `from` → `to` weeks.  1 week takes 1 real second.
  Future<void> _growTo(int to) async {
    final from = _displayedWeek;
    final target = to.clamp(1, totalWeeks);
    if (target == from || _isGrowing) return;
    setState(() => _isGrowing = true);
    await _growController.animateTo(
      (target - 1) / (totalWeeks - 1),
      duration: Duration(seconds: (target - from).abs()),
      curve: Curves.easeInOut,
    );
    if (!mounted) return;
    setState(() {
      _displayedWeek = target;
      _isGrowing = false;
    });
    // If we just landed on week 40, trigger the ripe-seed drop animation.
    if (target == totalWeeks) {
      _seedDropController.forward(from: 0);
    }
  }

  // ───────────────────────── care actions ─────────────────────────

  /// Watering grows the tree by exactly 1 week (animated over 1 second).
  void _onWater() {
    // Drop FX (water particles)
    for (var i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!mounted) return;
        final id = UniqueKey();
        setState(() {
          _drops.add(_DropFx(
            id: id,
            left: 140 + _rng.nextDouble() * 100,
          ));
        });
        Future.delayed(const Duration(milliseconds: 1700), () {
          if (!mounted) return;
          setState(() => _drops.removeWhere((d) => d.id == id));
        });
      });
    }
    // Grow one week forward
    if (_displayedWeek < totalWeeks) {
      _growTo(_displayedWeek + 1);
    }
  }

  void _onSun() {
    setState(() => _sunActive = !_sunActive);
  }

  void _onLove() {
    // 3 butterflies, each from a different random spot in the canopy area
    final palettes = _BurstButterfly._palettes;
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        if (!mounted) return;
        final palette = palettes[_rng.nextInt(palettes.length)];
        final spawnX = 70 + _rng.nextDouble() * 190;
        final spawnY = 200 + _rng.nextDouble() * 180;
        final angle = _rng.nextDouble() * 2 * pi;
        final dist = 90 + _rng.nextDouble() * 110;
        final dx = cos(angle) * dist;
        final dy = sin(angle) * dist - 40;
        final rot = _rng.nextDouble() * 120 - 60;
        final id = UniqueKey();
        setState(() {
          _burstButterflies.add(_BurstButterfly(
            id: id,
            startX: spawnX,
            startY: spawnY,
            dx: dx,
            dy: dy,
            rotation: rot,
            palette: palette,
          ));
        });
        Future.delayed(const Duration(milliseconds: 2700), () {
          if (!mounted) return;
          setState(() =>
              _burstButterflies.removeWhere((b) => b.id == id));
        });
      });
    }
  }

  // ───────────────────────── build ─────────────────────────

  /// Pure helper — avoids subscribing the whole screen to CycleProvider.
  int _trimester(int week) {
    if (week <= 12) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final week = _displayedWeek;
    final trimester = _trimester(week);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final stageW = constraints.maxWidth;
          final stageH = constraints.maxHeight;

          return Stack(
            children: [
              // Background gradient (sky → meadow) — static, isolated
              const RepaintBoundary(child: _SkyGradient()),

              // Static clouds (no animation) — isolated repaint
              const RepaintBoundary(child: _StaticClouds()),

              // Sun overlay (top-right) when sun care active
              if (_sunActive) const RepaintBoundary(child: _SunOverlay()),

              // The sunflower — programmatic Flutter painter, no Lottie.
              // Pot/stem origin are constants in the painter, so position
              // is millimetrically identical across all 40 weeks.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 90, 20, 0),
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                          [_growController, _seedDropController]),
                      builder: (_, __) {
                        final week = 1 +
                            _growController.value * (totalWeeks - 1);
                        return CustomPaint(
                          painter: SunflowerPainter(
                            weekProgress: week,
                            seedDrop: _seedDropController.value,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // (Grass strip removed — the sunflower is in a pot now, so
              // the meadow gradient at the bottom of the sky serves as
              // the visual ground.  _GrassStrip is kept defined below
              // in case it's needed for a future variant.)

              // Ambient butterflies — drawn ONCE (static), no 60fps rebuild
              RepaintBoundary(
                child: SizedBox(
                  width: stageW,
                  height: stageH,
                  child: Stack(
                    children: _ambient
                        .map((b) => b.buildStatic(stageW, stageH))
                        .toList(),
                  ),
                ),
              ),

              // Drop FX (water care)
              ..._drops.map((d) => Positioned(
                    left: d.left,
                    top: 90,
                    child: _AnimatedDrop(key: ValueKey(d.id)),
                  )),

              // Burst butterflies (love care)
              ..._burstButterflies.map(
                (b) => Positioned(
                  left: b.startX,
                  top: b.startY,
                  child: _AnimatedBurst(
                    key: ValueKey(b.id),
                    dx: b.dx,
                    dy: b.dy,
                    rotation: b.rotation,
                    palette: b.palette,
                  ),
                ),
              ),

              // Top: week badge (left, tappable for LMP) + trimester badge
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _pickLmpDate(context),
                      child: _TopBadge(
                        icon: Icons.calendar_today_outlined,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Hafta '),
                              TextSpan(
                                text: '$week',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFEC4899),
                                ),
                              ),
                              const TextSpan(text: ' / 40'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _TopBadge(
                      child: Text(
                        '$trimester. Trimester',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Care buttons row, just below the badges
              Positioned(
                top: 60,
                left: 18,
                right: 18,
                child: Row(
                  children: [
                    Expanded(
                      child: _CareButton(
                        icon: '💧',
                        label: 'SU VER',
                        iconColor: const Color(0xFF40BCD8),
                        onTap: _onWater,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CareButton(
                        icon: '☀️',
                        label: 'GÜNEŞ',
                        iconColor: const Color(0xFFFFB627),
                        onTap: _onSun,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CareButton(
                        icon: '💖',
                        label: 'SEVGİ',
                        iconColor: const Color(0xFFEC4899),
                        onTap: _onLove,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          );
        }),
      ),
    );
  }

  Future<void> _pickLmpDate(BuildContext context) async {
    final cycle = context.read<CycleProvider>();
    final initial = cycle.pregnancyStartDate ??
        DateTime.now().subtract(const Duration(days: 56)); // ~8 weeks ago
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 280)), // 40 weeks back
      lastDate: now,
      helpText: 'Son adet başlangıcı',
    );
    if (picked != null) {
      cycle.updatePregnancyStartDate(picked);
      // Recompute pregnancyWeek (provider just updated) and snap to it.
      _seekToWeek(cycle.pregnancyWeek);
    }
  }
}

// ──────────────────────── helper widgets ────────────────────────

class _SkyGradient extends StatelessWidget {
  const _SkyGradient();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBCDCFF), // sky blue top
            Color(0xFFDBECFF),
            Color(0xFFFFFFFF), // white middle
            Color(0xFFEAF6E0),
            Color(0xFFCFEAB8),
            Color(0xFF7CC16E), // meadow green
          ],
          stops: [0.0, 0.18, 0.38, 0.58, 0.78, 1.0],
        ),
      ),
    );
  }
}

class _StaticClouds extends StatelessWidget {
  const _StaticClouds();

  @override
  Widget build(BuildContext context) {
    // Static clouds — no animation. Continuous 60fps Transform.translate
    // here was contributing to UI jank, so we just paint them in place.
    return const Stack(
      children: [
        Positioned(
          top: 30,
          left: -10,
          child: _Cloud(width: 160, height: 60, opacity: 0.85),
        ),
        Positioned(
          top: 80,
          right: -20,
          child: _Cloud(width: 140, height: 50, opacity: 0.85),
        ),
        Positioned(
          top: 110,
          left: 90,
          child: _Cloud(width: 120, height: 42, opacity: 0.6),
        ),
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width, height, opacity;
  const _Cloud(
      {required this.width, required this.height, required this.opacity});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: opacity),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.35, 0.7],
        ),
      ),
    );
  }
}

class _SunOverlay extends StatefulWidget {
  const _SunOverlay();
  @override
  State<_SunOverlay> createState() => _SunOverlayState();
}

class _SunOverlayState extends State<_SunOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 60,
      child: RotationTransition(
        turns: _ctrl,
        child: Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFFFD54A), Color(0xFFFFB627)],
              stops: [0.0, 0.75],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x8CFFB428),
                blurRadius: 50,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrassStrip extends StatelessWidget {
  const _GrassStrip();
  @override
  Widget build(BuildContext context) {
    // Sized so the trunk is clearly visible ABOVE the grass — the grass
    // only covers the very bottom of the Lottie viewBox where there's no
    // tree content.  Adjust if the trunk still looks like it's floating.
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: CustomPaint(painter: _GrassPainter()),
    );
  }
}

class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // back grass
    final back = Paint()..color = const Color(0xFF5FA056);
    final pBack = Path()..moveTo(0, h);
    pBack.lineTo(0, h * 0.625);
    for (double x = 0; x <= w; x += 8) {
      pBack.quadraticBezierTo(
          x + 4, h * 0.375, x + 8, x.toInt() % 16 == 0 ? h * 0.625 : h * 0.575);
    }
    pBack.lineTo(w, h);
    pBack.close();
    canvas.drawPath(pBack, back);

    // front grass
    final front = Paint()..color = const Color(0xFF7DC16D);
    final pFront = Path()..moveTo(0, h);
    pFront.lineTo(0, h * 0.79);
    for (double x = 0; x <= w; x += 10) {
      pFront.quadraticBezierTo(
          x + 5, h * 0.58, x + 10, x.toInt() % 20 == 0 ? h * 0.83 : h * 0.79);
    }
    pFront.lineTo(w, h);
    pFront.close();
    canvas.drawPath(pFront, front);

    // tiny flowers
    final flowers = [
      _Flower(0.13, 0.66, const Color(0xFFF9A8D4)),
      _Flower(0.47, 0.72, const Color(0xFFFFFFFF)),
      _Flower(0.76, 0.69, const Color(0xFFA78BFA)),
      _Flower(0.89, 0.75, const Color(0xFFF9A8D4)),
      _Flower(0.29, 0.71, const Color(0xFFFFFFFF)),
    ];
    for (final f in flowers) {
      final cx = f.xRatio * w;
      final cy = f.yRatio * h;
      canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = f.color);
      canvas.drawCircle(
          Offset(cx, cy), 0.8, Paint()..color = const Color(0xFFFDE047));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Flower {
  final double xRatio, yRatio;
  final Color color;
  _Flower(this.xRatio, this.yRatio, this.color);
}

class _TopBadge extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  const _TopBadge({required this.child, this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 4),
          ],
          DefaultTextStyle.merge(
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7C3AED),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CareButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  const _CareButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon,
                style: TextStyle(fontSize: 18, color: iconColor)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── overlay FX models ────────────────────────

class _DropFx {
  final UniqueKey id;
  final double left;
  _DropFx({required this.id, required this.left});
}

class _AnimatedDrop extends StatefulWidget {
  const _AnimatedDrop({super.key});
  @override
  State<_AnimatedDrop> createState() => _AnimatedDropState();
}

class _AnimatedDropState extends State<_AnimatedDrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final dy = t * 360;
        final opacity = t < 0.2 ? t * 5 : (t > 0.9 ? (1 - t) * 10 : 1.0);
        return Transform.translate(
          offset: Offset(0, dy),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: 8,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFF40BCD8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(4, 7),
                  topRight: Radius.elliptical(4, 7),
                  bottomLeft: Radius.elliptical(4, 5),
                  bottomRight: Radius.elliptical(4, 5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x9940BCD8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BurstButterfly {
  final UniqueKey id;
  final double startX, startY;
  final double dx, dy;
  final double rotation;
  final _BfPalette palette;
  _BurstButterfly({
    required this.id,
    required this.startX,
    required this.startY,
    required this.dx,
    required this.dy,
    required this.rotation,
    required this.palette,
  });

  static const _palettes = [
    _BfPalette(Color(0xFFF472B6), Color(0xFFEC4899), Color(0xFF3B1F1C)),
    _BfPalette(Color(0xFFA78BFA), Color(0xFF7C3AED), Color(0xFF2E1065)),
    _BfPalette(Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFF451A03)),
    _BfPalette(Color(0xFF67E8F9), Color(0xFF06B6D4), Color(0xFF0E2C33)),
    _BfPalette(Color(0xFFFDA4AF), Color(0xFFFB7185), Color(0xFF3B0D1D)),
    _BfPalette(Color(0xFF86EFAC), Color(0xFF22C55E), Color(0xFF0E2E1C)),
  ];
}

class _BfPalette {
  final Color a, b, body;
  const _BfPalette(this.a, this.b, this.body);
}

class _AnimatedBurst extends StatefulWidget {
  final double dx, dy, rotation;
  final _BfPalette palette;
  const _AnimatedBurst({
    super.key,
    required this.dx,
    required this.dy,
    required this.rotation,
    required this.palette,
  });
  @override
  State<_AnimatedBurst> createState() => _AnimatedBurstState();
}

class _AnimatedBurstState extends State<_AnimatedBurst>
    with TickerProviderStateMixin {
  late final AnimationController _move;
  late final AnimationController _flap;
  @override
  void initState() {
    super.initState();
    _move = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..forward();
    _flap = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _move.dispose();
    _flap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _move,
      builder: (_, __) {
        final t = _move.value;
        final dx = widget.dx * t;
        final dy = widget.dy * t;
        final rot = widget.rotation * t;
        final opacity = t < 0.15 ? t / 0.15 : (1 - t);
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rot * pi / 180,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: AnimatedBuilder(
                animation: _flap,
                builder: (_, __) => SizedBox(
                  width: 30,
                  height: 26,
                  child: CustomPaint(
                    painter: _ButterflyPainter(
                      palette: widget.palette,
                      flap: 1 - 0.45 * _flap.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  final _BfPalette palette;
  final double flap; // 0.55..1.0 — horizontal scale of wings
  _ButterflyPainter({required this.palette, required this.flap});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(flap, 1);

    final paintA = Paint()..color = palette.a;
    final paintB = Paint()..color = palette.b;
    final body = Paint()..color = palette.body;
    final dot = Paint()..color = const Color(0xB3FFFFFF);

    // left wings
    canvas.drawOval(Rect.fromCenter(center: const Offset(-5, -1), width: 14, height: 18), paintA);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-5, 4), width: 10, height: 13), paintB);
    canvas.drawCircle(const Offset(-5, -3), 1.5, dot);

    // right wings
    canvas.drawOval(Rect.fromCenter(center: const Offset(5, -1), width: 14, height: 18), paintA);
    canvas.drawOval(Rect.fromCenter(center: const Offset(5, 4), width: 10, height: 13), paintB);
    canvas.drawCircle(const Offset(5, -3), 1.5, dot);

    canvas.restore();

    // body (always centered, no wing-flap scale)
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 1), width: 2.5, height: 14),
        body);

    // antennae
    final antPaint = Paint()
      ..color = palette.body
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final pathL = Path()
      ..moveTo(cx - 1, cy - 7)
      ..quadraticBezierTo(cx - 3, cy - 12, cx - 5, cy - 13);
    final pathR = Path()
      ..moveTo(cx + 1, cy - 7)
      ..quadraticBezierTo(cx + 3, cy - 12, cx + 5, cy - 13);
    canvas.drawPath(pathL, antPaint);
    canvas.drawPath(pathR, antPaint);
  }

  @override
  bool shouldRepaint(covariant _ButterflyPainter oldDelegate) =>
      oldDelegate.flap != flap || oldDelegate.palette != palette;
}

class _AmbientButterfly {
  final _BfPalette palette;
  final double phase; // 0..1 offset
  final double cx, cy; // center of orbit
  final double rx, ry; // orbit radii
  final double speed;

  _AmbientButterfly({
    required this.palette,
    required this.phase,
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.speed,
  });

  factory _AmbientButterfly.random(Random rng, int idx) {
    final palettes = _BurstButterfly._palettes;
    return _AmbientButterfly(
      palette: palettes[idx % palettes.length],
      phase: rng.nextDouble(),
      cx: 0.2 + rng.nextDouble() * 0.6,
      cy: 0.7 + rng.nextDouble() * 0.18,
      rx: 0.18 + rng.nextDouble() * 0.18,
      ry: 0.04 + rng.nextDouble() * 0.05,
      speed: 0.8 + rng.nextDouble() * 0.6,
    );
  }

  /// Static placement — chosen once, painted once. No per-frame work.
  Widget buildStatic(double w, double h) {
    // Use phase as a deterministic offset so two butterflies don't overlap.
    final angle = phase * 2 * pi;
    final dx = cx * w + cos(angle) * rx * w;
    final dy = cy * h + sin(angle * 2) * ry * h;
    final rot = sin(angle) * 18;
    return Positioned(
      left: dx - 18,
      top: dy - 13,
      child: Transform.rotate(
        angle: rot * pi / 180,
        child: RepaintBoundary(
          child: SizedBox(
            width: 36,
            height: 30,
            child: CustomPaint(
              painter: _ButterflyPainter(palette: palette, flap: 0.95),
            ),
          ),
        ),
      ),
    );
  }
}
