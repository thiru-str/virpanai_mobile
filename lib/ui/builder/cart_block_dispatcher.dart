import 'package:flutter/material.dart';
import '../../model/block_config.dart';
import 'block_dispatcher.dart';
import 'blocks/cart/cart_items_1.dart';
import 'blocks/cart/promo_code_1.dart';
import 'blocks/cart/order_summary_1.dart';
import 'blocks/cart/checkout_cta_1.dart';

/// Dispatches Cart blocks to their component widgets.
class CartBlockDispatcher extends BlockDispatcher {
  // Cart data
  List<dynamic> cartItems = [];
  bool isLoading = false;
  List<String> appliedPromoCodes = [];
  String? subtotal;
  String? discount;
  String? shipping;
  String? tax;
  String? total;
  String? platformFee;
  bool isCheckoutLoading = false;

  // Callbacks
  Function(dynamic item, int newQty)? onQuantityChanged;
  Function(dynamic item)? onRemoveItem;
  VoidCallback? onPromoCodeTap;
  VoidCallback? onCheckout;
  VoidCallback? onContinueShopping;

  @override
  Widget buildBlock(BlockConfig block) {
    switch (block.component) {
      case 'CartItems1':
        return CartItems1Widget(
          items: cartItems,
          isLoading: isLoading,
          onQuantityChanged: onQuantityChanged,
          onRemove: onRemoveItem,
          config: block,
        );

      case 'PromoCode1':
        return PromoCode1Widget(
          appliedCodes: appliedPromoCodes,
          onTap: onPromoCodeTap ?? () {},
          config: block,
        );

      case 'OrderSummary1':
        return OrderSummary1Widget(
          subtotal: subtotal,
          discount: discount,
          shipping: shipping,
          tax: tax,
          total: total,
          platformFee: platformFee,
          config: block,
        );

      case 'ShippingProgress1':
        // TODO: Implement when VirpanAI builds this variant
        return const SizedBox.shrink();

      case 'Upsell1':
        // TODO: Implement when VirpanAI builds this variant
        return const SizedBox.shrink();

      case 'CheckoutCta1':
        return CheckoutCta1Widget(
          totalAmount: total,
          isLoading: isCheckoutLoading,
          onCheckout: onCheckout ?? () {},
          onContinueShopping: onContinueShopping,
          config: block,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
