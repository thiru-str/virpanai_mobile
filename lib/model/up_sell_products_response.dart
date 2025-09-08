// To parse this JSON data, do
//
//     final productsResponse = productsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

UpSellProductsResponse productsResponseFromJson(String str) => UpSellProductsResponse.fromJson(json.decode(str));

String productsResponseToJson(UpSellProductsResponse data) => json.encode(data.toJson());

class UpSellProductsResponse {
  List<Product>? products;

  UpSellProductsResponse({
    this.products,
  });

  factory UpSellProductsResponse.fromJson(Map<String, dynamic> json) => UpSellProductsResponse(
    products: json["up_selling_product"] == null ? [] : List<Product>.from(json["up_selling_product"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "up_selling_product": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}
