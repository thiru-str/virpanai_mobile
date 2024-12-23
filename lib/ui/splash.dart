

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/ui/cash_flow_page.dart';
import 'package:waioz/ui/cash_section_page.dart';
import 'package:waioz/ui/login_page.dart';
import 'package:waioz/ui/main_page.dart';
import 'package:waioz/ui/ongoing_order_page.dart';
import 'package:waioz/ui/payment_flow_widget.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/shared_preferences_util.dart';


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
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('images/ic_storees_splash.png',height: 200,width: 200,)
      ),
    );
  }

  void navToNextPage() async{
    int? branchId = await SharedPreferencesUtil().getInt('branch_id');
    int? userId = await SharedPreferencesUtil().getInt('user_id');
    String? tenantId = await SharedPreferencesUtil().getString('tenant_id');
    Widget nextPage = branchId == null ? const WelcomePage() : userId==null ? LoginScreen(branchId: branchId,tenantId: tenantId!,) : MainScreen();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => nextPage));
      }
    });
  }

}


