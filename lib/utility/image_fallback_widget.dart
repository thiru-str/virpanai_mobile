import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

class ImageFallbackWidget extends StatelessWidget {
  final double? h;
  final double? w;
  final BoxFit fit;
  const ImageFallbackWidget(
      {super.key, this.h, this.w, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      color: AppColors.secondary,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.ic_no_image,
        width: (w ??0)* 0.5,
        height: (h ?? 0)* 0.5,
        fit: fit,
      ),
    );
  }
}
