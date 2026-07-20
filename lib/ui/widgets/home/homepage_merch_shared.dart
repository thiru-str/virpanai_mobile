import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';

String merchImage(LayoutDatum data) {
  return data.image ?? data.productData?.image ?? '';
}

/// Renders a merchant image from a resolved [url], falling back to
/// [ImageFallbackWidget] when the url is empty or fails to load.
/// Mirrors the CachedNetworkImage usage in [HomeMerchCompactCard].
Widget merchImageOrFallback(
  String url, {
  BoxFit fit = BoxFit.cover,
  BoxFit? fallbackFit,
  double? width,
  double? height,
}) {
  ImageFallbackWidget fallback() =>
      ImageFallbackWidget(h: height, w: width, fit: fallbackFit ?? fit);
  if (url.isEmpty) return fallback();
  return CachedNetworkImage(
    imageUrl: url,
    fit: fit,
    width: width,
    height: height,
    errorWidget: (_, __, ___) => fallback(),
  );
}

String merchSubtitle(LayoutDatum data) {
  if ((data.featureText ?? '').trim().isNotEmpty) {
    return data.featureText!.trim();
  }
  if ((data.subTitle ?? '').trim().isNotEmpty) {
    return data.subTitle!.trim();
  }
  return '';
}

String merchSellingPrice(LayoutDatum data) {
  return data.prices?.sellingPrice ?? data.prices?.discountedPrice ?? '0';
}

String merchOriginalPrice(LayoutDatum data) {
  return data.prices?.originalPrice ?? '0';
}

String merchBadge(LayoutDatum data) {
  if ((data.salesText ?? '').trim().isNotEmpty) {
    return data.salesText!.trim();
  }
  return '';
}

String merchRating(LayoutDatum data) {
  if (data.rating == null) return '';
  return data.rating.toString();
}

class HomeMerchSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback? onTap;
  final bool centered;

  const HomeMerchSectionHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.ctaText = '',
    this.onTap,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: centered ? TextAlign.center : TextAlign.left,
      style: FontUtils.primaryFontStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textColor,
      ),
    );

    final subtitleWidget = subtitle.trim().isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                subtitle,
                style: FontUtils.primaryFontStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textColor50,
                ),
              ),
            ),
          );

    if (centered) {
      return Column(
        children: [
          subtitleWidget,
          titleWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              subtitleWidget,
              titleWidget,
            ],
          ),
        ),
        if (ctaText.trim().isNotEmpty && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ctaText,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class HomeMerchCompactCard extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final bool showButton;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const HomeMerchCompactCard({
    super.key,
    required this.data,
    required this.onTap,
    this.showButton = true,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final badge = merchBadge(data);
    final subtitle = merchSubtitle(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;
    final rating = merchRating(data);
    final variantId = data.variantDetails?.variantId ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 188,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 176,
                      width: double.infinity,
                      color: AppColors.secondary,
                      child: image.isEmpty
                          ? const ImageFallbackWidget(
                              h: 176,
                              w: double.infinity,
                              fit: BoxFit.contain,
                            )
                          : CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorWidget: (_, __, ___) =>
                                  const ImageFallbackWidget(
                                h: 176,
                                w: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                  ),
                  if (badge.isNotEmpty)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    color: AppColors.textColor50,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                CurrencyUtil.appendCurrency(sellingPrice),
                style: FontUtils.primaryFontStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColor,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(height: 4),
                Text(
                  CurrencyUtil.appendCurrency(originalPrice),
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    color: AppColors.textColor50,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
              if (rating.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rating,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (showButton) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: variantId.isNotEmpty && onCartQtyChanged != null
                        ? () => onCartQtyChanged!.call(1, variantId)
                        : onTap,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      variantId.isNotEmpty && onCartQtyChanged != null
                          ? 'ADD'
                          : 'SHOP NOW',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HomeMerchEditorialCard extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;

  const HomeMerchEditorialCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);
    final subtitle = merchSubtitle(data);
    final badge = merchBadge(data);
    final sellingPrice = merchSellingPrice(data);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 248,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    color: AppColors.secondary,
                    child: image.isEmpty
                        ? const ImageFallbackWidget(
                            h: 280,
                            w: double.infinity,
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (_, __, ___) =>
                                const ImageFallbackWidget(
                              h: 280,
                              w: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (badge.isNotEmpty)
                    Positioned(
                      left: 14,
                      top: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      CurrencyUtil.appendCurrency(sellingPrice),
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
