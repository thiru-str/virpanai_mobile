import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_colors.dart';

class SearchBarWithRollingHint extends StatefulWidget {
  final VoidCallback onTap;

  const SearchBarWithRollingHint({super.key, required this.onTap});

  @override
  State<SearchBarWithRollingHint> createState() => _SearchBarWithRollingHintState();
}

class _SearchBarWithRollingHintState extends State<SearchBarWithRollingHint> with TickerProviderStateMixin {
  final List<String> _hints = [
    'mobiles',
    'gadgets',
    'earbuds',
    'electronics',
    'temper',
    'cables',
    'cases and accessories',
  ];

  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startCycling();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _startCycling() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;

      _controller.reset(); // Reset for each new slide
      setState(() {
        _currentIndex = (_currentIndex + 1) % _hints.length;
      });
      _controller.forward(); // Animate the new text sliding in
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primary.withAlpha(50)),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRect(
                child: Row(
                  children: [
                    Text(
                      'Search',
                      style: FontUtils.primaryFontStyle(color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 4,),
                    SlideTransition(
                      position: _animation,
                      child: Row(
                        children: [
                          Text(
                            _hints[_currentIndex],
                            key: ValueKey(_hints[_currentIndex]),
                            style: FontUtils.primaryFontStyle(color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





