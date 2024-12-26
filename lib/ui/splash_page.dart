

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../utility/shared_preferences_util.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    navToNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.primary,
      body: Center(
        child: SvgPicture.asset(AppAssets.app_logo,height: 120,width: 158)
      ),
    );
  }

  void navToNextPage() async{
    String? token = await SharedPreferencesUtil().getString('token');
    Widget nextPage = token == null ? WelcomePage() : const BottomNavPage();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        PageRouteUtils.pushReplacement(context, nextPage);
      }
    });
  }

}


