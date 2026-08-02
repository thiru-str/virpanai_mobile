import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';
import 'cms_text_color.dart';

class Banner3 extends StatelessWidget {
  final Content content;

  const Banner3({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BannerGridSection(
      content: content,
      maxItems: 3,
    );
  }
}

class Banner4 extends StatelessWidget {
  final Content content;

  const Banner4({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BannerGridSection(
      content: content,
      maxItems: 6,
    );
  }
}

class _BannerGridSection extends StatelessWidget {
  final Content content;
  final int maxItems;

  const _BannerGridSection({
    required this.content,
    required this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);
    final items = (content.layoutData ?? []).take(maxItems).toList();

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              content.layoutTitle ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.secondaryFontStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            if ((content.layoutSubTitle ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                content.layoutSubTitle ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 12,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const columns = 3;
                  const spacing = 10.0;
                  final computed =
                      (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;
                  final tileSize = computed.clamp(96.0, 115.0);

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final item in items)
                        _BannerItem(
                          size: tileSize,
                          imageUrl: item.image ?? '',
                          onTap: () {
                            RedirectUtils.handleContentRedirect(
                              context: context,
                              layoutOption: content.layoutOption ?? "",
                              layoutData: item,
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final double size;
  final String imageUrl;
  final VoidCallback onTap;

  const _BannerItem({
    required this.size,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    ImageFallbackWidget(h: size, w: size, fit: BoxFit.contain),
              )
            : ImageFallbackWidget(h: size, w: size, fit: BoxFit.contain),
      ),
    );
  }
}
