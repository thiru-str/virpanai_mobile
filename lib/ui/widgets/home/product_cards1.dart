import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'product_cards_shared.dart';
import 'cms_text_color.dart';

// Reusable product-card components (mirrors the web ProductListRow1 /
// ProductHeroGrid1 / ProductCarouselXL1 / ProductRatingGrid1). Each is wired to
// the real cart via onCartQtyChanged(delta, variantId).

String _price(String v) => CurrencyUtil.appendCurrency(v);
String? _rating(LayoutDatum d) => d.rating?.toString();

// ---------------------------------------------------------------- ListRow ----
class ProductListRow1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductListRow1({super.key, required this.content, this.onCartQtyChanged});
  @override
  State<ProductListRow1> createState() => _ProductListRow1State();
}

class _ProductListRow1State extends State<ProductListRow1> {
  final Map<String, int> _qty = {};
  @override
  void initState() {
    super.initState();
    for (final d in widget.content.layoutData ?? []) {
      _qty[d.id ?? ''] = cartQtyOf(d);
    }
  }

  void _bump(String id, String vid, int delta) {
    setState(() => _qty[id] = ((_qty[id] ?? 0) + delta).clamp(0, 99));
    if (vid.isNotEmpty) widget.onCartQtyChanged?.call(delta, vid);
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.content.layoutData ?? []).take(8).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final accent = AppColors.textColor;
    return Container(
      decoration: AppUtils.buildLayoutBackground(widget.content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(
            title: widget.content.layoutTitle ?? '',
            subtitle: widget.content.layoutSubTitle ?? '',
            ctaText: widget.content.layoutRedirectTitle ?? ''),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cmsCard(context, Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i != 0) const Divider(height: 1),
                _row(context, items[i], accent),
              ]
            ],
          ),
        ),
      ]),
    );
  }

  Widget _row(BuildContext context, LayoutDatum d, Color accent) {
    final id = d.id ?? '';
    final vid = variantIdOf(d);
    final selling = sellingPriceOf(d);
    final original = originalPriceOf(d);
    final hasDiscount = original != '0' && original != selling;
    final rating = _rating(d);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
              height: 60,
              width: 60,
              child: merchImageOrFallback(merchImage(d), fit: BoxFit.cover)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cmsCardText(context, AppColors.textColor))),
                const SizedBox(height: 2),
                Row(children: [
                  if (hasPackText(d.subTitle))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(d.subTitle!,
                          style: FontUtils.primaryFontStyle(
                              fontSize: 11, color: cmsCardText(context, AppColors.textColor50))),
                    ),
                  if (rating != null && rating.isNotEmpty)
                    RatingChip(rating: rating),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Text(_price(selling),
                      style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: cmsCardText(context, AppColors.textColor))),
                  if (hasDiscount) ...[
                    const SizedBox(width: 6),
                    Text(_price(original),
                        style: FontUtils.primaryFontStyle(
                            fontSize: 11,
                            color: cmsCardText(context, AppColors.textColor50),
                            decoration: TextDecoration.lineThrough)),
                  ],
                ]),
              ]),
        ),
        const SizedBox(width: 8),
        AddStepper(
            count: _qty[id] ?? 0,
            accent: accent,
            onInc: () => _bump(id, vid, 1),
            onDec: () => _bump(id, vid, -1)),
      ]),
    );
  }
}

// --------------------------------------------------------------- HeroGrid ----
class ProductHeroGrid1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductHeroGrid1({super.key, required this.content, this.onCartQtyChanged});
  @override
  State<ProductHeroGrid1> createState() => _ProductHeroGrid1State();
}

class _ProductHeroGrid1State extends State<ProductHeroGrid1> {
  final Map<String, int> _qty = {};
  @override
  void initState() {
    super.initState();
    for (final d in widget.content.layoutData ?? []) {
      _qty[d.id ?? ''] = cartQtyOf(d);
    }
  }

  void _bump(String id, String vid, int delta) {
    setState(() => _qty[id] = ((_qty[id] ?? 0) + delta).clamp(0, 99));
    if (vid.isNotEmpty) widget.onCartQtyChanged?.call(delta, vid);
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.content.layoutData ?? []).take(5).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final accent = AppColors.textColor;
    final hero = items.first;
    final rest = items.skip(1).take(4).toList();
    return Container(
      decoration: AppUtils.buildLayoutBackground(widget.content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(
            title: widget.content.layoutTitle ?? '',
            subtitle: widget.content.layoutSubTitle ?? '',
            ctaText: widget.content.layoutRedirectTitle ?? ''),
        const SizedBox(height: 12),
        _heroCard(context, hero, accent),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [for (final d in rest) _smallCard(context, d, accent)],
        ),
      ]),
    );
  }

  Widget _heroCard(BuildContext context, LayoutDatum d, Color accent) {
    final id = d.id ?? '';
    final vid = variantIdOf(d);
    return Container(
      decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kCardBorder)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
            aspectRatio: 16 / 10,
            child: merchImageOrFallback(merchImage(d), fit: BoxFit.cover)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(d.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: cmsCardText(context, AppColors.textColor))),
                    const SizedBox(height: 4),
                    Text(_price(sellingPriceOf(d)),
                        style: FontUtils.primaryFontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: cmsCardText(context, AppColors.textColor))),
                  ]),
            ),
            AddStepper(
                count: _qty[id] ?? 0,
                accent: accent,
                onInc: () => _bump(id, vid, 1),
                onDec: () => _bump(id, vid, -1)),
          ]),
        ),
      ]),
    );
  }

  Widget _smallCard(BuildContext context, LayoutDatum d, Color accent) {
    final id = d.id ?? '';
    final vid = variantIdOf(d);
    return Container(
      decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kCardBorder)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
            aspectRatio: 1,
            child: merchImageOrFallback(merchImage(d), fit: BoxFit.cover)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cmsCardText(context, AppColors.textColor))),
                  const Spacer(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_price(sellingPriceOf(d)),
                            style: FontUtils.primaryFontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: cmsCardText(context, AppColors.textColor))),
                        AddStepper(
                            count: _qty[id] ?? 0,
                            accent: accent,
                            onInc: () => _bump(id, vid, 1),
                            onDec: () => _bump(id, vid, -1)),
                      ]),
                ]),
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------- CarouselXL ----
class ProductCarouselXL1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductCarouselXL1({super.key, required this.content, this.onCartQtyChanged});
  @override
  State<ProductCarouselXL1> createState() => _ProductCarouselXL1State();
}

class _ProductCarouselXL1State extends State<ProductCarouselXL1> {
  final Map<String, int> _qty = {};
  @override
  void initState() {
    super.initState();
    for (final d in widget.content.layoutData ?? []) {
      _qty[d.id ?? ''] = cartQtyOf(d);
    }
  }

  void _bump(String id, String vid, int delta) {
    setState(() => _qty[id] = ((_qty[id] ?? 0) + delta).clamp(0, 99));
    if (vid.isNotEmpty) widget.onCartQtyChanged?.call(delta, vid);
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.content.layoutData ?? []).take(10).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final accent = AppColors.textColor;
    return Container(
      decoration: AppUtils.buildLayoutBackground(widget.content),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(
              title: widget.content.layoutTitle ?? '',
              subtitle: widget.content.layoutSubTitle ?? '',
              ctaText: widget.content.layoutRedirectTitle ?? ''),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 330,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final d = items[i];
              final id = d.id ?? '$i';
              final vid = variantIdOf(d);
              final selling = sellingPriceOf(d);
              final original = originalPriceOf(d);
              final hasDiscount = original != '0' && original != selling;
              final rating = _rating(d);
              return Container(
                width: 220,
                decoration: BoxDecoration(
                    color: cmsCard(context, Colors.white),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: kCardBorder)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                          aspectRatio: 4 / 5,
                          child: merchImageOrFallback(merchImage(d),
                              fit: BoxFit.cover)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.title ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FontUtils.primaryFontStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: cmsCardText(context, AppColors.textColor))),
                                if (rating != null && rating.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  RatingChip(rating: rating),
                                ],
                                const Spacer(),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(_price(selling),
                                                style:
                                                    FontUtils.primaryFontStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: AppColors
                                                            .textColor)),
                                            if (hasDiscount)
                                              Text(_price(original),
                                                  style: FontUtils
                                                      .primaryFontStyle(
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .textColor50,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough)),
                                          ]),
                                      AddStepper(
                                          count: _qty[id] ?? 0,
                                          accent: accent,
                                          onInc: () => _bump(id, vid, 1),
                                          onDec: () => _bump(id, vid, -1)),
                                    ]),
                              ]),
                        ),
                      ),
                    ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------- RatingGrid ----
class ProductRatingGrid1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductRatingGrid1({super.key, required this.content, this.onCartQtyChanged});
  @override
  State<ProductRatingGrid1> createState() => _ProductRatingGrid1State();
}

class _ProductRatingGrid1State extends State<ProductRatingGrid1> {
  final Map<String, int> _qty = {};
  @override
  void initState() {
    super.initState();
    for (final d in widget.content.layoutData ?? []) {
      _qty[d.id ?? ''] = cartQtyOf(d);
    }
  }

  void _bump(String id, String vid, int delta) {
    setState(() => _qty[id] = ((_qty[id] ?? 0) + delta).clamp(0, 99));
    if (vid.isNotEmpty) widget.onCartQtyChanged?.call(delta, vid);
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.content.layoutData ?? []).take(8).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final accent = AppColors.textColor;
    return Container(
      decoration: AppUtils.buildLayoutBackground(widget.content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(
            title: widget.content.layoutTitle ?? '',
            subtitle: widget.content.layoutSubTitle ?? '',
            ctaText: widget.content.layoutRedirectTitle ?? ''),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.66),
          itemBuilder: (context, i) {
            final d = items[i];
            final id = d.id ?? '$i';
            final vid = variantIdOf(d);
            final selling = sellingPriceOf(d);
            final original = originalPriceOf(d);
            final hasDiscount = original != '0' && original != selling;
            final rating = _rating(d);
            final off = d.prices?.discountPercentage;
            return Container(
              decoration: BoxDecoration(
                  color: cmsCard(context, Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kCardBorder)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(children: [
                      AspectRatio(
                          aspectRatio: 1.15,
                          child: merchImageOrFallback(merchImage(d),
                              fit: BoxFit.cover)),
                      if ((off ?? '').isNotEmpty)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(off!,
                                style: FontUtils.primaryFontStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                        ),
                    ]),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (rating != null && rating.isNotEmpty)
                                RatingChip(rating: rating, solid: true),
                              const SizedBox(height: 3),
                              Text(d.title ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: FontUtils.primaryFontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cmsCardText(context, AppColors.textColor))),
                              const Spacer(),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(_price(selling),
                                              style:
                                                  FontUtils.primaryFontStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors
                                                          .textColor)),
                                          if (hasDiscount)
                                            Text(_price(original),
                                                style: FontUtils
                                                    .primaryFontStyle(
                                                        fontSize: 9,
                                                        color: AppColors
                                                            .textColor50,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough)),
                                        ]),
                                    AddStepper(
                                        count: _qty[id] ?? 0,
                                        accent: accent,
                                        onInc: () => _bump(id, vid, 1),
                                        onDec: () => _bump(id, vid, -1)),
                                  ]),
                            ]),
                      ),
                    ),
                  ]),
            );
          },
        ),
      ]),
    );
  }
}
