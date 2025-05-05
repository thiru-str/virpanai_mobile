import 'dart:convert';

import 'package:waioz/model/product_category_response.dart';

FilterCategoryResponse filterCategoryResponseFromJson(String str) => FilterCategoryResponse.fromJson(json.decode(str));

String filterCategoryResponseToJson(FilterCategoryResponse data) => json.encode(data.toJson());

class FilterCategoryResponse {
  List<ProductCategory>? productCategories;
  int? count;
  int? offset;
  int? limit;

  FilterCategoryResponse({
    this.productCategories,
    this.count,
    this.offset,
    this.limit,
  });

  factory FilterCategoryResponse.fromJson(Map<String, dynamic> json) => FilterCategoryResponse(
    productCategories: json["product_categories"] == null ? [] : List<ProductCategory>.from(json["product_categories"]!.map((x) => ProductCategory.fromJson(x))),
    count: json["count"],
    offset: json["offset"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "product_categories": productCategories == null ? [] : List<dynamic>.from(productCategories!.map((x) => x.toJson())),
    "count": count,
    "offset": offset,
    "limit": limit,
  };
}