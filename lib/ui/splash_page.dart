

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/push_notification_service.dart';
import '../utility/app_strings.dart';
import '../utility/font_utils.dart';
import '../utility/shared_preferences_util.dart';


import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  final bool skipLogin;
  const SplashPage({super.key,this.skipLogin = false});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await PushNotificationService().initialize(context);
    });

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF124B5C), // dark blue
              Color(0xFF63C132), // green
            ],
          ),
        ),
        child: Center(
          child: SvgPicture.asset(AppAssets.app_logo),
        ),
      ),
    );
  }

  void navToNextPage() async {
    String? token = await SharedPreferencesUtil().getString('token');
    Widget nextPage = token == null ? widget.skipLogin ? const BottomNavPage():  WelcomePage() : const BottomNavPage();

    // Delay navigation until the animation completes
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      PageRouteUtils.pushWithZoom(context, nextPage);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



