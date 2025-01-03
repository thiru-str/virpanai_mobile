// To parse this JSON data, do
//
//     final productDetailReponse = productDetailReponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

ProductDetailReponse productDetailReponseFromJson(String str) => ProductDetailReponse.fromJson(json.decode(str));

String productDetailReponseToJson(ProductDetailReponse data) => json.encode(data.toJson());


class ProductDetailReponse {
  Product? product;

  ProductDetailReponse({
    this.product,
  });

  factory ProductDetailReponse.fromJson(Map<String, dynamic> json) => ProductDetailReponse(
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "product": product?.toJson(),
  };
}