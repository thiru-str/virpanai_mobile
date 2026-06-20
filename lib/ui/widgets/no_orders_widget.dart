import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';

class NoOrdersWidget extends StatelessWidget {
  final String message;
  final String buttonText;
  final String iconPath;
  final VoidCallback onButtonTap;
  final bool showExplore;

  const NoOrdersWidget({
    Key? key,
    required this.message,
    required this.buttonText,
    required this.iconPath,
    required this.onButtonTap,
    this.showExplore = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Section
            Image.asset(
              iconPath,
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            // Message Section
            Text(
              message,
              textAlign: TextAlign.center,
              style: UiTypography.cardTitle(
                color: Colors.black87,
              ).copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // Button Section
            Visibility(
              visible: showExplore,
              child: ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Background color
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: Text(
                  buttonText,
                  style: UiTypography.cardAction(
                    color: Colors.white,
                  ).copyWith(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
