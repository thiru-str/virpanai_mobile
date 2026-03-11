import 'package:flutter/material.dart';

const Color _kShimmerBaseColor = Color(0xFFE8EAF1);
const Color _kShimmerHighlightColor = Color(0xFFF6F8FC);

class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enabled;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.enabled = true,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - (2.4 * _controller.value), -0.3),
              end: Alignment(1.0 + (2.4 * _controller.value), 0.3),
              colors: [
                _kShimmerBaseColor,
                _kShimmerBaseColor,
                _kShimmerHighlightColor,
                _kShimmerBaseColor,
                _kShimmerBaseColor,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: _kShimmerBaseColor,
        borderRadius: borderRadius,
      ),
    );
  }
}

class AppReveal extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delayStep;
  final Offset beginOffset;

  const AppReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 500),
    this.delayStep = const Duration(milliseconds: 45),
    this.beginOffset = const Offset(0, 0.035),
  });

  @override
  State<AppReveal> createState() => _AppRevealState();
}

class _AppRevealState extends State<AppReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delayStep * widget.index, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : widget.beginOffset,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
