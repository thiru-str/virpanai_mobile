import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/mobile_frame_widget.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

class ForceUpdateScreen extends StatelessWidget {
  final VoidCallback onUpdateNow;

  const ForceUpdateScreen({
    super.key,
    required this.onUpdateNow,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Gradient section (only for illustration)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        Colors.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const MobileFrameWidget(),
                ),

                const SizedBox(height: 32),

                /// Title (now on pure white background)
                Text(
                  "Update To The Latest Version Now!",
                  textAlign: TextAlign.center,
                  style: UiTypography.cardTitle().copyWith(
                    fontSize: 20,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 16),

                /// Description (pure white background)
                Text(
                  "A brand new version of the ${AppConfig.appName} app is available in the App Store. "
                      "Please update your app to use all of our amazing features.",
                  textAlign: TextAlign.center,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 14,
                    color: AppColors.textColor50,
                  ).copyWith(height: 1.5),
                ),

                const SizedBox(height: 84),

                /// Update Now Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: onUpdateNow,
                      child: Text(
                        "Update now",
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




