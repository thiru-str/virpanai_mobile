// To parse this JSON data, do
//
//     final tagsResponse = tagsResponseFromJson(jsonString);

import 'dart:convert';

TagsResponse tagsResponseFromJson(String str) => TagsResponse.fromJson(json.decode(str));

String tagsResponseToJson(TagsResponse data) => json.encode(data.toJson());

class TagsResponse {
  List<ProductTag>? productTags;
  int? count;
  int? offset;
  int? limit;

  TagsResponse({
    this.productTags,
    this.count,
    this.offset,
    this.limit,
  });

  factory TagsResponse.fromJson(Map<String, dynamic> json) => TagsResponse(
    productTags: json["product_tags"] == null ? [] : List<ProductTag>.from(json["product_tags"]!.map((x) => ProductTag.fromJson(x))),
    count: json["count"],
    offset: json["offset"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "product_tags": productTags == null ? [] : List<dynamic>.from(productTags!.map((x) => x.toJson())),
    "count": count,
    "offset": offset,
    "limit": limit,
  };
}

class ProductTag {
  String? id;
  String? value;
  int? count;

  ProductTag({
    this.id,
    this.value,
    this.count,
  });

  factory ProductTag.fromJson(Map<String, dynamic> json) => ProductTag(
    id: json["id"],
    value: json["value"],
    count: json["count"] is num ? (json["count"] as num).toInt() : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "value": value,
    "count": count,
  };
}
