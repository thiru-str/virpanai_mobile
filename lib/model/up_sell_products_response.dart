// To parse this JSON data, do
//
//     final productsResponse = productsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

UpSellProductsResponse productsResponseFromJson(String str) =>
    UpSellProductsResponse.fromJson(json.decode(str));

String productsResponseToJson(UpSellProductsResponse data) =>
    json.encode(data.toJson());

class UpSellProductsResponse {
  List<Product>? products;
  String? label;

  UpSellProductsResponse({
    this.products,
    this.label,
  });

  factory UpSellProductsResponse.fromJson(Map<String, dynamic> json) =>
      UpSellProductsResponse(
        products: json["up_selling_product"] == null
            ? []
            : List<Product>.from(
                json["up_selling_product"]!.map((x) => Product.fromJson(x))),
        label: json["label"],
      );

  Map<String, dynamic> toJson() => {
        "up_selling_product": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "label": label,
      };
}
