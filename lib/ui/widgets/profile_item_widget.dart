import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class ProfileItemWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ProfileItemWidget({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary,width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Text(
              title,
              style: FontUtils.primaryFontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            // Forward Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.profileItemArrowColor,
            ),
          ],
        ),
      ),
    );
  }
}
