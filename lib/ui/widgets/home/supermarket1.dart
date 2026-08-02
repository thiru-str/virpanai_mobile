import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// Supermarket / quick-commerce compact component batch (FRESHKART genre).
// Mirrors the web CategoryMini1 / ProductMini1 / DealStrip1 — deliberately
// SMALL, dense cards for a grocery storefront.
const Color kGrocery = Color(0xFF16A34A);
const Color kDeal = Color(0xFFE11D48);

// CategoryMini1 — dense grid of small category tiles (rounded squares).
class CategoryMini1 extends StatelessWidget {
  final Content content;
  const CategoryMini1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? '',
            ctaText: content.layoutRedirectTitle ?? ''),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78),
          itemBuilder: (context, i) => Column(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox.expand(
                  child: merchImageOrFallback(merchImage(items[i]),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(items[i].title ?? '',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: cmsText(context, AppColors.textColor))),
          ]),
        ),
      ]),
    );
  }
}

// ProductMini1 — dense grid of small product cards (image, pack size, price, ADD).
class ProductMini1 extends StatelessWidget {
  final Content content;
  const ProductMini1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? '',
            ctaText: content.layoutRedirectTitle ?? ''),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.56),
          itemBuilder: (context, i) => _MiniProductCard(data: items[i]),
        ),
      ]),
    );
  }
}

class _MiniProductCard extends StatelessWidget {
  final LayoutDatum data;
  const _MiniProductCard({required this.data});
  @override
  Widget build(BuildContext context) {
    final selling = merchSellingPrice(data);
    final original = merchOriginalPrice(data);
    final hasDiscount = original != '0' && original != selling;
    final badge = merchBadge(data);
    return Container(
      decoration: BoxDecoration(
        color: cmsCard(context, Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kInkBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(fit: StackFit.expand, children: [
            Container(
              color: AppColors.secondary,
              child: merchImageOrFallback(merchImage(data), fit: BoxFit.cover),
            ),
            if (badge.isNotEmpty)
              Positioned(
                left: 5,
                top: 5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(badge,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // pack size like "1 kg" contains letters; skip a bare price number
                  if ((data.subTitle ?? '').isNotEmpty &&
                      data.subTitle!.codeUnits.any((c) =>
                          (c >= 65 && c <= 90) || (c >= 97 && c <= 122)))
                    Text(data.subTitle!,
                        style: FontUtils.primaryFontStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: cmsCardText(context, AppColors.textColor50))),
                  Text(data.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cmsCardText(context, AppColors.textColor))),
                  const Spacer(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(CurrencyUtil.appendCurrency(selling),
                                  style: FontUtils.primaryFontStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: cmsCardText(context, AppColors.textColor))),
                              if (hasDiscount)
                                Text(CurrencyUtil.appendCurrency(original),
                                    style: FontUtils.primaryFontStyle(
                                        fontSize: 9,
                                        color: cmsCardText(context, AppColors.textColor50),
                                        decoration:
                                            TextDecoration.lineThrough)),
                            ]),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cmsAccent(context, kGrocery)),
                          ),
                          child: Text('ADD',
                              style: FontUtils.primaryFontStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: cmsAccent(context, kGrocery))),
                        ),
                      ]),
                ]),
          ),
        ),
      ]),
    );
  }
}

// DealStrip1 — scrollable strip of small offer/deal cards.
class DealStrip1 extends StatelessWidget {
  final Content content;
  const DealStrip1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
              ctaText: content.layoutRedirectTitle ?? ''),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 170,
                child: Stack(fit: StackFit.expand, children: [
                  Container(
                    color: AppColors.secondary,
                    child: merchImageOrFallback(merchImage(items[i]),
                        fit: BoxFit.cover),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((items[i].featureText ?? '').isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: kDeal,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(items[i].featureText!,
                                  style: FontUtils.primaryFontStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                          const SizedBox(height: 5),
                          Text(items[i].title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

const Color kInkBorder = Color(0x14000000);
