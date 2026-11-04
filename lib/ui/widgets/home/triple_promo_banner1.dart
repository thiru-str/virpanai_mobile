import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';

// TriplePromoBanner1 — three promo tiles in a Row from the first 3 layoutData
// items: rounded image + gradient + title + a tiny "Shop ›"; each tile taps
// through to its item. Renders fewer tiles if fewer than 3 items exist.
class TriplePromoBanner1 extends StatelessWidget {
  final Content content;
  const TriplePromoBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final tiles = items.length > 3 ? items.sublist(0, 3) : items;
    final ctaLabel = content.layoutRedirectTitle?.isNotEmpty == true
        ? content.layoutRedirectTitle!
        : 'Shop';

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                Expanded(
                  child: _PromoTile(
                    data: tiles[i],
                    ctaLabel: ctaLabel,
                    onTap: () => RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content.layoutOption ?? '',
                      layoutData: tiles[i],
                    ),
                  ),
                ),
                if (i != tiles.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  final LayoutDatum data;
  final String ctaLabel;
  final VoidCallback onTap;

  const _PromoTile({
    required this.data,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: merchImageOrFallback(merchImage(data), fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.70),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$ctaLabel ›',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.90),
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
