import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

class MobileFrameWidget extends StatelessWidget {
  const MobileFrameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            /// Mobile Frame
            SvgPicture.asset(
              AppAssets.mobile_frame,
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              width: 220,
              height: 120,
            ),

            /// Speaker
            Positioned(
              top: 10,
              child: SvgPicture.asset(
                AppAssets.mobile_speaker,
                colorFilter: ColorFilter.mode(
                  AppColors.primary.withOpacity(0.6),
                  BlendMode.srcIn,
                ),
                width: 40,  // reduced
                height: 6,
              ),
            ),

            /// Loop Arrow
            SvgPicture.asset(
              AppAssets.mobile_update,
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              width: 110, // reduced
              height: 45,
            ),

            /// Settings Gear
            SvgPicture.asset(
              AppAssets.mobile_settings,
              colorFilter: ColorFilter.mode(
                AppColors.primary.withOpacity(0.7),
                BlendMode.srcIn,
              ),
              width: 45, // reduced
              height: 15,
            ),
          ],
        ),

        // Horizontal Line (default, not SVG)
        Container(
          height: 1.2,
          width: 100,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

