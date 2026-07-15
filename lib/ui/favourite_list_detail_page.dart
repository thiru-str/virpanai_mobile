import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/product_response.dart' hide Image;
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/cart_response.dart' hide Product;
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:waioz/utility/page_route_utils.dart';

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
  bool _isListView = true;
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
              p.wishlistItemId!: WishlistGroupProduct(
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
        variantId: product.savedVariantId,
        listId: widget.listId,
      );
      if (mounted) {
        setState(() {
          products.removeWhere((p) => p.wishlistItemId == product.wishlistItemId);
          itemMap.remove(product.wishlistItemId);
        });
      }
    } catch (_) {}
  }

  Future<void> _updateQty(Product product, int delta) async {
    final item = itemMap[product.wishlistItemId ?? ''];
    if (item == null || item.id == null) return;
    final current = int.tryParse(item.quantity ?? '1') ?? 1;
    final next = (current + delta).clamp(1, 999);
    if (next == current) return;
    try {
      await _api.updateFavouriteListItemQty(context, item.id!, next);
      if (mounted) {
        setState(() {
          itemMap[product.wishlistItemId ?? ''] = WishlistGroupProduct(
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
    // Check if cart already has items — only ask the user what to do if it does
    bool cartHasItems = false;
    try {
      final cartRes = await _api.getCart(context);
      cartHasItems = (cartRes.cart?.items?.isNotEmpty ?? false);
    } catch (_) {
      // Can't reach cart or no cart yet — treat as empty
    }

    String choice = 'keep';
    if (cartHasItems) {
      final picked = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _MoveToCartSheet(productCount: products.length),
      );
      if (picked == null) return;
      choice = picked;
    }

    setState(() => movingToCart = true);
    try {
      final res = await _api.moveFavouriteListToCart(
        context,
        widget.listId,
        clearExistingCart: choice == 'clear',
      );
      _showResultBanner(res.addedCount ?? 0, res.skippedCount ?? 0);
    } catch (_) {
      Fluttertoast.showToast(msg: 'Added to cart');
    } finally {
      if (mounted) setState(() => movingToCart = false);
    }
  }

  void _showResultBanner(int added, int skipped) {
    Fluttertoast.showToast(
      msg: added > 0
          ? 'Added $added item${added != 1 ? 's' : ''} to cart${skipped > 0 ? ', $skipped skipped' : ''}.'
          : 'No items could be added.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                      color: const Color(0xFF272727),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.listName,
                            style: FontUtils.secondaryFontStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF272727),
                            ),
                          ),
                          if (!loading && products.isNotEmpty)
                            Text(
                              '${products.length} item${products.length != 1 ? 's' : ''}',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!loading && products.isNotEmpty)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isListView = !_isListView),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _isListView
                                ? Icons.grid_view_rounded
                                : Icons.view_list_rounded,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          Expanded(
            child: loading
                ? _buildSkeleton()
                : products.isEmpty
                    ? _buildEmpty()
                    : FadeTransition(
                        opacity: _fadeCtrl,
                        child:
                            _isListView ? _buildList() : _buildGrid(),
                      ),
          ),

          // ── Bottom action bar ────────────────────────────────────
          if (!loading && products.isNotEmpty)
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: movingToCart ? null : _moveAllToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: movingToCart
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Add ${products.length} item${products.length != 1 ? 's' : ''} to Cart',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  Container(
                      height: 10,
                      width: 70,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
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
  }

  void _openProduct(Product product) {
    if (product.id == null) return;
    PageRouteUtils.pushWithSlide(
      context,
      ProductDetailPage(productId: product.id!),
    ).then((_) => _loadProducts());
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => _WishlistGridCard(
          key: ValueKey(products[i].wishlistItemId ?? products[i].id ?? i.toString()),
          product: products[i],
          config: widget.config,
          item: itemMap[products[i].wishlistItemId ?? ''],
          onRemove: () async => _removeProduct(products[i]),
          onQtyChange: (delta) => _updateQty(products[i], delta),
          onTap: () => _openProduct(products[i]),
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _WishlistListCard(
          key: ValueKey(products[i].wishlistItemId ?? products[i].id ?? i.toString()),
          product: products[i],
          config: widget.config,
          item: itemMap[products[i].wishlistItemId ?? ''],
          onRemove: () async => _removeProduct(products[i]),
          onQtyChange: (delta) => _updateQty(products[i], delta),
          onTap: () => _openProduct(products[i]),
        ),
      ),
    );
  }
}

// ── Grid card ─────────────────────────────────────────────────────────────────

class _WishlistGridCard extends StatefulWidget {
  final Product product;
  final FavouriteListConfig config;
  final WishlistGroupProduct? item;
  final Future<void> Function() onRemove;
  final ValueChanged<int> onQtyChange;
  final VoidCallback onTap;

  const _WishlistGridCard({
    super.key,
    required this.product,
    required this.config,
    required this.item,
    required this.onRemove,
    required this.onQtyChange,
    required this.onTap,
  });

  @override
  State<_WishlistGridCard> createState() => _WishlistGridCardState();
}

class _WishlistGridCardState extends State<_WishlistGridCard> {
  bool _removing = false;

  String? _priceStr() {
    final amt = widget.product.variants?.firstOrNull
        ?.calculatedPrice?.calculatedAmount;
    if (amt == null) return null;
    return '₹${amt.toStringAsFixed(0)}';
  }

  String? _origPriceStr() {
    final v = widget.product.variants?.firstOrNull;
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

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removing
                        ? null
                        : () async {
                            setState(() => _removing = true);
                            try {
                              await widget.onRemove();
                            } catch (_) {
                              if (mounted) setState(() => _removing = false);
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: _removing
                          ? Padding(
                              padding: const EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.grey.shade400,
                              ),
                            )
                          : Icon(Icons.close,
                              size: 14, color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
      ), // GestureDetector
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF4F4F4),
        child:
            Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 32),
      );
}

// ── List card ─────────────────────────────────────────────────────────────────

class _WishlistListCard extends StatefulWidget {
  final Product product;
  final FavouriteListConfig config;
  final WishlistGroupProduct? item;
  final Future<void> Function() onRemove;
  final ValueChanged<int> onQtyChange;
  final VoidCallback onTap;

  const _WishlistListCard({
    super.key,
    required this.product,
    required this.config,
    required this.item,
    required this.onRemove,
    required this.onQtyChange,
    required this.onTap,
  });

  @override
  State<_WishlistListCard> createState() => _WishlistListCardState();
}

class _WishlistListCardState extends State<_WishlistListCard> {
  bool _removing = false;

  String? _priceStr() {
    final amt = widget.product.variants?.firstOrNull
        ?.calculatedPrice?.calculatedAmount;
    if (amt == null) return null;
    return '₹${amt.toStringAsFixed(0)}';
  }

  String? _origPriceStr() {
    final v = widget.product.variants?.firstOrNull;
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

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 100,
              height: 110,
              child: widget.product.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: widget.product.thumbnail!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFF4F4F4),
                        child: Icon(Icons.image_outlined,
                            color: Colors.grey.shade400, size: 28),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF4F4F4),
                      child: Icon(Icons.image_outlined,
                          color: Colors.grey.shade400, size: 28),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF272727),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (price != null)
                    Row(
                      children: [
                        Text(
                          price,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (origPrice != null) ...[
                          const SizedBox(width: 6),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.config.qtyEnabled)
                        _QtyPill(
                          qty: qty,
                          onDecrement: () => widget.onQtyChange(-1),
                          onIncrement: () => widget.onQtyChange(1),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _removing
                            ? null
                            : () async {
                                setState(() => _removing = true);
                                await Future.microtask(widget.onRemove);
                              },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _removing
                              ? Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Colors.red.shade300,
                                  ),
                                )
                              : Icon(Icons.delete_outline_rounded,
                                  size: 16, color: Colors.red.shade400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ), // GestureDetector
    );
  }
}

// ── Qty pill ──────────────────────────────────────────────────────────────────

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
          _PillBtn(icon: Icons.remove, enabled: qty > 1, onTap: onDecrement),
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
          _PillBtn(icon: Icons.add, enabled: qty < 999, onTap: onIncrement),
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
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
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
}

// ── Move to cart sheet ────────────────────────────────────────────────────────

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
    final accent =
        widget.destructive ? Colors.red.shade400 : AppColors.primary;
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
          color: _pressed
              ? accent.withValues(alpha: 0.06)
              : const Color(0xFFF8F7FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed
                ? accent.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
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
            Icon(Icons.chevron_right,
                color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
