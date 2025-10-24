import 'package:flutter/cupertino.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/product_card_1.dart';
import 'package:waioz/ui/widgets/product_card_2.dart';
import 'package:waioz/ui/widgets/product_card_3.dart';
import 'package:waioz/ui/widgets/product_card_4.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../model/product_response.dart';

class ProductView extends StatefulWidget {
  final Product product;
  final String? type; // made optional
  final VoidCallback onTapCard;
  final VoidCallback? onTapFavorite;
  final VoidCallback? onAddToCart;
  final bool isFavorite;

  const ProductView({
    Key? key,
    required this.product,
    this.type,
    required this.onTapCard,
    this.onTapFavorite,
    this.onAddToCart,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  ProductCardType? _resolvedType;

  @override
  void initState() {
    super.initState();
    _loadType();
  }

  Future<void> _loadType() async {
    final savedTypeString = await SharedPreferencesUtil().getString('product_view');

    setState(() {
      _resolvedType = _mapStringToType(widget.type) ??
          _mapStringToType(savedTypeString) ??
          ProductCardType.productView1;
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
        );

      case ProductCardType.productView2:
        return ProductCard2(
          product: widget.product,
          onTapCard: widget.onTapCard,
          onTapFavorite: widget.onTapFavorite,
          onAddToCart: widget.onAddToCart,
          isFavorite: widget.isFavorite,
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
        );
    }
  }
}


enum ProductCardType {
  productView1,
  productView2,
  productView3,
  productView4,
}

