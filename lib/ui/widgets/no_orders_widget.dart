import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';

class NoOrdersWidget extends StatelessWidget {
  final String message;
  final String buttonText;
  final String iconPath;
  final VoidCallback onButtonTap;

  const NoOrdersWidget({
    Key? key,
    required this.message,
    required this.buttonText,
    required this.iconPath,
    required this.onButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Section
          Image.asset(
            iconPath,height: 100,width: 100,
          ),
          const SizedBox(height: 16),
          // Message Section
          Text(
            message,
            style: FontUtils.circularStdStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Button Section
          ElevatedButton(
            onPressed: onButtonTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // Background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              buttonText,
              style: FontUtils.circularStdStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
