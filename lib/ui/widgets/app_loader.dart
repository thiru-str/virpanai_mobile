import 'dart:math';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

// Maligai items — font size tuned per emoji to match visual weight
const _emojis = [
  ('🍜', 26.0), // instant foods — noodles
  ('🍚', 26.0), // rice, oils & masala
  ('🥤', 30.0), // tall narrow cup — needs larger
  ('🍪', 26.0), // circular — balanced
  ('🧴', 30.0), // tall narrow bottle — needs larger
  ('☕', 28.0), // cup — slightly narrow
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

                          return Positioned(
                            left: x,
                            top: y,
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
