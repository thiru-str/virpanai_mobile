import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';
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

class Item11 extends StatefulWidget {
  final Content content;

  const Item11({super.key, required this.content});

  @override
  State<Item11> createState() => _Item11State();
}

class _Item11State extends State<Item11> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoStory();
  }

  void _startAutoStory() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.content.layoutData!.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutData = widget.content.layoutData!;
    final currentData = layoutData[_currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 🔹 Background image
            Image.network(
              currentData.image ?? '',
              width: double.infinity,
              height: 500,
              fit: BoxFit.cover,
            ),

            // 🔸 Gradient starts just above button, ends at bottom
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

            // 🔹 Centered Title + Subtitle (above gradient)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentData.title ?? 'SUMMER BREW',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Visibility(
                    visible: false,
                    child: Text(
                      'Zestful. Playful. Delightful.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Bottom Center CTA Button
            Visibility(
              visible: false,
              child: Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Shop',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Bottom Progress Indicator
            Positioned(
              bottom: 6,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(widget.content.layoutData!.length, (index) {
                  final isSeen = index < _currentIndex;
                  final isActive = index == _currentIndex;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSeen
                            ? Colors.white
                            : isActive
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





