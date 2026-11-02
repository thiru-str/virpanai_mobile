import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/product_response.dart' as pr;
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/home/basket/basket_shared.dart';
import 'package:waioz/ui/widgets/home/maison/maison_shared.dart';
import 'package:waioz/utility/cart_store.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

/// BASKET's options sheet — MAISON's colour sheet made for a grocery shelf.
/// Same idea (pick the exact option and add it without leaving the shelf; the
/// preview shows the picked option's own photo and price), with the family's
/// rules: packshots whole on white, MRP struck with a "% OFF", and the add
/// button turning into a stepper so a shopper can take several packs, or a
/// second size, in one visit.
class BasketOption {
  final String id;
  final String name;
  final String price;
  final String mrp;
  final String image;
  final bool inStock;
  const BasketOption(this.id, this.name, this.price, this.mrp, this.image, this.inStock);
}

/// The options the home payload already carries, so the sheet opens filled.
List<BasketOption> basketOptionsFromItem(LayoutDatum d) => maisonVariants(d)
    .map((v) => BasketOption(v.id, v.name, v.price, '', v.image, true))
    .toList();

/// Every option with its own price, MRP, stock and photo, from the product.
/// Same in-stock rule as the product page.
Future<({String label, List<BasketOption> options})> basketLoadOptions(BuildContext context, LayoutDatum item) async {
  final response = await ApiService().productDetail(context, item.id ?? '');
  final variants = response.product?.variants ?? const <pr.Variant>[];
  String label = '';
  final options = <BasketOption>[];
  for (final v in variants) {
    if ((v.id ?? '').isEmpty) continue;
    final values = (v.options ?? const <pr.Value>[]).map((o) => o.value ?? '').where((s) => s.isNotEmpty).toList();
    if (label.isEmpty && (v.options?.isNotEmpty ?? false)) label = v.options!.first.option?.title ?? '';
    final photos = v.metadata?.images ?? const [];
    final photo = photos.isNotEmpty ? photos.first.url ?? '' : v.metadata?.thumbnail ?? '';
    final inStock = v.manageInventory != true || v.allowBackorder == true || (v.inventoryQuantity ?? 0) > 0;
    options.add(BasketOption(
      v.id!,
      values.isNotEmpty ? values.join(' · ') : (v.title ?? ''),
      v.calculatedPrice?.calculatedAmount?.toString() ?? '',
      v.calculatedPrice?.originalAmount?.toString() ?? '',
      photo,
      inStock,
    ));
  }
  return (label: label, options: options);
}

Future<void> showBasketOptionsSheet(BuildContext context, LayoutDatum item, BasketColors colors,
    void Function(int delta, String variantId) onCartQtyChanged) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BasketOptionsSheet(item: item, colors: colors, onCartQtyChanged: onCartQtyChanged),
  );
}

class BasketOptionsSheet extends StatefulWidget {
  final LayoutDatum item;
  final BasketColors colors;
  final void Function(int delta, String variantId) onCartQtyChanged;

  /// Where the full option list comes from; a test passes its own.
  final Future<({String label, List<BasketOption> options})> Function(BuildContext context, LayoutDatum item) load;

  const BasketOptionsSheet(
      {super.key, required this.item, required this.colors, required this.onCartQtyChanged, this.load = basketLoadOptions});

  @override
  State<BasketOptionsSheet> createState() => _BasketOptionsSheetState();
}

class _BasketOptionsSheetState extends State<BasketOptionsSheet> {
  late List<BasketOption> _options = basketOptionsFromItem(widget.item);
  String _label = '';
  String _pickedId = '';
  bool _loading = true;
  StreamSubscription<CartStateEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _pickedId = _firstInStock(_options);
    _sub = eventBus.on<CartStateEvent>().listen((_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _firstInStock(List<BasketOption> options) {
    for (final o in options) {
      if (o.inStock) return o.id;
    }
    return options.isEmpty ? '' : options.first.id;
  }

  Future<void> _load() async {
    try {
      final r = await widget.load(context, widget.item);
      if (!mounted) return;
      setState(() {
        if (r.options.isNotEmpty) {
          final keep = r.options.any((o) => o.id == _pickedId && o.inStock);
          _options = r.options;
          if (!keep) _pickedId = _firstInStock(r.options);
        }
        _label = r.label;
      });
    } catch (_) {
      // the options the shelf carried still work without their photos
    }
    if (mounted) setState(() => _loading = false);
  }

  void _openProduct() {
    final id = widget.item.id ?? '';
    if (id.isEmpty) return;
    Navigator.of(context).pop();
    PageRouteUtils.pushWithSlide(context, ProductDetailPage(productId: id));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final bottom = 18 + MediaQuery.of(context).padding.bottom;
    final handle = Center(
      child: Container(
          width: 40, height: 4, decoration: BoxDecoration(color: kBasketLine, borderRadius: BorderRadius.circular(2))),
    );

    if (_options.isEmpty) {
      return _Shell(
        padding: EdgeInsets.fromLTRB(20, 10, 20, bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          handle,
          const SizedBox(height: 28),
          if (_loading)
            SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.4, color: c.accent))
          else ...[
            Text("Couldn't load the options", style: FontUtils.primaryFontStyle(fontSize: 14, color: kBasketInk)),
            TextButton(onPressed: _openProduct, child: Text('View product', style: TextStyle(color: c.accent))),
          ],
          const SizedBox(height: 28),
        ]),
      );
    }

    final picked = _options.firstWhere((o) => o.id == _pickedId, orElse: () => _options.first);
    final price = basketAmount(picked.price.isNotEmpty ? picked.price : widget.item.prices?.sellingPrice);
    final mrp = basketAmount(picked.mrp);
    final s = basketNumber(picked.price), o = basketNumber(picked.mrp);
    final off = s > 0 && o > s ? ((o - s) / o * 100).round() : 0;
    final image = picked.image.isNotEmpty ? picked.image : widget.item.image;
    final count = CartStore.instance.quantityForVariant(picked.id) ?? 0;
    final heading = _label.isNotEmpty ? 'Choose ${_label.toLowerCase()}' : 'Choose an option';

    return _Shell(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        handle,
        const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: _openProduct,
            child: Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBasketLine)),
              child: BasketImage(url: image),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.item.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: kBasketInk)),
              const SizedBox(height: 4),
              Text(picked.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.secondaryFontStyle(fontSize: 12.5, color: kBasketInk.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 4, children: [
                if (price.isNotEmpty)
                  Text(price,
                      style: FontUtils.primaryFontStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kBasketInk)),
                if (off > 0 && mrp.isNotEmpty)
                  Text(mrp,
                      style: FontUtils.secondaryFontStyle(
                          fontSize: 12.5,
                          color: kBasketInk.withValues(alpha: 0.45),
                          decoration: TextDecoration.lineThrough)),
                if (off > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: kBasketDeal, borderRadius: BorderRadius.circular(5)),
                    child: Text('$off% OFF',
                        style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        Text(heading.toUpperCase(),
            style: FontUtils.primaryFontStyle(
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: kBasketInk.withValues(alpha: 0.55))),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.34),
          child: SingleChildScrollView(
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final opt in _options)
                _OptionChip(
                  option: opt,
                  selected: opt.id == picked.id,
                  inCart: CartStore.instance.quantityForVariant(opt.id) ?? 0,
                  colors: c,
                  onTap: opt.inStock
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() => _pickedId = opt.id);
                        }
                      : null,
                ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        if (!picked.inStock)
          _WideButton(label: 'Sold out', fill: kBasketLine, ink: kBasketInk.withValues(alpha: 0.5))
        else if (count <= 0)
          _WideButton(
            label: 'Add to cart',
            fill: c.accent,
            ink: c.onAccent,
            icon: Icons.add_shopping_cart_rounded,
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onCartQtyChanged(1, picked.id);
            },
          )
        else
          _WideStepper(
            count: count,
            colors: c,
            onDec: () => widget.onCartQtyChanged(-1, picked.id),
            onInc: () => widget.onCartQtyChanged(1, picked.id),
          ),
      ]),
    );
  }
}

class _Shell extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;
  const _Shell({required this.padding, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: padding,
        child: child,
      );
}

/// One option: its name and price; a thin accent ring when picked, a small
/// count when it is already in the cart, struck through when sold out.
class _OptionChip extends StatelessWidget {
  final BasketOption option;
  final bool selected;
  final int inCart;
  final BasketColors colors;
  final VoidCallback? onTap;
  const _OptionChip(
      {required this.option, required this.selected, required this.inCart, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    final out = !option.inStock;
    final ink = out ? kBasketInk.withValues(alpha: 0.35) : kBasketInk;
    final price = basketAmount(option.price);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minWidth: 84),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.accent.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? colors.accent : kBasketLine, width: selected ? 1.6 : 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(option.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ink,
                      decoration: out ? TextDecoration.lineThrough : TextDecoration.none)),
            ),
            if (inCart > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: colors.accent, borderRadius: BorderRadius.circular(8)),
                child: Text('$inCart',
                    style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w800, color: colors.onAccent)),
              ),
            ],
          ]),
          const SizedBox(height: 2),
          Text(out ? 'Sold out' : price,
              style: FontUtils.secondaryFontStyle(fontSize: 11.5, color: kBasketInk.withValues(alpha: out ? 0.35 : 0.6))),
        ]),
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  final String label;
  final Color fill;
  final Color ink;
  final IconData? icon;
  final VoidCallback? onTap;
  const _WideButton({required this.label, required this.fill, required this.ink, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18, color: ink), const SizedBox(width: 8)],
            Text(label, style: FontUtils.primaryFontStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: ink)),
          ]),
        ),
      );
}

class _WideStepper extends StatelessWidget {
  final int count;
  final BasketColors colors;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _WideStepper({required this.count, required this.colors, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    final on = colors.onAccent;
    Widget btn(IconData icon, VoidCallback tap, String label) => Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              tap();
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(width: 64, height: 50, child: Icon(icon, size: 20, color: on)),
          ),
        );
    return Container(
      height: 50,
      decoration: BoxDecoration(color: colors.accent, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        btn(Icons.remove_rounded, onDec, 'Remove one'),
        Expanded(
          child: Text('$count in cart',
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: on)),
        ),
        btn(Icons.add_rounded, onInc, 'Add one'),
      ]),
    );
  }
}
