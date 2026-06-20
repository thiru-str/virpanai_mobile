import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../utility/page_route_utils.dart';

// Fixed-position grocery emojis that drift upward through the green section.
// Phase offsets stagger them so they don't all start at the same point.
class _FloatItem {
  final String emoji;
  final double baseX; // 0.0–1.0 of screen width
  final double drift; // horizontal S-curve amplitude (fraction of width)
  final double phase; // start offset in [0, 1)
  const _FloatItem(this.emoji, this.baseX, this.drift, this.phase);
}

const _floatItems = [
  _FloatItem('🌿', 0.06, 0.05, 0.00),  // curry leaf
  _FloatItem('🧄', 0.22, -0.04, 0.09), // garlic
  _FloatItem('🌾', 0.38, 0.06, 0.18),  // rice & grains
  _FloatItem('🌶️', 0.55, -0.05, 0.27), // chilli
  _FloatItem('🥥', 0.72, 0.04, 0.36),  // coconut
  _FloatItem('🧅', 0.88, -0.06, 0.45), // onion
  _FloatItem('🍅', 0.14, 0.05, 0.54),  // tomato
  _FloatItem('🍋', 0.46, -0.04, 0.63), // lemon
  _FloatItem('🫘', 0.64, 0.05, 0.72),  // lentils / dal
  _FloatItem('🫚', 0.82, -0.04, 0.81), // cooking oil
  _FloatItem('🥜', 0.30, 0.06, 0.90),  // groundnuts
];

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;      // one-shot entrance  900ms
  late final AnimationController _floatCtrl; // emoji drift loop  6000ms
  late final AnimationController _ringCtrl;  // pulse rings loop  2200ms
  late final AnimationController _btnCtrl;   // button nudge loop 2400ms

  late final Animation<double> _iconScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  // Arrow nudges right then returns; rests for ~44% of cycle
  late final Animation<double> _arrowNudge;
  // Green glow synced with the nudge
  late final Animation<double> _btnGlow;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _iconScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );
    _contentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 28% nudge out → 28% return → 44% rest
    final _nudgeSeq = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 6.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 6.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 44),
    ]);
    _arrowNudge = _nudgeSeq.animate(_btnCtrl);

    _btnGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 44),
    ]).animate(_btnCtrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _floatCtrl.dispose();
    _ringCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final greenH = size.height * 0.58;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Column(
          children: [
            // ── Green hero section ──────────────────────────────────────
            Expanded(
              flex: 58,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Radial green gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.1,
                          colors: [
                            Color(0xFF56C254),
                            Color(0xFF3EAA3C),
                            Color(0xFF2A7D29),
                          ],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Mango paisley (maanga motif) — iconic Tamil textile pattern
                  Positioned.fill(
                    child: CustomPaint(painter: const _MangoPainter()),
                  ),

                  // Floating grocery emojis drifting upward
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) {
                      return SizedBox.expand(
                        child: Stack(
                          children: List.generate(_floatItems.length, (i) {
                            final item = _floatItems[i];
                            final t = (_floatCtrl.value + item.phase) % 1.0;
                            final y = (1.0 - t) * greenH - 20;
                            final x = item.baseX * size.width +
                                sin(t * 2 * pi) * item.drift * size.width;
                            final opacity = (t < 0.08
                                    ? t / 0.08
                                    : t > 0.85
                                        ? (1.0 - t) / 0.15
                                        : 1.0) *
                                0.42;
                            return Positioned(
                              left: x,
                              top: y,
                              child: Opacity(
                                opacity: opacity.clamp(0.0, 1.0),
                                child: Text(
                                  item.emoji,
                                  style: const TextStyle(
                                      fontSize: 26, height: 1),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),

                  // Pulse rings + icon — layered in their own centred stack
                  Align(
                    alignment: const Alignment(0, 0.05),
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Expanding white pulse rings
                          AnimatedBuilder(
                            animation: _ringCtrl,
                            builder: (_, __) => CustomPaint(
                              size: const Size(220, 220),
                              painter: _RingPainter(_ringCtrl.value),
                            ),
                          ),

                          // App icon — squircle container (matches badge shape)
                          ScaleTransition(
                            scale: _iconScale,
                            child: Container(
                              width: 148,
                              height: 148,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    blurRadius: 40,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.30),
                                    blurRadius: 20,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.asset(
                                  AppAssets.app_icon,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Arch wave — organic boundary to white section
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      size: Size(size.width, 72),
                      painter: const _ArchPainter(),
                    ),
                  ),
                ],
              ),
            ),

            // ── White content section ───────────────────────────────────
            Expanded(
              flex: 42,
              child: SafeArea(
                top: false,
                child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.welcome_to_store,
                            textAlign: TextAlign.center,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A1A),
                            ).copyWith(height: 1.15, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            AppStrings.get_your_product,
                            textAlign: TextAlign.center,
                            style: FontUtils.secondaryFontStyle(
                              fontSize: 15,
                              color: const Color(0xFF888888),
                            ).copyWith(height: 1.55),
                          ),

                          const SizedBox(height: 28),

                          // CTA — animated nudge + glow
                          AnimatedBuilder(
                            animation: _btnCtrl,
                            builder: (_, __) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3EAA3C).withValues(
                                        alpha: _btnGlow.value * 0.45),
                                    blurRadius: 12 + _btnGlow.value * 10,
                                    spreadRadius: _btnGlow.value * 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => PageRouteUtils.pushWithSlide(
                                      context, const PhoneNumberPage()),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color(0xFF3EAA3C)),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.white.withValues(alpha: 0.12)),
                                    elevation: WidgetStateProperty.all(0),
                                    shadowColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppStrings.get_started,
                                        style: FontUtils.primaryFontStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Transform.translate(
                                        offset:
                                            Offset(_arrowNudge.value, 0),
                                        child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3 staggered white rings that expand outward from the icon and fade out
class _RingPainter extends CustomPainter {
  final double t;
  const _RingPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final radius = 74.0 + phase * 36.0; // 74 → 110
      final opacity = (1 - phase) * 0.20;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

// Mango paisley (maanga motif) — the teardrop shape woven into Tamil silks,
// sarees, and temple textiles for centuries. Scattered at varied angles.
class _MangoPainter extends CustomPainter {
  const _MangoPainter();

  static const _angles = [
    0.0, 0.65, -0.50, 1.20, -0.80, 0.30, -1.25, 0.95, 0.45, -0.25, 1.50, -0.60,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    const spacing = 46.0;
    int idx = 0;
    int row = 0;

    for (double y = spacing * 0.5; y < size.height + spacing; y += spacing) {
      final xOff = row.isOdd ? spacing * 0.5 : 0.0;
      for (double x = xOff; x < size.width + spacing; x += spacing) {
        _drawMango(canvas, x, y, _angles[idx % _angles.length], paint);
        idx++;
      }
      row++;
    }
  }

  void _drawMango(Canvas canvas, double cx, double cy, double angle, Paint paint) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    const r = 5.5;     // base-circle radius
    const tipY = -12.0; // distance from centre to pointed tip

    // Teardrop outline: two bezier curves up to the tip + bottom semicircle
    final path = Path()
      ..moveTo(0, tipY)
      ..cubicTo(r, tipY + (0 - tipY) * 0.32, r, -r * 0.38, r, 0)
      ..arcToPoint(Offset(-r, 0),
          radius: const Radius.circular(r), clockwise: true)
      ..cubicTo(-r, -r * 0.38, -r, tipY + (0 - tipY) * 0.32, 0, tipY)
      ..close();
    canvas.drawPath(path, paint);

    // Traditional inner dot — appears in authentic maanga motif embroidery
    canvas.drawCircle(
      Offset(0, tipY * 0.42),
      1.3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MangoPainter old) => false;
}

// Smooth concave arch separating green and white sections
class _ArchPainter extends CustomPainter {
  const _ArchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ArchPainter old) => false;
}
