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
        // Mobile UI (Stacked SVGs)
        Stack(
          alignment: Alignment.center,
          children: [
            /// Mobile Frame
            SvgPicture.asset(
              AppAssets.mobile_frame,
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              width: 300,
              height: 190,
            ),

            /// Speaker
            Positioned(
              top: 15,
              child: SvgPicture.asset(
                AppAssets.mobile_speaker,
                colorFilter: ColorFilter.mode(
                  AppColors.primary.withOpacity(0.6),
                  BlendMode.srcIn,
                ),
                width: 60,
                height: 8,
              ),
            ),

            /// Loop Arrow
            SvgPicture.asset(
              AppAssets.mobile_update,
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              width: 150,
              height: 75,
            ),

            /// Settings Gear
            SvgPicture.asset(
              AppAssets.mobile_settings,
              colorFilter: ColorFilter.mode(
                AppColors.primary.withOpacity(0.7),
                BlendMode.srcIn,
              ),
              width: 60,
              height: 23,
            ),
          ],
        ),


        // Horizontal Line (default, not SVG)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
            height: 1.5,
            width: double.infinity,
            color: AppColors.primary, // default line color
          ),
        ),
      ],
    );
  }
}
