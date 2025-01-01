// To parse this JSON data, do
//
//     final getWishlistResponse = getWishlistResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

GetWishlistResponse getWishlistResponseFromJson(String str) => GetWishlistResponse.fromJson(json.decode(str));

String getWishlistResponseToJson(GetWishlistResponse data) => json.encode(data.toJson());

class GetWishlistResponse {
  bool? success;
  List<ProductWishlist>? productWishlist;

  GetWishlistResponse({
    this.success,
    this.productWishlist,
  });

  factory GetWishlistResponse.fromJson(Map<String, dynamic> json) => GetWishlistResponse(
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
  DateTime? createdAt;
  DateTime? updatedAt;
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
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "product_id": productId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}