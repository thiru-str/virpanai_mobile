import 'package:cached_network_image/cached_network_image.dart';
import 'cms_text_color.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';

class Grid5 extends StatelessWidget {
  final Content content;

  const Grid5({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final items = (content.layoutData ?? []).take(8).toList();
    final headerImage = content.layoutBannerImage ?? '';

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.layoutTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        content.layoutSubTitle ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cmsText(context, const Color(0xFF7B7B7B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: headerImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: headerImage,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) =>
                              const ImageFallbackWidget(
                            w: 40,
                            h: 40,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const ImageFallbackWidget(
                          w: 40,
                          h: 40,
                          fit: BoxFit.contain,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cmsCard(context, const Color(0xFFE1E4ED)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _Grid5Card(
                    layoutData: item,
                    onTap: () {
                      RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption ?? "",
                        layoutData: item,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid5Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Grid5Card({
    required this.layoutData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.expand(
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const ImageFallbackWidget(
                    w: 26,
                    h: 26,
                    fit: BoxFit.contain,
                  ),
                )
              : const ImageFallbackWidget(
                  w: 26,
                  h: 26,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
