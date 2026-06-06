import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/utility/app_colors.dart';

/// Simple Wishlist heart for product cards (1.6.0).
///
/// Self-contained: handles tap → API → local state. No callback plumbing
/// from the parent needed beyond passing `variantId`, `productId`, and
/// `initialSavedId`.
///
/// `initialSavedId` is the wishlist_item.id when this product is already
/// saved (parent fetches via `ApiService.wishlistIsSaved`), null otherwise.
/// Empty/null `variantId` hides the heart entirely — nothing to save.
class WishlistHeartButton extends StatefulWidget {
  final String variantId;
  final String productId;
  final String? initialSavedId;
  final bool isLoggedIn;
  final double size;

  const WishlistHeartButton({
    super.key,
    required this.variantId,
    required this.productId,
    required this.isLoggedIn,
    this.initialSavedId,
    this.size = 16,
  });

  @override
  State<WishlistHeartButton> createState() => _WishlistHeartButtonState();
}

class _WishlistHeartButtonState extends State<WishlistHeartButton> {
  String? _savedId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _savedId = widget.initialSavedId;
  }

  @override
  void didUpdateWidget(covariant WishlistHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent re-renders (e.g. after refreshing the saved-id set) — sync only
    // if we haven't been touched since the last server snapshot. (`_busy`
    // implies an in-flight mutation; respect that.)
    if (!_busy && oldWidget.initialSavedId != widget.initialSavedId) {
      _savedId = widget.initialSavedId;
    }
  }

  Future<void> _toggle() async {
    if (_busy || !widget.isLoggedIn || widget.variantId.isEmpty) return;

    final api = ApiService();
    final prev = _savedId;

    if (_savedId != null && _savedId!.isNotEmpty) {
      // Remove
      setState(() {
        _busy = true;
        _savedId = null;
      });
      final ok = await api.removeFromWishlist(context, prev!);
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (!ok) _savedId = prev; // revert on failure
      });
    } else {
      // Add
      setState(() {
        _busy = true;
        _savedId = '__pending__';
      });
      final item = await api.addToWishlist(context, widget.variantId, widget.productId);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _savedId = item?['id'] as String? ?? prev; // revert on null
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) return const SizedBox.shrink();
    if (widget.variantId.isEmpty) return const SizedBox.shrink();

    final filled = _savedId != null && _savedId!.isNotEmpty;

    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          filled ? Icons.favorite : Icons.favorite_border,
          size: widget.size,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
