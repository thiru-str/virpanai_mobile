import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomZigzagRows1 — alternating editorial content rows (zig-zag) of CUSTOM
// content. Each item is a Row of a fixed 100x100 rounded image and a text
// column (title bold maxLines 2 + description maxLines 3). EVEN rows are
// image-left, ODD rows image-right (children order swapped). Rows tap through.
// Vertical, non-scrolling list capped at 4 items. NOT products.
class CustomZigzagRows1 extends StatelessWidget {
  final Content content;
  const CustomZigzagRows1({super.key, required this.content});

  static const double _imageSize = 100;

  @override
  Widget build(BuildContext context) {
    final all = content.layoutData ?? [];
    if (all.isEmpty) return const SizedBox.shrink();
    final items = all.length > 4 ? all.sublist(0, 4) : all;

    final titleColor = cmsCardText(context, AppColors.textColor);
    final descColor = cmsCardText(context, AppColors.textColor50);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((content.layoutTitle ?? '').isNotEmpty ||
              (content.layoutSubTitle ?? '').isNotEmpty) ...[
            HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
            ),
            const SizedBox(height: 12),
          ],
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, i) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final item = items[i];
              final description = merchSubtitle(item);
              final imageLeft = i.isEven;

              final image = ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: merchImageOrFallback(
                  merchImage(item),
                  width: _imageSize,
                  height: _imageSize,
                ),
              );

              final text = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12.5,
                          color: descColor,
                        ),
                      ),
                    ],
                  ],
                ),
              );

              final children = imageLeft
                  ? [image, const SizedBox(width: 16), text]
                  : [text, const SizedBox(width: 16), image];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
