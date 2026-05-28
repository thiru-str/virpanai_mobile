import 'package:flutter/material.dart';
import 'package:waioz/utility/app_assets.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Image.asset(
        AppAssets.app_loader,
        width: 170,
        height: 170,
        errorBuilder: (_, __, ___) => Image.asset(
          AppAssets.app_icon,
          width: 170,
          height: 170,
        ),
      ),
    );
  }
}
