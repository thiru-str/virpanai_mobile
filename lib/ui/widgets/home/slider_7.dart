import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';
import 'cms_text_color.dart';

class Slider7 extends StatelessWidget {
  final Content content;

  const Slider7({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((content.layoutTitle ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Center(
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _Slider7Card(
                      layoutData: items[i],
                      onTap: () {
                        RedirectUtils.handleContentRedirect(
                          context: context,
                          layoutOption: content.layoutOption ?? '',
                          layoutData: items[i],
                        );
                      },
                    ),
                    if (i != items.length - 1) const SizedBox(width: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slider7Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Slider7Card({
    required this.layoutData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.72,
          height: 230,
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: Uri.encodeFull(imageUrl),
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const ImageFallbackWidget(
                    fit: BoxFit.contain,
                  ),
                )
              : const ImageFallbackWidget(
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
