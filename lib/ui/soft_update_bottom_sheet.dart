import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/mobile_frame_widget.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

class SoftUpdateBottomSheet extends StatelessWidget {
  final VoidCallback onUpdateNow;
  final VoidCallback onContinue;

  const SoftUpdateBottomSheet({
    super.key,
    required this.onUpdateNow,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Gradient box containing MobileFrameWidget
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: MobileFrameWidget(), // smaller now
            ),
          ),


          const SizedBox(height: 28), // 👈 spacing between mobile frame and texts

          /// Small header
          Text(
            "NEW UPDATE IS AVAILABLE",
            style: FontUtils.primaryFontStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          /// Bold title
          Text(
            "Update To The Latest\nVersion Now!",
            textAlign: TextAlign.center,
            style: UiTypography.cardTitle().copyWith(
              fontSize: 20,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          /// Description
          Text(
            "New features added and dispute bugs fixed for a smoother experience",
            textAlign: TextAlign.center,
            style: FontUtils.secondaryFontStyle(
              fontSize: 14,
              color: AppColors.textColor50,
            ).copyWith(height: 1.5),
          ),
          const SizedBox(height: 28),

          /// Update Now Button
          SizedBox(
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
          const SizedBox(height: 12),

          /// Continue button (text only)
          GestureDetector(
            onTap: onContinue,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Continue to app",
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

