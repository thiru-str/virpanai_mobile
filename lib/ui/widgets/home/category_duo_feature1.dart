import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryDuoFeature1 — exactly TWO tall half-width feature category cards side
// by side (the first two items). Each is a rounded image with a bottom scrim, a
// large title overlay and a small "Shop ›" caption. If only one item exists it
// renders full-width. Distinct from the two-column image GRID by being a fixed
// pair of tall hero tiles rather than an N-item grid.
class CategoryDuoFeature1 extends StatelessWidget {
  final Content content;
  const CategoryDuoFeature1({super.key, required this.content});

  Widget _card(BuildContext context, LayoutDatum item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => RedirectUtils.handleContentRedirect(
        context: context,
        layoutOption: content.layoutOption ?? '',
        layoutData: item,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 200,
          color: cmsCard(context, AppColors.secondary),
          child: Stack(
            fit: StackFit.expand,
            children: [
              merchImageOrFallback(
                merchImage(item),
                width: double.infinity,
                height: double.infinity,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shop ›',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
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
    final pair = items.take(2).toList();
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
          if (pair.length == 1)
            _card(context, pair.first)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _card(context, pair[0])),
                const SizedBox(width: 12),
                Expanded(child: _card(context, pair[1])),
              ],
            ),
        ],
      ),
    );
  }
}
