import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryMasonry1 — a 2-column STAGGERED / masonry layout of rounded image
// tiles. Even-index items go in the left column, odd-index in the right, and
// tile heights alternate tall/short by index so the two columns interleave.
// Each tile has a bottom scrim gradient with the category title overlaid.
class CategoryMasonry1 extends StatelessWidget {
  final Content content;
  const CategoryMasonry1({super.key, required this.content});

  // Alternating heights: index 0 tall, 1 short, 2 short, 3 tall, ... so the two
  // columns stagger against each other.
  double _tileHeight(int index) => (index % 4 == 0 || index % 4 == 3) ? 200 : 150;

  Widget _tile(BuildContext context, LayoutDatum item, int index) {
    return GestureDetector(
      onTap: () => RedirectUtils.handleContentRedirect(
        context: context,
        layoutOption: content.layoutOption ?? '',
        layoutData: item,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: _tileHeight(index),
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: cmsCard(context, AppColors.secondary),
                child: merchImageOrFallback(
                  merchImage(item),
                  width: double.infinity,
                  height: _tileHeight(index),
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
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  item.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final tile = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _tile(context, items[i], i),
      );
      if (i.isEven) {
        left.add(tile);
      } else {
        right.add(tile);
      }
    }

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((content.layoutTitle ?? '').isNotEmpty) ...[
            HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
              ctaText: content.layoutRedirectTitle ?? '',
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: left,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
