// To parse this JSON data, do
//
//     final wishlistResponse = wishlistResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

WishlistResponse wishlistResponseFromJson(String str) => WishlistResponse.fromJson(json.decode(str));

String wishlistResponseToJson(WishlistResponse data) => json.encode(data.toJson());

class WishlistResponse {
  bool? success;
  List<ProductWishlist>? productWishlist;

  WishlistResponse({
    this.success,
    this.productWishlist,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) => WishlistResponse(
    success: json["success"],
    productWishlist: json["product_wishlist"] == null ? [] : List<ProductWishlist>.from(json["product_wishlist"]!.map((x) => ProductWishlist.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "product_wishlist": productWishlist == null ? [] : List<dynamic>.from(productWishlist!.map((x) => x.toJson())),
  };
}

class ProductWishlist {
  String? id;
  String? customerId;
  String? productId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  List<Product>? products;

  ProductWishlist({
    this.id,
    this.customerId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.products,
  });

  factory ProductWishlist.fromJson(Map<String, dynamic> json) => ProductWishlist(
    id: json["id"],
    customerId: json["customer_id"],
    productId: json["product_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "product_id": productId,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}