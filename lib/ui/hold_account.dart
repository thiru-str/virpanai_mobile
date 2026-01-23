import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';

class HoldAccountDialog extends StatelessWidget {
  final VoidCallback onJoin;
  final bool loading;

  const HoldAccountDialog({
    super.key,
    required this.onJoin,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Icon
            SvgPicture.asset(
              AppAssets.ic_lock,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            // 🔹 Title
            const Text(
              'Account is on Hold',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D3916),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your account is put on hold. Please contact GoWelMart Admin to continue',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),


            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: loading? Center(child: CircularProgressIndicator(color: AppColors.primary,),): ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Ok',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
