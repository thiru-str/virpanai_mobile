import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'premium_kit.dart';

/// Premium product card — clean image, badge, title, price, add.
/// Used by both the rail (fixed width) and the grid (full-width Add).
class PProductCard extends StatelessWidget {
  final LayoutDatum item;
  final double imageAspect;
  final bool fullWidthAdd; // grid style vs compact-icon rail style
  const PProductCard({super.key, required this.item, this.imageAspect = 1, this.fullWidthAdd = false});

  @override
  Widget build(BuildContext context) {
    final title = item.title ?? '';
    final badge = item.salesText;
    return PCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(children: [
            PImage(url: item.image, aspectRatio: imageAspect, radius: PRadius.image - 2),
            if (badge != null && badge.isNotEmpty)
              Positioned(top: 8, left: 8, child: PBadge(text: badge)),
          ]),
          const SizedBox(height: PGap.md),
          SizedBox(
            height: 36,
            child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: PType.cardTitle()),
          ),
          const SizedBox(height: PGap.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: PPrice(selling: item.prices?.sellingPrice, original: item.prices?.originalPrice)),
              if (!fullWidthAdd) ...[
                const SizedBox(width: PGap.sm),
                const PAddButton(compact: true),
              ],
            ],
          ),
          if (fullWidthAdd) ...[
            const SizedBox(height: PGap.md),
            const PAddButton(),
          ],
        ],
      ),
    );
  }
}

/// PremiumProductRail1 — horizontal, premium product rail with a section header.
class PremiumProductRail1 extends StatelessWidget {
  final Content content;
  const PremiumProductRail1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: PGap.xl),
        PSectionHeader(
          title: content.layoutTitle ?? '',
          subtitle: content.layoutSubTitle,
          cta: content.layoutRedirectTitle,
        ),
        SizedBox(
          height: 312,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: PGap.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: PGap.md),
            itemBuilder: (_, i) => SizedBox(width: 172, child: PProductCard(item: items[i], fullWidthAdd: true)),
          ),
        ),
        const SizedBox(height: PGap.xs),
      ],
    );
  }
}

/// PremiumProductGrid1 — 2-column premium product grid.
class PremiumProductGrid1 extends StatelessWidget {
  final Content content;
  const PremiumProductGrid1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: PGap.xl),
        PSectionHeader(
          title: content.layoutTitle ?? '',
          subtitle: content.layoutSubTitle,
          cta: content.layoutRedirectTitle,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: PGap.lg),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: PGap.md,
            mainAxisSpacing: PGap.md,
            mainAxisExtent: 340,
          ),
          itemBuilder: (_, i) => PProductCard(item: items[i], imageAspect: 4 / 5, fullWidthAdd: true),
        ),
        const SizedBox(height: PGap.xs),
      ],
    );
  }
}
