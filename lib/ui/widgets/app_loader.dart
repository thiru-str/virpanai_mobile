import 'dart:math';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

// Maligai items — font size tuned per emoji to match visual weight
const _emojis = [
  ('🌿', 20.0), // curry leaf — visually wide, keep smaller
  ('🌾', 26.0), // rice & grains
  ('🌶️', 30.0), // chilli — narrow shape, needs larger
  ('🧅', 26.0), // onion & vegetables
  ('🍪', 26.0), // biscuits & snacks
  ('🧼', 26.0), // soap & household
];

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with TickerProviderStateMixin {
  late final AnimationController _orbitCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _fadeCtrl;

  // Stored to avoid per-frame allocation
  late final Animation<double> _pulseAnim;
  final _trackPainter = const _OrbitTrackPainter();

  @override
  void initState() {
    super.initState();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOut,
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbit track + emoji items
              AnimatedBuilder(
                animation: _orbitCtrl,
                builder: (_, __) {
                  final orbitAngle = _orbitCtrl.value * 2 * pi;
                  return CustomPaint(
                    size: const Size(210, 210),
                    painter: _trackPainter,
                    child: SizedBox(
                      width: 210,
                      height: 210,
                      child: Stack(
                        children: List.generate(_emojis.length, (i) {
                          const orbitR = 76.0;
                          const hitSize = 32.0;
                          final itemSize = _emojis[i].$2;
                          final theta =
                              orbitAngle + (i / _emojis.length) * 2 * pi;
                          final x = 105 + orbitR * cos(theta) - hitSize / 2;
                          final y = 105 + orbitR * sin(theta) - hitSize / 2;

                          // Depth: back (sin=-1) → front (sin=+1)
                          final depth = (sin(theta) + 1) / 2;
                          final scale = 0.70 + depth * 0.50; // 0.70 → 1.20
                          final opacity = 0.35 + depth * 0.65; // 0.35 → 1.00

                          return Positioned(
                            left: x,
                            top: y,
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: SizedBox(
                                  width: hitSize,
                                  height: hitSize,
                                  child: Center(
                                    child: Text(
                                      _emojis[i].$1,
                                      style: TextStyle(
                                        fontSize: itemSize,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),

              // Pulsing green glow behind mascot
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) {
                  final pulse = _pulseAnim.value;
                  return Container(
                    width: 90 + pulse * 8,
                    height: 90 + pulse * 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.14 + pulse * 0.14),
                          blurRadius: 22 + pulse * 14,
                          spreadRadius: 2 + pulse * 4,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Mascot
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(AppAssets.app_icon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitTrackPainter extends CustomPainter {
  const _OrbitTrackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      76,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_OrbitTrackPainter old) => false;
}
