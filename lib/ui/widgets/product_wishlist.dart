// To parse this JSON data, do
//
//     final wishListResponse = wishListResponseFromJson(jsonString);

import 'dart:convert';

WishListResponse wishListResponseFromJson(String str) => WishListResponse.fromJson(json.decode(str));

String wishListResponseToJson(WishListResponse data) => json.encode(data.toJson());

class WishListResponse {
  ProductWishlist? productWishlist;

  WishListResponse({
    this.productWishlist,
  });

  factory WishListResponse.fromJson(Map<String, dynamic> json) => WishListResponse(
    productWishlist: json["product_wishlist"] == null ? null : ProductWishlist.fromJson(json["product_wishlist"]),
  );

  Map<String, dynamic> toJson() => {
    "product_wishlist": productWishlist?.toJson(),
  };
}

class ProductWishlist {
  String? id;
  String? customerId;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  ProductWishlist({
    this.id,
    this.customerId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProductWishlist.fromJson(Map<String, dynamic> json) => ProductWishlist(
    id: json["id"],
    customerId: json["customer_id"],
    productId: json["product_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "product_id": productId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
