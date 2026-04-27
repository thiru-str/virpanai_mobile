import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';

import 'mobile_frame_widget.dart';

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
    return SafeArea(
      child: Container(
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            /// Bold title
            const Text(
              "Update To The Latest\nVersion Now!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            /// Description
            const Text(
              "New features added and dispute bugs fixed for a smoother experience",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            /// Update Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: onUpdateNow,
                child: const Text(
                  "Update now",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Continue button (text only)
            GestureDetector(
              onTap: onContinue,
              child: const Text(
                "Continue to app",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

