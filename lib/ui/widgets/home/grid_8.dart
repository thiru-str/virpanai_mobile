import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';
import 'cms_text_color.dart';

class Grid8 extends StatelessWidget {
  final Content content;

  const Grid8({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final items = content.layoutData ?? [];
    final leftImage = (content.layoutLeftCardImage ?? '').trim().isNotEmpty
        ? content.layoutLeftCardImage!.trim()
        : (items.isNotEmpty ? (items.first.image ?? '') : '');
    final rightImage = (content.layoutRightCardImage ?? '').trim().isNotEmpty
        ? content.layoutRightCardImage!.trim()
        : (items.length > 1 ? (items[1].image ?? '') : '');

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      content.layoutTitle ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
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
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          content.layoutRedirectTitle ?? '',
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cmsCardText(context, AppColors.textColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _TopImageCard(
                    imageUrl: leftImage,
                    onTap: () {
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content.redirectData!,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TopImageCard(
                    imageUrl: rightImage,
                    onTap: () {
                      RedirectUtils.handleContentRedirectViewAll(
                        context: context,
                        redirectData: content.redirectData!,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 14,
                mainAxisSpacing: 18,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _Grid8Item(
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
          ],
        ),
      ),
    );
  }
}

class _TopImageCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _TopImageCard({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeUrl = imageUrl.isNotEmpty ? Uri.encodeFull(imageUrl) : '';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1.42,
          child: safeUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: safeUrl,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const ImageFallbackWidget(
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
      ),
    );
  }
}

class _Grid8Item extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Grid8Item({
    required this.layoutData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';
    final safeUrl = imageUrl.isNotEmpty ? Uri.encodeFull(imageUrl) : '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: safeUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: safeUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const ImageFallbackWidget(
                        w: 28,
                        h: 28,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const ImageFallbackWidget(
                      w: 28,
                      h: 28,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: Text(
              layoutData.title ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
