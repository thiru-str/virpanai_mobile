// To parse this JSON data, do
//
//     final productsResponse = productsResponseFromJson(jsonString);

import 'dart:convert';

ProductsResponse productsResponseFromJson(String str) => ProductsResponse.fromJson(json.decode(str));

String productsResponseToJson(ProductsResponse data) => json.encode(data.toJson());

class ProductsResponse {
  List<Product>? products;
  int? count;
  int? offset;
  int? limit;

  ProductsResponse({
    this.products,
    this.count,
    this.offset,
    this.limit,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => ProductsResponse(
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    count: json["count"],
    offset: json["offset"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "count": count,
    "offset": offset,
    "limit": limit,
  };
}

class Product {
  String? id;
  String? title;
  String? subtitle;
  String? description;
  String? handle;
  bool? isGiftcard;
  bool? discountable;
  String? thumbnail;
  CollectionId? collectionId;
  dynamic typeId;
  dynamic weight;
  dynamic length;
  dynamic height;
  dynamic width;
  dynamic hsCode;
  dynamic originCountry;
  dynamic midCode;
  dynamic material;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic type;
  Tion? collection;
  List<Image>? options;
  List<dynamic>? tags;
  List<Image>? images;
  List<Variant>? variants;

  Product({
    this.id,
    this.title,
    this.subtitle,
    this.description,
    this.handle,
    this.isGiftcard,
    this.discountable,
    this.thumbnail,
    this.collectionId,
    this.typeId,
    this.weight,
    this.length,
    this.height,
    this.width,
    this.hsCode,
    this.originCountry,
    this.midCode,
    this.material,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.collection,
    this.options,
    this.tags,
    this.images,
    this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    title: json["title"],
    subtitle: json["subtitle"],
    description: json["description"],
    handle: json["handle"],
    isGiftcard: json["is_giftcard"],
    discountable: json["discountable"],
    thumbnail: json["thumbnail"],
    collectionId: collectionIdValues.map[json["collection_id"]]!,
    typeId: json["type_id"],
    weight: json["weight"],
    length: json["length"],
    height: json["height"],
    width: json["width"],
    hsCode: json["hs_code"],
    originCountry: json["origin_country"],
    midCode: json["mid_code"],
    material: json["material"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    type: json["type"],
    collection: json["collection"] == null ? null : Tion.fromJson(json["collection"]),
    options: json["options"] == null ? [] : List<Image>.from(json["options"]!.map((x) => Image.fromJson(x))),
    tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
    images: json["images"] == null ? [] : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
    variants: json["variants"] == null ? [] : List<Variant>.from(json["variants"]!.map((x) => Variant.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subtitle": subtitle,
    "description": description,
    "handle": handle,
    "is_giftcard": isGiftcard,
    "discountable": discountable,
    "thumbnail": thumbnail,
    "collection_id": collectionIdValues.reverse[collectionId],
    "type_id": typeId,
    "weight": weight,
    "length": length,
    "height": height,
    "width": width,
    "hs_code": hsCode,
    "origin_country": originCountry,
    "mid_code": midCode,
    "material": material,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "type": type,
    "collection": collection?.toJson(),
    "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x.toJson())),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x.toJson())),
  };
}

class Tion {
  String? id;
  CollectionTitle? title;
  Handle? handle;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic metadata;
  dynamic deletedAt;
  String? productId;

  Tion({
    this.id,
    this.title,
    this.handle,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.deletedAt,
    this.productId,
  });

  factory Tion.fromJson(Map<String, dynamic> json) => Tion(
    id: json["id"],
    title: collectionTitleValues.map[json["title"]]!,
    handle: handleValues.map[json["handle"]]!,
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    metadata: json["metadata"],
    deletedAt: json["deleted_at"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": collectionTitleValues.reverse[title],
    "handle": handleValues.reverse[handle],
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "metadata": metadata,
    "deleted_at": deletedAt,
    "product_id": productId,
  };
}

enum Handle {
  WITHOUT_VARIANTS
}

final handleValues = EnumValues({
  "without_variants": Handle.WITHOUT_VARIANTS
});

enum CollectionTitle {
  DEFAULT_OPTION,
  WITHOUT_VARIANTS
}

final collectionTitleValues = EnumValues({
  "Default option": CollectionTitle.DEFAULT_OPTION,
  "Without Variants": CollectionTitle.WITHOUT_VARIANTS
});

enum CollectionId {
  PCOL_01_JF00_GAGRXJJMYZHJKK9_JV5_RQ
}

final collectionIdValues = EnumValues({
  "pcol_01JF00GAGRXJJMYZHJKK9JV5RQ": CollectionId.PCOL_01_JF00_GAGRXJJMYZHJKK9_JV5_RQ
});

class Image {
  String? id;
  String? url;
  dynamic metadata;
  int? rank;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  CollectionTitle? title;
  List<ValueElement>? values;

  Image({
    this.id,
    this.url,
    this.metadata,
    this.rank,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.title,
    this.values,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    id: json["id"],
    url: json["url"],
    metadata: json["metadata"],
    rank: json["rank"],
    productId: json["product_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    title: collectionTitleValues.map[json["title"]]!,
    values: json["values"] == null ? [] : List<ValueElement>.from(json["values"]!.map((x) => ValueElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "metadata": metadata,
    "rank": rank,
    "product_id": productId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "title": collectionTitleValues.reverse[title],
    "values": values == null ? [] : List<dynamic>.from(values!.map((x) => x.toJson())),
  };
}

class ValueElement {
  String? id;
  ValueEnum? value;
  dynamic metadata;
  String? optionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  Tion? option;

  ValueElement({
    this.id,
    this.value,
    this.metadata,
    this.optionId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.option,
  });

  factory ValueElement.fromJson(Map<String, dynamic> json) => ValueElement(
    id: json["id"],
    value: valueEnumValues.map[json["value"]]!,
    metadata: json["metadata"],
    optionId: json["option_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    option: json["option"] == null ? null : Tion.fromJson(json["option"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "value": valueEnumValues.reverse[value],
    "metadata": metadata,
    "option_id": optionId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "option": option?.toJson(),
  };
}

enum ValueEnum {
  DEFAULT_OPTION_VALUE
}

final valueEnumValues = EnumValues({
  "Default option value": ValueEnum.DEFAULT_OPTION_VALUE
});

class Variant {
  String? id;
  VariantTitle? title;
  String? sku;
  dynamic barcode;
  dynamic ean;
  dynamic upc;
  bool? allowBackorder;
  bool? manageInventory;
  dynamic hsCode;
  dynamic originCountry;
  dynamic midCode;
  dynamic material;
  dynamic weight;
  dynamic length;
  dynamic height;
  dynamic width;
  dynamic metadata;
  int? variantRank;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<ValueElement>? options;

  Variant({
    this.id,
    this.title,
    this.sku,
    this.barcode,
    this.ean,
    this.upc,
    this.allowBackorder,
    this.manageInventory,
    this.hsCode,
    this.originCountry,
    this.midCode,
    this.material,
    this.weight,
    this.length,
    this.height,
    this.width,
    this.metadata,
    this.variantRank,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.options,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    id: json["id"],
    title: variantTitleValues.map[json["title"]]!,
    sku: json["sku"],
    barcode: json["barcode"],
    ean: json["ean"],
    upc: json["upc"],
    allowBackorder: json["allow_backorder"],
    manageInventory: json["manage_inventory"],
    hsCode: json["hs_code"],
    originCountry: json["origin_country"],
    midCode: json["mid_code"],
    material: json["material"],
    weight: json["weight"],
    length: json["length"],
    height: json["height"],
    width: json["width"],
    metadata: json["metadata"],
    variantRank: json["variant_rank"],
    productId: json["product_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    options: json["options"] == null ? [] : List<ValueElement>.from(json["options"]!.map((x) => ValueElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": variantTitleValues.reverse[title],
    "sku": sku,
    "barcode": barcode,
    "ean": ean,
    "upc": upc,
    "allow_backorder": allowBackorder,
    "manage_inventory": manageInventory,
    "hs_code": hsCode,
    "origin_country": originCountry,
    "mid_code": midCode,
    "material": material,
    "weight": weight,
    "length": length,
    "height": height,
    "width": width,
    "metadata": metadata,
    "variant_rank": variantRank,
    "product_id": productId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x.toJson())),
  };
}

enum VariantTitle {
  DEFAULT_VARIANT
}

final variantTitleValues = EnumValues({
  "Default variant": VariantTitle.DEFAULT_VARIANT
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
