import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../utility/page_route_utils.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the status bar
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Transparent status bar
          statusBarIconBrightness: Brightness.dark, // For dark icons
          statusBarBrightness: Brightness.light, // For light icons (iOS)
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                AppAssets.welcome_bg,
                fit: BoxFit.cover,
              ),
            ),
            // Soft gradient scrim so text/CTA stay legible over any image
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.85),
                      Colors.white,
                    ],
                    stops: const [0.45, 0.78, 1.0],
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Welcome text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.welcome_to_store,
                          textAlign: TextAlign.center,
                          style: UiTypography.cardTitle().copyWith(
                            fontSize: 32,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.get_your_product,
                          textAlign: TextAlign.center,
                          style: FontUtils.secondaryFontStyle(
                            fontSize: 16,
                            color: AppColors.textColor50,
                          ).copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Get Started button (single dominant primary CTA)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 28,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button tap
                        PageRouteUtils.pushWithSlide(
                            context, const PhoneNumberPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Button color
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.get_started,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
