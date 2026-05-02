import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/product_response.dart' hide Image;
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class FavouriteListDetailPage extends StatefulWidget {
  final String listId;
  final String listName;
  final FavouriteListConfig config;

  const FavouriteListDetailPage({
    super.key,
    required this.listId,
    required this.listName,
    required this.config,
  });

  @override
  State<FavouriteListDetailPage> createState() =>
      _FavouriteListDetailPageState();
}

class _FavouriteListDetailPageState extends State<FavouriteListDetailPage>
    with SingleTickerProviderStateMixin {
  List<Product> products = [];
  Map<String, WishlistGroupProduct> itemMap = {};
  bool loading = true;
  bool movingToCart = false;
  final _api = ApiService();
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final res = await _api.getFavouriteListProducts(context, widget.listId);
      if (!mounted) return;
      final loaded = res.products ?? [];
      setState(() {
        products = loaded;
        itemMap = {
          for (final p in loaded)
            if (p.id != null && p.wishlistItemId != null)
              p.id!: WishlistGroupProduct(
                id: p.wishlistItemId,
                productId: p.id,
                variantId: p.savedVariantId,
                quantity: p.wishlistQty ?? '1',
              )
        };
        loading = false;
      });
      _fadeCtrl.forward();
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _removeProduct(Product product) async {
    try {
      await _api.deleteProductFromFavouriteList(
        context,
        productId: product.id ?? '',
        listId: widget.listId,
      );
      if (mounted) {
        setState(() {
          products.removeWhere((p) => p.id == product.id);
          itemMap.remove(product.id);
        });
      }
    } catch (_) {}
  }

  Future<void> _updateQty(Product product, int delta) async {
    final item = itemMap[product.id ?? ''];
    if (item == null || item.id == null) return;
    final current = int.tryParse(item.quantity ?? '1') ?? 1;
    final next = (current + delta).clamp(1, 999);
    if (next == current) return;
    try {
      await _api.updateFavouriteListItemQty(context, item.id!, next);
      if (mounted) {
        setState(() {
          itemMap[product.id ?? ''] = WishlistGroupProduct(
            id: item.id,
            customerWishlistGroupId: item.customerWishlistGroupId,
            customerId: item.customerId,
            productId: item.productId,
            variantId: item.variantId,
            quantity: next.toString(),
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _moveAllToCart() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoveToCartSheet(productCount: products.length),
    );
    if (choice == null) return;

    setState(() => movingToCart = true);
    try {
      final res = await _api.moveFavouriteListToCart(
        context,
        widget.listId,
        clearExistingCart: choice == 'clear',
      );
      if (mounted) {
        final added = res.addedCount ?? 0;
        final skipped = res.skippedCount ?? 0;
        _showResultBanner(added, skipped);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => movingToCart = false);
    }
  }

  void _showResultBanner(int added, int skipped) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: const Color(0xFF272727),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                added > 0
                    ? 'Added $added item${added != 1 ? 's' : ''} to cart${skipped > 0 ? ', $skipped skipped' : ''}.'
                    : 'No items could be added.',
                style: FontUtils.primaryFontStyle(
                    fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.listName,
          style: FontUtils.secondaryFontStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF272727),
          ),
        ),
        actions: [
          if (!loading && products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: movingToCart ? null : _moveAllToCart,
                child: AnimatedOpacity(
                  opacity: movingToCart ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF272727),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: movingToCart
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            children: [
                              const Icon(Icons.shopping_cart_outlined,
                                  color: Colors.white, size: 15),
                              const SizedBox(width: 5),
                              Text(
                                'Add all',
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: loading
          ? _buildSkeleton()
          : products.isEmpty
              ? _buildEmpty()
              : _buildGrid(),
    );
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      AppColors.primary.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(Icons.favorite_border_rounded,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Nothing here yet',
                style: FontUtils.secondaryFontStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Save products to this list from any product page.',
                style: FontUtils.primaryFontStyle(
                    fontSize: 13, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildGrid() {
    return FadeTransition(
      opacity: _fadeCtrl,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => _WishlistProductCard(
          product: products[i],
          config: widget.config,
          item: itemMap[products[i].id ?? ''],
          onRemove: () => _removeProduct(products[i]),
          onQtyChange: (delta) => _updateQty(products[i], delta),
        ),
      ),
    );
  }
}

class _WishlistProductCard extends StatefulWidget {
  final Product product;
  final FavouriteListConfig config;
  final WishlistGroupProduct? item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;

  const _WishlistProductCard({
    required this.product,
    required this.config,
    required this.item,
    required this.onRemove,
    required this.onQtyChange,
  });

  @override
  State<_WishlistProductCard> createState() => _WishlistProductCardState();
}

class _WishlistProductCardState extends State<_WishlistProductCard> {
  bool _removing = false;

  String? _priceStr() {
    final v = widget.product.variants?.isNotEmpty == true
        ? widget.product.variants!.first
        : null;
    final amt = v?.calculatedPrice?.calculatedAmount;
    if (amt == null) return null;
    return '₹${amt.toStringAsFixed(0)}';
  }

  String? _origPriceStr() {
    final v = widget.product.variants?.isNotEmpty == true
        ? widget.product.variants!.first
        : null;
    final calc = v?.calculatedPrice?.calculatedAmount;
    final orig = v?.calculatedPrice?.originalAmount;
    if (orig == null || calc == null || orig <= calc) return null;
    return '₹${orig.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final qty = int.tryParse(widget.item?.quantity ?? '1') ?? 1;
    final price = _priceStr();
    final origPrice = _origPriceStr();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with remove button overlay
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: widget.product.thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: widget.product.thumbnail!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFF4F4F4),
                            child: Icon(Icons.image_outlined,
                                color: Colors.grey.shade400, size: 32),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF4F4F4),
                          child: Icon(Icons.image_outlined,
                              color: Colors.grey.shade400, size: 32),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removing
                        ? null
                        : () async {
                            setState(() => _removing = true);
                            await Future.microtask(widget.onRemove);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4)
                        ],
                      ),
                      child: _removing
                          ? Padding(
                              padding: const EdgeInsets.all(7),
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.grey.shade500),
                            )
                          : Icon(Icons.close,
                              size: 15, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF272727),
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (origPrice != null) ...[
                        const SizedBox(width: 5),
                        Text(
                          origPrice,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (widget.config.qtyEnabled) ...[
                  const SizedBox(height: 8),
                  _QtyPill(
                    qty: qty,
                    onDecrement: () => widget.onQtyChange(-1),
                    onIncrement: () => widget.onQtyChange(1),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyPill({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillBtn(
            icon: Icons.remove,
            enabled: qty > 1,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$qty',
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF272727),
              ),
            ),
          ),
          _PillBtn(
            icon: Icons.add,
            enabled: qty < 999,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PillBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 3,
                        offset: const Offset(0, 1))
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 14,
            color: enabled ? const Color(0xFF272727) : Colors.grey.shade400,
          ),
        ),
      );
}

class _MoveToCartSheet extends StatelessWidget {
  final int productCount;

  const _MoveToCartSheet({required this.productCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add all to cart',
            style: FontUtils.secondaryFontStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$productCount product${productCount != 1 ? 's' : ''} will be added.',
            style: FontUtils.primaryFontStyle(
                fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          _CartOptionTile(
            icon: Icons.playlist_add_rounded,
            title: 'Keep cart & add',
            subtitle: 'Existing cart items stay.',
            onTap: () => Navigator.pop(context, 'keep'),
          ),
          const SizedBox(height: 10),
          _CartOptionTile(
            icon: Icons.delete_sweep_outlined,
            title: 'Clear cart & add',
            subtitle: 'Start fresh with this list.',
            destructive: true,
            onTap: () => Navigator.pop(context, 'clear'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Cancel',
              style: FontUtils.primaryFontStyle(
                  fontSize: 14, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartOptionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _CartOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  State<_CartOptionTile> createState() => _CartOptionTileState();
}

class _CartOptionTileState extends State<_CartOptionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.destructive ? Colors.red.shade400 : AppColors.primary;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? accent.withOpacity(0.06) : const Color(0xFFF8F7FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed ? accent.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF272727),
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
