
import 'dart:convert';

import 'package:waioz/ui/cart_response.dart';

ProductInfoResponse productInfoResponseFromJson(String str) => ProductInfoResponse.fromJson(json.decode(str));

String productInfoResponseToJson(ProductInfoResponse data) => json.encode(data.toJson());

class ProductInfoResponse {
  Cart? cart;
  bool? productOnWishlist;

  ProductInfoResponse({
    this.cart,
    this.productOnWishlist,
  });

  factory ProductInfoResponse.fromJson(Map<String, dynamic> json) => ProductInfoResponse(
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
    productOnWishlist: json["product_on_wishlist"],
  );

  Map<String, dynamic> toJson() => {
    "cart": cart?.toJson(),
    "product_on_wishlist": productOnWishlist,
  };
}