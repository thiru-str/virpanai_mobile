// To parse this JSON data, do
//
//     final productsResponse = productsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

AddOnProductsResponse productsResponseFromJson(String str) => AddOnProductsResponse.fromJson(json.decode(str));

String productsResponseToJson(AddOnProductsResponse data) => json.encode(data.toJson());

class AddOnProductsResponse {
  List<Product>? products;

  AddOnProductsResponse({
    this.products,
  });

  factory AddOnProductsResponse.fromJson(Map<String, dynamic> json) => AddOnProductsResponse(
    products: json["addon_product"] == null ? [] : List<Product>.from(json["addon_product"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "addon_product": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}
