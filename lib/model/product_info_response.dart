
import 'dart:convert';

import 'package:waioz/ui/cart_response.dart';

ProductInfoResponse productInfoResponseFromJson(String str) => ProductInfoResponse.fromJson(json.decode(str));

String productInfoResponseToJson(ProductInfoResponse data) => json.encode(data.toJson());

class ProductInfoResponse {
  Cart? cart;
  bool? productOnWishlist;
  String? productWishlistId;
  int? addOnProductCount;
  int? relatedProductCount;
  int? crossSellingProductCount;

  ProductInfoResponse({
    this.cart,
    this.productOnWishlist,
    this.productWishlistId,
    this.addOnProductCount,
    this.relatedProductCount,
    this.crossSellingProductCount,
  });

  factory ProductInfoResponse.fromJson(Map<String, dynamic> json) => ProductInfoResponse(
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
    productOnWishlist: json["product_on_wishlist"],
    productWishlistId: json["product_wishlist_id"],
    addOnProductCount: json["addon_product_count"],
    relatedProductCount: json["related_product_count"],
    crossSellingProductCount: json["cross_selling_product_count"],
  );

  Map<String, dynamic> toJson() => {
    "cart": cart?.toJson(),
    "product_on_wishlist": productOnWishlist,
    "product_wishlist_id": productWishlistId,
    "addon_product_count": addOnProductCount,
    "related_product_count": relatedProductCount,
    "cross_selling_product_count": crossSellingProductCount,
  };
}