import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../widgets/app_shimmer.dart';
import '../../../../utility/currency_util.dart';
import '../../../widgets/cart_item_card.dart';

/// CartItems1 - Default cart line items list with quantity controls.
/// Extracted from cart_page.dart cart items ListView section
class CartItems1Widget extends StatelessWidget {
  final List<dynamic> items; // Cart items (filtered, no platform fees)
  final bool isLoading;
  final Set<String> updatingItems; // item IDs currently being updated
  final Function(dynamic item, int newQty)? onQuantityChanged;
  final Function(dynamic item)? onRemove;
  final BlockConfig config;

  const CartItems1Widget({
    super.key,
    required this.items,
    required this.isLoading,
    required this.config,
    this.updatingItems = const {},
    this.onQuantityChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppShimmer(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )),
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final item = items[index];
          final itemId = item.id?.toString() ?? '';
          final isUpdating = updatingItems.contains(itemId);

          return CartItemCard(
            imageUrl: item.thumbnail?.toString() ?? '',
            productName: item.productTitle?.toString() ?? item.title?.toString() ?? '',
            size: item.variantTitle?.toString() ?? '',
            color: '',
            price: CurrencyUtil.appendCurrency(
              item.unitPrice?.toString() ?? item.total?.toString() ?? '0',
            ),
            quantity: item.quantity ?? 1,
            isUpdating: isUpdating,
            onIncrease: () => onQuantityChanged?.call(item, (item.quantity ?? 1) + 1),
            onDecrease: () {
              final qty = item.quantity ?? 1;
              if (qty <= 1) {
                onRemove?.call(item);
              } else {
                onQuantityChanged?.call(item, qty - 1);
              }
            },
            onRemoveAll: () => onRemove?.call(item),
          );
        },
      ),
    );
  }
}
