import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';

/// What stands in for a missing picture: the store's logo where the branch
/// bundles one ([AppConfig.placeholderLogo]), otherwise the generic mark.
class NoImageMark extends StatelessWidget {
  /// Keeps CMS previews neutral when they are rendered from a merchant branch.
  static bool debugGeneric = false;
  static bool get branded => AppConfig.placeholderLogo.isNotEmpty && !debugGeneric;

  /// The surface behind a missing picture: a light one, so a logo reads as a
  /// deliberate tile rather than a grey hole.
  static Color get surface => branded ? const Color(0xFFF8F5F0) : AppColors.secondary;

  final double? width;
  final double? height;
  const NoImageMark({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (!branded) return SvgPicture.asset(AppAssets.ic_no_image, width: width, height: height);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120, maxHeight: 120),
      child: Image.asset(AppConfig.placeholderLogo, width: width, height: height, fit: BoxFit.contain),
    );
  }
}

class ImageFallbackWidget extends StatelessWidget {
  final double? h;
  final double? w;
  final BoxFit fit;

  /// With a store logo, cover the slot it sits in rather than a small box in
  /// the middle of it. [w] and [h] still size the generic mark.
  final bool fill;
  const ImageFallbackWidget(
      {super.key, this.h, this.w, this.fit = BoxFit.cover, this.fill = false});

  @override
  Widget build(BuildContext context) {
    final cover = fill && NoImageMark.branded;
    return Container(
      width: cover ? null : w,
      height: cover ? null : h,
      color: NoImageMark.surface,
      alignment: Alignment.center,
      child: NoImageMark.branded
          ? NoImageMark(width: cover ? null : _part(w), height: cover ? null : _part(h))
          : SvgPicture.asset(
              AppAssets.ic_no_image,
              width: (w ??0)* 0.5,
              height: (h ?? 0)* 0.5,
              fit: fit,
            ),
    );
  }

  static double? _part(double? side) =>
      side == null || !side.isFinite ? null : side * 0.6;
}
