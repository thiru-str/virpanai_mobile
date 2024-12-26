// To parse this JSON data, do
//
//     final productCategoriesResponse = productCategoriesResponseFromJson(jsonString);

import 'dart:convert';

ProductCategoriesResponse productCategoriesResponseFromJson(String str) => ProductCategoriesResponse.fromJson(json.decode(str));

String productCategoriesResponseToJson(ProductCategoriesResponse data) => json.encode(data.toJson());

class ProductCategoriesResponse {
  List<ProductCategory>? productCategories;
  String? count;
  int? offset;
  int? limit;

  ProductCategoriesResponse({
    this.productCategories,
    this.count,
    this.offset,
    this.limit,
  });

  factory ProductCategoriesResponse.fromJson(Map<String, dynamic> json) => ProductCategoriesResponse(
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

class ProductCategory {
  String? id;
  String? name;
  String? description;
  String? handle;
  int? rank;
  String? parentCategoryId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic metadata;
  ProductCategory? parentCategory;
  List<ProductCategory>? categoryChildren;
  String? mpath;
  bool? isActive;
  bool? isInternal;
  String? image;

  ProductCategory({
    this.id,
    this.name,
    this.description,
    this.handle,
    this.rank,
    this.parentCategoryId,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.parentCategory,
    this.categoryChildren,
    this.mpath,
    this.isActive,
    this.isInternal,
    this.image,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    handle: json["handle"],
    rank: json["rank"],
    parentCategoryId: json["parent_category_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    metadata: json["metadata"],
    parentCategory: json["parent_category"] == null ? null : ProductCategory.fromJson(json["parent_category"]),
    categoryChildren: json["category_children"] == null ? [] : List<ProductCategory>.from(json["category_children"]!.map((x) => ProductCategory.fromJson(x))),
    mpath: json["mpath"],
    isActive: json["is_active"],
    isInternal: json["is_internal"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "handle": handle,
    "rank": rank,
    "parent_category_id": parentCategoryId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "metadata": metadata,
    "parent_category": parentCategory?.toJson(),
    "category_children": categoryChildren == null ? [] : List<dynamic>.from(categoryChildren!.map((x) => x.toJson())),
    "mpath": mpath,
    "is_active": isActive,
    "is_internal": isInternal,
    "image": image,
  };
}
