import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/redirect_utils.dart';

import '../../../utility/app_colors.dart';

class Slider1 extends StatefulWidget {
  final Content content;

  const Slider1({super.key, required this.content});

  @override
  State<Slider1> createState() => _Slider1State();
}

class _Slider1State extends State<Slider1> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextSlide();
        }
      });

    _controller.forward();
  }

  void _nextSlide() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.content.layoutData!.length;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutData = widget.content.layoutData!;
    final currentData = layoutData[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: (widget.content.layoutTitle ?? '').isNotEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.content.layoutTitle ?? '',
                  style: FontUtils.primaryFontStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.content.layoutSubTitle ?? '',
                  style: FontUtils.secondaryFontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: () {
              RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: widget.content.layoutOption ?? "",
                layoutData: currentData,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    height: 500,
                    child: Image.network(
                      currentData.image ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, url, error) =>
                         const ImageFallbackWidget(h: 220, fit: BoxFit.contain),
                    ),
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
                            Colors.black.withOpacity(0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Title section
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
                          children: List.generate(layoutData.length, (index) {
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
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
                                      borderRadius: BorderRadius.circular(4),
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
      ],
    );
  }
}
