import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

class Slider12 extends StatelessWidget {
  final Content content;

  const Slider12({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: backgroundDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? 'SIGNATURE SHAPES',
            centered: true,
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _ShapeCard(
                    data: items[i],
                    shapeIndex: i,
                    onTap: () => RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content.layoutOption ?? '',
                      layoutData: items[i],
                    ),
                  ),
                  if (i != items.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShapeCard extends StatelessWidget {
  final LayoutDatum data;
  final int shapeIndex;
  final VoidCallback onTap;

  const _ShapeCard({
    required this.data,
    required this.shapeIndex,
    required this.onTap,
  });

  BorderRadius _borderRadiusForIndex() {
    switch (shapeIndex % 4) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(42),
          topRight: Radius.circular(42),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(42),
        );
      case 1:
        return BorderRadius.circular(999);
      case 2:
        return BorderRadius.circular(140);
      default:
        return const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(64),
          bottomLeft: Radius.circular(64),
          bottomRight: Radius.circular(24),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 220,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: _borderRadiusForIndex(),
              child: Container(
                height: 260,
                width: double.infinity,
                color: AppColors.secondary,
                child: image.isEmpty
                    ? const ImageFallbackWidget(
                        h: 260,
                        w: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, ___) => const ImageFallbackWidget(
                          h: 260,
                          w: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              data.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            if (merchSubtitle(data).isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                merchSubtitle(data),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: FontUtils.primaryFontStyle(
                  fontSize: 12,
                  color: cmsCardText(context, AppColors.textColor50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
