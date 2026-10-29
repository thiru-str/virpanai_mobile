import 'package:cached_network_image/cached_network_image.dart';
import 'cms_text_color.dart';
import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/page_route_utils.dart';
import '../../../utility/redirect_utils.dart';
import '../../product_detail_page.dart';
import '../../product_page.dart';

class Slider2 extends StatelessWidget {
  final Content content;

  const Slider2({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title + Redirect
            Visibility(
              visible: content.layoutTitle?.isNotEmpty == true,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        content.layoutTitle ?? '',
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                      ),
                    ),
                    if ((content.layoutRedirectTitle ?? '').isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          RedirectUtils.handleContentRedirectViewAll(
                            context: context,
                            redirectData: content.redirectData!,
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              content.layoutRedirectTitle ?? "",
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                color: cmsCardText(context, AppColors.textColor),
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18)
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 🔹 Horizontal scrollable product slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // ✅ ensures image alignment
                  children: [
                    for (int i = 0;
                        i < (content.layoutData?.length ?? 0);
                        i++) ...[
                      _Slider2Card(
                        layoutData: content.layoutData![i],
                        onTap: () {
                          RedirectUtils.handleContentRedirect(
                            context: context,
                            layoutOption: content.layoutOption ?? "",
                            layoutData: content.layoutData![i],
                          );
                        },
                      ),
                      if (i != content.layoutData!.length - 1)
                        const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slider2Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Slider2Card({
    Key? key,
    required this.layoutData,
    required this.onTap,
  }) : super(key: key);

  bool get _hasDiscount =>
      layoutData.prices?.discountedPrice != null &&
      layoutData.prices?.discountedPrice != "0";

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmallScreen ? 80 : 90,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(top: _hasDiscount ? 10 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Fixed image section (all aligned)
                  Container(
                    width: isSmallScreen ? 80 : 90,
                    height: isSmallScreen ? 80 : 90,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: (imageUrl.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const ImageFallbackWidget(h: 80),
                            )
                          : const ImageFallbackWidget(h: 80),
                    ),
                  ),
          
                  const SizedBox(height: 6),
          
                  // ✅ Text section (auto height but doesn’t affect image line)
                  Visibility(
                    visible: layoutData.title?.isNotEmpty == true,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: isSmallScreen ? 32 : 34,
                        maxHeight: isSmallScreen ? 40 : 44,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          layoutData.title ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Keep discount badge on top/front with half overlap
            if (_hasDiscount)
              Positioned(
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    layoutData.prices?.discountPercentage ?? '',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
