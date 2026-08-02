import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';
import 'cms_text_color.dart';

class Grid10 extends StatelessWidget {
  final Content content;

  const Grid10({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final items = (content.layoutData ?? []).take(6).toList();

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                content.layoutTitle?.isNotEmpty == true
                    ? content.layoutTitle!
                    : 'Title Here',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.secondaryFontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cmsCardText(context, AppColors.textColor),
                ),
              ),
            ),
            const SizedBox(height: 18),
            MasonryGridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              itemBuilder: (context, index) {
                final item = items[index];
                return _Grid10Card(
                  layoutData: item,
                  height: _heightForIndex(index),
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

  double _heightForIndex(int index) {
    switch (index % 6) {
      case 0:
      case 1:
        return 136;
      case 2:
        return 160;
      case 3:
        return 142;
      case 4:
        return 128;
      case 5:
        return 116;
      default:
        return 136;
    }
  }
}

class _Grid10Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final double height;
  final VoidCallback onTap;

  const _Grid10Card({
    required this.layoutData,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';
    final safeUrl = imageUrl.isNotEmpty ? Uri.encodeFull(imageUrl) : '';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: const Color(0xFFD9DBE6),
            child: safeUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: safeUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
      ),
    );
  }
}
