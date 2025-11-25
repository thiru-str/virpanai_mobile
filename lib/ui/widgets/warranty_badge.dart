import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/utility/app_assets.dart';

class WarrantyBadge extends StatelessWidget {
  final String warrantyText;  // e.g. "1 YEAR", "2 YEARS"
  final double width;
  final double height;

  const WarrantyBadge({
    Key? key,
    required this.warrantyText,
    this.width = 90,
    this.height = 90,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Base SVG
          SvgPicture.asset(
            AppAssets.warranty,
            width: width,
            height: height,
          ),

          /// Positioned warranty text inside white band
          Positioned(
            top: height * 0.26,             // adjust text Y position
            child: Text(
              warrantyText.toUpperCase(),
              style: TextStyle(
                fontSize: width * 0.10,      // responsive text size
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
