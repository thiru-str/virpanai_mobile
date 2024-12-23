

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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


    /*Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => nextPage));
      }
    });*/
  }

}


