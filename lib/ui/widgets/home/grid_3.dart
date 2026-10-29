import 'package:cached_network_image/cached_network_image.dart';
import 'cms_text_color.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';

class Grid3 extends StatelessWidget {
  final Content content;

  const Grid3({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.only(top: 8)
        : const EdgeInsets.only(top: 8);
    final items = (content.layoutData ?? []).take(3).toList();
    final heroImage = content.layoutBannerImage?.isNotEmpty == true
        ? content.layoutBannerImage!
        : (items.isNotEmpty ? (items.first.image ?? '') : '');

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
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
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 268,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 220,
                    child: Container(
                      color: const Color(0xFFE1E4ED),
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: heroImage.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: heroImage,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const ImageFallbackWidget(
                                        w: 64, h: 64, fit: BoxFit.contain),
                              )
                            : const ImageFallbackWidget(
                                w: 64, h: 64, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    right: 15,
                    top: 165,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          _Grid3Card(
                            layoutData: items[i],
                            onTap: () {
                              RedirectUtils.handleContentRedirect(
                                context: context,
                                layoutOption: content.layoutOption ?? "",
                                layoutData: items[i],
                              );
                            },
                          ),
                          if (i != items.length - 1) const SizedBox(width: 30),
                        ],
                      ],
                    ),
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

class _Grid3Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Grid3Card({
    required this.layoutData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE1E4ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF6D758F),
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const ImageFallbackWidget(
                            w: 34, h: 34, fit: BoxFit.contain),
                      )
                    : const ImageFallbackWidget(
                        w: 34, h: 34, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              layoutData.title ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
