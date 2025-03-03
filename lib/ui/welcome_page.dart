import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../utility/page_route_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.welcome_to_store,
                        textAlign: TextAlign.center,
                        style: FontUtils.secondaryFontStyle1(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get_your_product,
                        textAlign: TextAlign.center,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Get Started button
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button tap
                      PageRouteUtils.pushWithSlide(context, const PhoneNumberPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: Text(
                      AppStrings.get_started,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

