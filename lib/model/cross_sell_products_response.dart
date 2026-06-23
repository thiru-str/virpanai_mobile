import 'dart:convert';

import 'package:waioz/model/product_response.dart';

CrossSellProductsResponse crossSellProductsResponseFromJson(String str) =>
    CrossSellProductsResponse.fromJson(json.decode(str));

String crossSellProductsResponseToJson(CrossSellProductsResponse data) =>
    json.encode(data.toJson());

class CrossSellProductsResponse {
  List<Product>? products;
  String? label;

  CrossSellProductsResponse({
    this.products,
    this.label,
  });

  factory CrossSellProductsResponse.fromJson(Map<String, dynamic> json) =>
      CrossSellProductsResponse(
        products: json["cross_selling_product"] == null
            ? []
            : List<Product>.from(
                json["cross_selling_product"]!.map((x) => Product.fromJson(x)),
              ),
        label: json["label"],
      );

  Map<String, dynamic> toJson() => {
        "cross_selling_product": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "label": label,
      };
}
