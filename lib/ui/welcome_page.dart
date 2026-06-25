import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../utility/page_route_utils.dart';

enum _NutKind { cashew, almond, walnut, pistachio, raisin }

class _FloatItem {
  final _NutKind kind;
  final double baseX;
  final double drift;
  final double phase;
  const _FloatItem(this.kind, this.baseX, this.drift, this.phase);
}

const _floatItems = [
  _FloatItem(_NutKind.cashew,    0.08,  0.04, 0.00),
  _FloatItem(_NutKind.almond,    0.25, -0.05, 0.11),
  _FloatItem(_NutKind.walnut,    0.44,  0.05, 0.22),
  _FloatItem(_NutKind.pistachio, 0.62, -0.04, 0.33),
  _FloatItem(_NutKind.cashew,    0.80,  0.05, 0.44),
  _FloatItem(_NutKind.raisin,    0.92, -0.04, 0.55),
  _FloatItem(_NutKind.almond,    0.16,  0.05, 0.66),
  _FloatItem(_NutKind.cashew,    0.50, -0.05, 0.77),
  _FloatItem(_NutKind.pistachio, 0.72,  0.04, 0.88),
];

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _btnCtrl;

  late final Animation<double> _iconScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _arrowNudge;
  late final Animation<double> _btnScale;

  static const _primary = Color(0xFFF32F38);
  static const _deep   = Color(0xFF9A0008);
  static const _light  = Color(0xFFFF5A60);

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();

    _iconScale = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.60, curve: Curves.elasticOut));

    _contentFade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut));

    _contentSlide = Tween<Offset>(
            begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.45, 1.0, curve: Curves.easeOut)));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 7000))
      ..repeat();

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();

    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();

    _arrowNudge = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 7.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 28),
      TweenSequenceItem(
          tween: Tween(begin: 7.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 28),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 44),
    ]).animate(_btnCtrl);

    _btnScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.04)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 28),
      TweenSequenceItem(
          tween: Tween(begin: 1.04, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 28),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 44),
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

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Stack(
          children: [
            // ── Full-screen red radial gradient ─────────────────────────
            Positioned.fill(
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 1.3,
                    colors: [_light, _primary, _deep],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // ── Cashew crescent pattern texture ─────────────────────────
            const Positioned.fill(
              child: CustomPaint(painter: _CashewPainter()),
            ),

            // ── Floating dry-fruit emojis ────────────────────────────────
            AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, __) => SizedBox.expand(
                child: Stack(
                  children: List.generate(_floatItems.length, (i) {
                    final item = _floatItems[i];
                    final t = (_floatCtrl.value + item.phase) % 1.0;
                    final y = (1.0 - t) * size.height - 20;
                    final x = item.baseX * size.width +
                        sin(t * 2 * pi) * item.drift * size.width;
                    final opacity = (t < 0.07
                            ? t / 0.07
                            : t > 0.88
                                ? (1.0 - t) / 0.12
                                : 1.0) *
                        0.90;
                    return Positioned(
                      left: x,
                      top: y,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: CustomPaint(
                            painter: _NutIconPainter(item.kind),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Content: icon + text + CTA centered on screen ───────────
            SafeArea(
              child: SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    children: [
                      const Spacer(flex: 10),

                      // Pulse rings + squircle icon
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _ringCtrl,
                              builder: (_, __) => CustomPaint(
                                size: const Size(220, 220),
                                painter: _RingPainter(_ringCtrl.value),
                              ),
                            ),
                            ScaleTransition(
                              scale: _iconScale,
                              child: Container(
                                width: 152,
                                height: 152,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(34),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _deep.withValues(alpha: 0.45),
                                      blurRadius: 48,
                                      offset: const Offset(0, 16),
                                    ),
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
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

                      const Spacer(flex: 6),

                      // Store name — white, bold
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          AppStrings.welcome_to_store,
                          textAlign: TextAlign.center,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ).copyWith(height: 1.1, letterSpacing: -0.5),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline — white at 80% opacity
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          AppStrings.get_your_product,
                          textAlign: TextAlign.center,
                          style: FontUtils.secondaryFontStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.80),
                          ).copyWith(height: 1.55),
                        ),
                      ),

                      const Spacer(flex: 8),

                      // CTA — white pill button with red text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: AnimatedBuilder(
                          animation: _btnCtrl,
                          builder: (_, __) => Transform.scale(
                            scale: _btnScale.value,
                            child: SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: () =>
                                    PageRouteUtils.pushWithSlide(
                                        context, const PhoneNumberPage()),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                  foregroundColor:
                                      WidgetStateProperty.all(_primary),
                                  overlayColor: WidgetStateProperty.all(
                                      _primary.withValues(alpha: 0.08)),
                                  elevation: WidgetStateProperty.all(0),
                                  shadowColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.get_started,
                                      style: FontUtils.primaryFontStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: _primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Transform.translate(
                                      offset: Offset(_arrowNudge.value, 0),
                                      child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: _primary,
                                          size: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 12),
                    ],
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

// White rings pulsing outward from the icon
class _RingPainter extends CustomPainter {
  final double t;
  const _RingPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final radius = 78.0 + phase * 32.0;
      final opacity = (1 - phase) * 0.22;
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

// Cashew crescent motif — kidney silhouette scattered as textile-style texture
class _CashewPainter extends CustomPainter {
  const _CashewPainter();

  static const _angles = [
    0.0, 0.70, -0.55, 1.30, -0.90, 0.35,
    -1.20, 1.00, 0.50, -0.30, 1.55, -0.65,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const spacing = 50.0;
    int idx = 0;
    int row = 0;

    for (double y = spacing * 0.5; y < size.height + spacing; y += spacing) {
      final xOff = row.isOdd ? spacing * 0.5 : 0.0;
      for (double x = xOff; x < size.width + spacing; x += spacing) {
        _drawCashew(canvas, x, y, _angles[idx % _angles.length], paint);
        idx++;
      }
      row++;
    }
  }

  void _drawCashew(
      Canvas canvas, double cx, double cy, double angle, Paint paint) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(-3.0, -8.0)
      ..cubicTo(8.0, -9.5, 12.0, -1.0, 9.0, 7.0)
      ..cubicTo(7.5, 10.0, 3.5, 10.5, 1.0, 8.5)
      ..cubicTo(-3.5, 5.5, -4.5, -3.5, -3.0, -8.0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CashewPainter old) => false;
}

// Flat vector nut icons — drawn with Canvas so each shape is instantly recognisable
class _NutIconPainter extends CustomPainter {
  final _NutKind kind;
  _NutIconPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case _NutKind.cashew:
        _drawCashew(canvas, size);
      case _NutKind.almond:
        _drawAlmond(canvas, size);
      case _NutKind.walnut:
        _drawWalnut(canvas, size);
      case _NutKind.pistachio:
        _drawPistachio(canvas, size);
      case _NutKind.raisin:
        _drawRaisin(canvas, size);
    }
  }

  // Golden filled crescent — same kidney silhouette as the background pattern
  void _drawCashew(Canvas canvas, Size size) {
    canvas.save();
    // Translate so the natural centre of the path lands at canvas centre
    canvas.translate(size.width * 0.355, size.height * 0.482);
    canvas.scale(1.4, 1.4);
    final path = Path()
      ..moveTo(-3.0, -8.0)
      ..cubicTo(8.0, -9.5, 12.0, -1.0, 9.0, 7.0)
      ..cubicTo(7.5, 10.0, 3.5, 10.5, 1.0, 8.5)
      ..cubicTo(-3.5, 5.5, -4.5, -3.5, -3.0, -8.0)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFD4A017));
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF7A5800)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
    canvas.restore();
  }

  // Almond — elongated pointed lens oval, tan/brown
  void _drawAlmond(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final path = Path()
      ..moveTo(0, -13)
      ..cubicTo(7, -10, 7, 10, 0, 13)
      ..cubicTo(-7, 10, -7, -10, 0, -13)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFC49A6C));
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF6E4020)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    // Centre ridge line characteristic of almonds
    canvas.drawLine(
        const Offset(0, -9),
        const Offset(0, 9),
        Paint()
          ..color = const Color(0xFF6E4020)
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round);
    canvas.restore();
  }

  // Walnut — brown circle with vertical crack and curved suture arcs
  void _drawWalnut(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    const r = 13.0;
    canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFF7C4A1E));
    // Vertical crack
    canvas.drawLine(
        const Offset(0, -r * 0.85),
        const Offset(0, r * 0.85),
        Paint()
          ..color = const Color(0xFF3A1A00)
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round);
    // Horizontal suture arcs
    for (final dy in [-r * 0.3, r * 0.25]) {
      canvas.drawArc(
          Rect.fromCenter(
              center: Offset(0, dy), width: r * 1.3, height: r * 0.6),
          0.2,
          pi * 0.8,
          false,
          Paint()
            ..color = const Color(0xFF3A1A00)
            ..strokeWidth = 0.9
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }
    canvas.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..color = const Color(0xFF3A1A00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1);
    canvas.restore();
  }

  // Pistachio — cream shell with green kernel showing through the split top
  void _drawPistachio(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    const rx = 7.0;
    const ry = 12.0;
    // Cream shell
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()..color = const Color(0xFFE8D5A0));
    // Green kernel showing in upper half through the split
    canvas.save();
    canvas.clipRect(
        Rect.fromLTWH(-rx - 1, -ry - 1, (rx + 1) * 2, ry + 0.5));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero, width: rx * 1.8, height: ry * 1.4),
        Paint()..color = const Color(0xFF6FA830));
    canvas.restore();
    // Shell outline
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()
          ..color = const Color(0xFF9A7830)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    // Split crack line at equator
    canvas.drawLine(
        Offset(-rx + 1, -0.5),
        Offset(rx - 1, -0.5),
        Paint()
          ..color = const Color(0xFF5A3A00)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round);
    canvas.restore();
  }

  // Raisin (dried grape) — small dark purple oval with wrinkle arcs
  void _drawRaisin(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 2);
    const rx = 7.0;
    const ry = 9.0;
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()..color = const Color(0xFF6B1F6B));
    for (final dy in [-ry * 0.3, ry * 0.3]) {
      canvas.drawArc(
          Rect.fromCenter(
              center: Offset(0, dy), width: rx * 1.2, height: ry * 0.5),
          0,
          pi,
          false,
          Paint()
            ..color = const Color(0xFF3A0A3A)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke);
    }
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()
          ..color = const Color(0xFF3A0A3A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_NutIconPainter old) => old.kind != kind;
}
