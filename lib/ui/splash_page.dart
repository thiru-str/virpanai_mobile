

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../utility/shared_preferences_util.dart';


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Define animation (zoom in)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start the animation
    _controller.forward();

    // Navigate to next page after animation
    navToNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset(
          AppAssets.app_icon,
        ),
      ),
    );
  }

  void navToNextPage() async {
    String? token = await SharedPreferencesUtil().getString('token');
    Widget nextPage = token == null ? WelcomePage() : const BottomNavPage();

    // Delay navigation until the animation completes
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      /*Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
        ),
      );*/
      PageRouteUtils.pushWithZoom(context, nextPage);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



