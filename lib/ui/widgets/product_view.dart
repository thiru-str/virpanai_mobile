import 'package:flutter/cupertino.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/product_card_1.dart';
import 'package:waioz/ui/widgets/product_card_2.dart';
import 'package:waioz/ui/widgets/product_card_3.dart';
import 'package:waioz/ui/widgets/product_card_4.dart';
import 'package:waioz/ui/widgets/product_card_7.dart';
import 'package:waioz/ui/widgets/product_card_8.dart';
import 'package:waioz/ui/widgets/product_card_9.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../model/product_response.dart';

class ProductView extends StatefulWidget {
  final Product product;
  final String? type;
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final bool isLoggedIn;
  /// wishlist_item.id for product's first variant when already saved
  final String? initialSavedId;

  const ProductView({
    super.key,
    required this.product,
    this.type,
    required this.onTapCard,
    this.onTapFavorite,
    this.onAddToCart,
    this.isFavorite = false,
    this.isLoggedIn = false,
    this.initialSavedId,
  });

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  ProductCardType? _resolvedType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final providedType = _mapStringToType(widget.type);
    if (providedType != null) {
      _resolvedType = providedType;
      _isLoading = false;
      return;
    }
    _loadType();
  }

  Future<void> _loadType() async {
    final savedTypeString =
        await SharedPreferencesUtil().getString('product_view');
    debugPrint('product view $savedTypeString');

    if (!mounted) return;
    setState(() {
      _resolvedType = _mapStringToType(widget.type) ??
          _mapStringToType(savedTypeString) ??
          ProductCardType.productView1;
      debugPrint('product view $_resolvedType');
      _isLoading = false;
    });
  }

  ProductCardType? _mapStringToType(String? type) {
    if (type == null) return null;

    try {
      return ProductCardType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ProductCardType.productView1,
      );
    } catch (_) {
      return ProductCardType.productView1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ProductCardSkeleton();
    }

    if (_resolvedType == null) {
      return ProductCard(
        product: widget.product,
        onTapCard: widget.onTapCard,
        onTapFavorite: widget.onTapFavorite,
        isFavorite: widget.isFavorite,
      );
    }

    switch (_resolvedType!) {
      case ProductCardType.productView1:
        return ProductCard1(
          product: widget.product,
          onTapCard: widget.onTapCard,
          onTapFavorite: widget.onTapFavorite,
          isFavorite: widget.isFavorite,
          isLoggedIn: widget.isLoggedIn,
          initialSavedId: widget.initialSavedId,
        );

      case ProductCardType.productView2:
        return ProductCard2(
          product: widget.product,
          onTapCard: widget.onTapCard,
          onTapFavorite: widget.onTapFavorite,
          onAddToCart: widget.onAddToCart,
          isFavorite: widget.isFavorite,
          isLoggedIn: widget.isLoggedIn,
          initialSavedId: widget.initialSavedId,
        );

      case ProductCardType.productView3:
        return ProductCard3(
          product: widget.product,
          onTapCard: widget.onTapCard,
          onAddToCart: widget.onAddToCart,
        );

      case ProductCardType.productView4:
        return ProductCard4(
          product: widget.product,
          onTapCard: widget.onTapCard,
          onTapFavorite: widget.onTapFavorite,
          onAddToCart: widget.onAddToCart,
          isFavorite: widget.isFavorite,
          isLoggedIn: widget.isLoggedIn,
          initialSavedId: widget.initialSavedId,
        );

      case ProductCardType.productView7:
        return ProductCard7(
          product: widget.product,
          onTapCard: widget.onTapCard,
        );

      case ProductCardType.productView8:
        return ProductCard8(
          product: widget.product,
          onTapCard: widget.onTapCard,
        );

      case ProductCardType.productView9:
        return ProductCard9(
          product: widget.product,
          onTapCard: widget.onTapCard,
          onTapFavorite: widget.onTapFavorite,
          onAddToCart: widget.onAddToCart,
          isFavorite: widget.isFavorite,
          isLoggedIn: widget.isLoggedIn,
          initialSavedId: widget.initialSavedId,
        );
    }
  }
}

enum ProductCardType {
  productView1,
  productView2,
  productView3,
  productView4,
  productView7,
  productView8,
  productView9,
}
