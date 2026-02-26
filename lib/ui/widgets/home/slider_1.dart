import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_assets.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';

class Slider1 extends StatefulWidget {
  final Content content;

  const Slider1({super.key, required this.content});

  @override
  State<Slider1> createState() => _Slider1State();
}

class _Slider1State extends State<Slider1> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  static const _slideDuration = Duration(seconds: 5);
  static const _swipeVelocityThreshold = 300; // px/s

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _nextSlide();
      });
    _controller.forward();
  }

  void _goTo(int index) {
    if (!mounted) return;
    final len = widget.content.layoutData!.length;
    setState(() => _currentIndex = (index % len + len) % len);
    _controller.forward(from: 0);
  }

  void _nextSlide() => _goTo(_currentIndex + 1);
  void _prevSlide() => _goTo(_currentIndex - 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutData = widget.content.layoutData!;
    if (layoutData.isEmpty) return const SizedBox.shrink();
    final currentData = layoutData[_currentIndex];
    final backgroundDecoration = AppUtils.buildLayoutBackground(widget.content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.content.layoutTitle?.isNotEmpty == true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content.layoutTitle ?? '',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      widget.content.layoutSubTitle ?? '',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: widget.content.layoutOption!,
                  layoutData: currentData,
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    behavior: HitTestBehavior
                        .deferToChild, // let child taps (redirection) work
                    // Pause only when a horizontal drag actually starts
                    onHorizontalDragStart: (_) {
                      if (_controller.isAnimating) _controller.stop();
                    },
                    onHorizontalDragEnd: (details) {
                      final v = details.primaryVelocity ?? 0.0;
                      if (v.abs() > _swipeVelocityThreshold) {
                        if (v > 0) {
                          _prevSlide(); // swipe right → previous
                        } else {
                          _nextSlide(); // swipe left → next
                        }
                      } else {
                        // small flicks: do nothing, just resume
                        if (!_controller.isAnimating) _controller.forward();
                      }
                    },

                    // (Optional) allow long-press to pause/resume without interfering with taps
                    onLongPressStart: (_) {
                      if (_controller.isAnimating) _controller.stop();
                    },
                    onLongPressEnd: (_) {
                      if (!_controller.isAnimating) _controller.forward();
                    },

                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: currentData.image ?? '',
                          width: MediaQuery.of(context).size.width,
                          height: 500,
                          fit: BoxFit.cover,
                          errorWidget: (context, _, __) => _fallbackWidget(),
                        ),

                        // Bottom gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                        // Title section (your tap/redirection can be on this or another child)
                        Positioned(
                          bottom: 100,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                currentData.title ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.yellow,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Progress bar
                        Positioned(
                          bottom: 6,
                          left: 16,
                          right: 16,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Row(
                                children:
                                    List.generate(layoutData.length, (index) {
                                  double value;
                                  if (index < _currentIndex) {
                                    value = 1.0;
                                  } else if (index == _currentIndex) {
                                    value = _controller.value;
                                  } else {
                                    value = 0.0;
                                  }

                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ],
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

Widget _fallbackWidget() {
  return Container(
    height: 500,
    color: AppColors.secondary,
    alignment: Alignment.center,
    child: SvgPicture.asset(
      AppAssets.ic_no_image,
      height: 500 * 0.5,
    ),
  );
}
