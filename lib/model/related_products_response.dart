// To parse this JSON data, do
//
//     final productsResponse = productsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

RelatedProductsResponse productsResponseFromJson(String str) =>
    RelatedProductsResponse.fromJson(json.decode(str));

String productsResponseToJson(RelatedProductsResponse data) =>
    json.encode(data.toJson());

class RelatedProductsResponse {
  List<Product>? products;
  int? count;
  int? offset;
  int? limit;
  String? label;

  RelatedProductsResponse({
    this.products,
    this.count,
    this.offset,
    this.limit,
    this.label,
  });

  factory RelatedProductsResponse.fromJson(Map<String, dynamic> json) =>
      RelatedProductsResponse(
        products: json["related_product"] == null
            ? []
            : List<Product>.from(
                json["related_product"]!.map((x) => Product.fromJson(x))),
        label: json["label"],
      );

  Map<String, dynamic> toJson() => {
        "related_product": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "label": label,
      };
}
