import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// Second quick-commerce compact batch (FRESHKART). Mirrors the web
// ProductStepper1 / CategoryCircle1 / CategoryPills1 / ReorderRail1 — the ADD
// button turns into a −/+ quantity stepper (Blinkit / Zepto pattern).
const Color _kGrocery = Color(0xFF16A34A);
const Color _kBorder = Color(0x14000000);

// A small −/+ stepper that swaps in for the ADD button.
class _AddStepper extends StatelessWidget {
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _AddStepper({required this.count, required this.onInc, required this.onDec});
  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return GestureDetector(
        onTap: onInc,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cmsAccent(context, _kGrocery)),
          ),
          child: Text('ADD',
              style: FontUtils.primaryFontStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, color: cmsAccent(context, _kGrocery))),
        ),
      );
    }
    return Container(
      decoration:
          BoxDecoration(color: cmsAccent(context, _kGrocery), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _stepBtn(Icons.remove, onDec),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text('$count',
              style: FontUtils.primaryFontStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: cmsOn(cmsAccent(context, _kGrocery)))),
        ),
        _stepBtn(Icons.add, onInc),
      ]),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
            height: 26,
            width: 24,
            child: Icon(icon, size: 15, color: Colors.white)),
      );
}

// Compact product card with a stepper. Shared by ProductStepper1 + ReorderRail1.
class _StepperCard extends StatelessWidget {
  final LayoutDatum data;
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _StepperCard(
      {required this.data,
      required this.count,
      required this.onInc,
      required this.onDec});

  bool get _hasPack {
    final s = data.subTitle ?? '';
    return s.isNotEmpty &&
        s.codeUnits.any((c) => (c >= 65 && c <= 90) || (c >= 97 && c <= 122));
  }

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
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(fit: StackFit.expand, children: [
            Container(
                color: AppColors.secondary,
                child: merchImageOrFallback(merchImage(data), fit: BoxFit.cover)),
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
                  if (_hasPack)
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
                                        decoration: TextDecoration.lineThrough)),
                            ]),
                        _AddStepper(count: count, onInc: onInc, onDec: onDec),
                      ]),
                ]),
          ),
        ),
      ]),
    );
  }
}

// A product's variant id (for the cart) and its current cart quantity.
String _variantOf(LayoutDatum d) =>
    d.variantDetails?.variantId ?? d.cartDetails?.variantId ?? '';
int _cartQtyOf(LayoutDatum d) => d.cartDetails?.quantity ?? 0;

// ProductStepper1 — dense grid of small product cards with ADD→stepper wired to
// the real cart. `onCartQtyChanged(delta, variantId)` runs the add/update.
class ProductStepper1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ProductStepper1({super.key, required this.content, this.onCartQtyChanged});
  @override
  State<ProductStepper1> createState() => _ProductStepper1State();
}

class _ProductStepper1State extends State<ProductStepper1> {
  final Map<String, int> _qty = {};

  @override
  void initState() {
    super.initState();
    for (final d in widget.content.layoutData ?? []) {
      _qty[d.id ?? ''] = _cartQtyOf(d);
    }
  }

  void _bump(String id, String variantId, int d) {
    setState(() => _qty[id] = ((_qty[id] ?? 0) + d).clamp(0, 99));
    if (variantId.isNotEmpty) widget.onCartQtyChanged?.call(d, variantId);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
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
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.53),
          itemBuilder: (context, i) {
            final id = items[i].id ?? '$i';
            final vid = _variantOf(items[i]);
            return _StepperCard(
                data: items[i],
                count: _qty[id] ?? 0,
                onInc: () => _bump(id, vid, 1),
                onDec: () => _bump(id, vid, -1));
          },
        ),
      ]),
    );
  }
}

// ReorderRail1 — "Buy it again" horizontal rail of small cards with stepper.
class ReorderRail1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;
  const ReorderRail1({super.key, required this.content, this.onCartQtyChanged});
  @override
  State<ReorderRail1> createState() => _ReorderRail1State();
}

class _ReorderRail1State extends State<ReorderRail1> {
  final Map<String, int> _qty = {};

  @override
  void initState() {
    super.initState();
    for (final d in widget.content.layoutData ?? []) {
      _qty[d.id ?? ''] = _cartQtyOf(d);
    }
  }

  void _bump(String id, String variantId, int d) {
    setState(() => _qty[id] = ((_qty[id] ?? 0) + d).clamp(0, 99));
    if (variantId.isNotEmpty) widget.onCartQtyChanged?.call(d, variantId);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(widget.content),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Icon(Icons.replay, size: 18, color: _kGrocery),
            const SizedBox(width: 8),
            Expanded(
              child: HomeMerchSectionHeader(
                  title: widget.content.layoutTitle ?? 'Buy it again',
                  subtitle: widget.content.layoutSubTitle ?? '',
                  ctaText: widget.content.layoutRedirectTitle ?? ''),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final id = items[i].id ?? '$i';
              final vid = _variantOf(items[i]);
              return SizedBox(
                width: 140,
                child: _StepperCard(
                    data: items[i],
                    count: _qty[id] ?? 0,
                    onInc: () => _bump(id, vid, 1),
                    onDec: () => _bump(id, vid, -1)),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// CategoryCircle1 — scrollable rail of small circular category icons.
class CategoryCircle1 extends StatelessWidget {
  final Content content;
  const CategoryCircle1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((content.layoutTitle ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: HomeMerchSectionHeader(
                title: content.layoutTitle ?? '',
                subtitle: content.layoutSubTitle ?? ''),
          ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) => SizedBox(
              width: 66,
              child: Column(children: [
                ClipOval(
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: merchImageOrFallback(merchImage(items[i]),
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 5),
                Text(items[i].title ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cmsText(context, AppColors.textColor))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// CategoryPills1 — scrollable row of small category chips.
class CategoryPills1 extends StatelessWidget {
  final Content content;
  const CategoryPills1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((content.layoutTitle ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: HomeMerchSectionHeader(
                title: content.layoutTitle ?? '',
                subtitle: content.layoutSubTitle ?? ''),
          ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => Container(
              padding: const EdgeInsets.only(left: 4, right: 12),
              decoration: BoxDecoration(
                color: cmsCard(context, Colors.white),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _kBorder),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                ClipOval(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: merchImageOrFallback(merchImage(items[i]),
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 8),
                Text(items[i].title ?? '',
                    style: FontUtils.primaryFontStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cmsCardText(context, AppColors.textColor))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
