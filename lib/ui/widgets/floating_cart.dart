import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/cart_store.dart';
import 'package:waioz/utility/page_route_utils.dart';

/// The floating "View cart" pill, for a Scaffold's floatingActionButton slot
/// with [FloatingActionButtonLocation.centerFloat]. Shows while the cart holds
/// something; it reads [CartStore] on open, so a page pushed after the last cart
/// change still shows it. Opens the cart page unless [onTap] says otherwise.
class FloatingCart extends StatefulWidget {
  /// Bottom padding for a scrolling page, so its last row clears the pill.
  static const double clearance = 96;

  final VoidCallback? onTap;
  const FloatingCart({super.key, this.onTap});

  @override
  State<FloatingCart> createState() => _FloatingCartState();
}

class _FloatingCartState extends State<FloatingCart> {
  ViewCartModel? _cart = CartStore.instance.badge;
  late final StreamSubscription<ViewCartModel> _sub;

  @override
  void initState() {
    super.initState();
    _sub = eventBus.on<ViewCartModel>().listen((event) {
      if (mounted) setState(() => _cart = event);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _cart?.totalItems ?? 0;
    if (total == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: widget.onTap ?? () => PageRouteUtils.pushWithSlide(context, const CartPage()),
      child: ViewCartWidget(totalItems: total, itemImages: _cart?.itemImages),
    );
  }
}
