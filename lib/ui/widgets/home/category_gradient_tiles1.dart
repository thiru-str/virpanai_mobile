import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';

// CategoryGradientTiles1 — a 2-column grid of IMAGE-LESS gradient tiles. Each
// tile is a rounded Container filled with a LinearGradient whose hue is derived
// from the tile index (so every tile differs), a leading translucent-white
// Material icon (cycled from a small list) and the category title (white,
// maxLines 1) pinned bottom-left. No network image keeps it distinct from all
// image-based category widgets, and the per-index gradient hue keeps it
// distinct from the flat-tint colour-block grid.
class CategoryGradientTiles1 extends StatelessWidget {
  final Content content;
  const CategoryGradientTiles1({super.key, required this.content});

  static const _icons = [
    Icons.category_rounded,
    Icons.local_mall_rounded,
    Icons.diamond_rounded,
    Icons.spa_rounded,
    Icons.bolt_rounded,
    Icons.local_offer_rounded,
    Icons.auto_awesome_rounded,
    Icons.favorite_rounded,
  ];

  // A deliberate gradient accent: derive two related hues from the index so
  // each tile gets a distinct, saturated diagonal gradient.
  List<Color> _gradientFor(int i) {
    final hue = (i * 47) % 360;
    final start = HSLColor.fromAHSL(1, hue.toDouble(), 0.62, 0.55).toColor();
    final end =
        HSLColor.fromAHSL(1, (hue + 24) % 360.0, 0.66, 0.42).toColor();
    return [start, end];
  }

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 100,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              final colors = _gradientFor(i);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _icons[i % _icons.length],
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        item.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
