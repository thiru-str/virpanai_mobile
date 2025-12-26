import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

class WarrantyInfoCard extends StatelessWidget {
  final String description;
  final bool isGwmWarranty;

  const WarrantyInfoCard({
    Key? key,
    required this.description,
    required this.isGwmWarranty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DottedBorder(
        color: AppColors.primary.withOpacity(0.5),
        strokeWidth: 1.5,
        dashPattern: const [6, 6], // dot-gap pattern
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6FFF7), // light green background
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// SVG Badge
              SvgPicture.asset(
                isGwmWarranty?AppAssets.ic_gwm_warranty:AppAssets.ic_warranty,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),

              const SizedBox(width: 16),

              /// Description text (vertically centered)
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
