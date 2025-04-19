// To parse this JSON data, do
//
//     final productCategoryResponse = productCategoryResponseFromJson(jsonString);

import 'dart:convert';

ProductCategoryResponse productCategoryResponseFromJson(String str) => ProductCategoryResponse.fromJson(json.decode(str));

String productCategoryResponseToJson(ProductCategoryResponse data) => json.encode(data.toJson());

class ProductCategoryResponse {
  ProductCategory? productCategory;

  ProductCategoryResponse({
    this.productCategory,
  });

  factory ProductCategoryResponse.fromJson(Map<String, dynamic> json) => ProductCategoryResponse(
    productCategory: json["product_category"] == null ? null : ProductCategory.fromJson(json["product_category"]),
  );

  Map<String, dynamic> toJson() => {
    "product_category": productCategory?.toJson(),
  };
}

class ProductCategory {
  String? id;
  String? name;
  String? description;
  String? handle;
  int? rank;
  dynamic parentCategoryId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic metadata;
  CategoryChild? parentCategory;
  List<CategoryChild>? categoryChildren;

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
    parentCategory: json["parent_category"] == null ? null : CategoryChild.fromJson(json["parent_category"]),
    categoryChildren: json["category_children"] == null ? [] : List<CategoryChild>.from(json["category_children"]!.map((x) => CategoryChild.fromJson(x))),
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
    "parent_category": parentCategory,
    "category_children": categoryChildren == null ? [] : List<dynamic>.from(categoryChildren!.map((x) => x.toJson())),
  };
}

class CategoryChild {
  String? id;
  String? name;
  String? description;
  String? handle;
  String? mpath;
  bool? isActive;
  bool? isInternal;
  int? rank;
  dynamic metadata;
  String? parentCategoryId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  CategoryChild({
    this.id,
    this.name,
    this.description,
    this.handle,
    this.mpath,
    this.isActive,
    this.isInternal,
    this.rank,
    this.metadata,
    this.parentCategoryId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CategoryChild.fromJson(Map<String, dynamic> json) => CategoryChild(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    handle: json["handle"],
    mpath: json["mpath"],
    isActive: json["is_active"],
    isInternal: json["is_internal"],
    rank: json["rank"],
    metadata: json["metadata"],
    parentCategoryId: json["parent_category_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "handle": handle,
    "mpath": mpath,
    "is_active": isActive,
    "is_internal": isInternal,
    "rank": rank,
    "metadata": metadata,
    "parent_category_id": parentCategoryId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
