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
  String? collectionId;
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
  Metadata? metadata;
  dynamic type;
  Tion? collection;
  List<ProductOption>? options;
  List<dynamic>? tags;
  List<Image>? images;
  List<Variant>? variants;
  List<ProductWishlistElement>? productReview;
  ProductWishlistElement? productWishlist;
  bool isSelected;

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
    this.metadata,
    this.type,
    this.collection,
    this.options,
    this.tags,
    this.images,
    this.variants,
    this.productReview,
    this.productWishlist,
    this.isSelected = false,
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
    collectionId: json["collection_id"],
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
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    type: json["type"],
    collection: json["collection"] == null ? null : Tion.fromJson(json["collection"]),
    options: json["options"] == null
        ? []
        : List<ProductOption>.from(
        json["options"].map((x) => ProductOption.fromJson(x))),
    tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
    images: json["images"] == null ? [] : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
    variants: json["variants"] == null ? [] : List<Variant>.from(json["variants"]!.map((x) => Variant.fromJson(x))),
    productReview: json["product_review"] == null ? [] : List<ProductWishlistElement>.from(json["product_review"]!.map((x) => ProductWishlistElement.fromJson(x))),
    productWishlist: json["product_wishlist"] == null ? null : ProductWishlistElement.fromJson(json["product_wishlist"]),

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
    "collection_id": collectionId,
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
    "metadata": metadata?.toJson(),
    "type": type,
    "collection": collection?.toJson(),
    "options": options == null
        ? []
        : List<dynamic>.from(options!.map((x) => x.toJson())),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x.toJson())),
    "product_review": productReview == null ? [] : List<dynamic>.from(productReview!.map((x) => x.toJson())),
    "product_wishlist": productWishlist?.toJson(),
  };
}

class Metadata {
  ReviewSummary? reviewSummary;
  String? additionalDescription;

  Metadata({
    this.reviewSummary,
    this.additionalDescription,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    reviewSummary: json["review_summary"] == null ? null : ReviewSummary.fromJson(json["review_summary"]),
    additionalDescription: json["additional_description"],
  );

  Map<String, dynamic> toJson() => {
    "review_summary": reviewSummary?.toJson(),
    "additional_description": additionalDescription,
  };
}

class ReviewSummary {
  String? totalReviews;
  String? averageRating;

  ReviewSummary({
    this.totalReviews,
    this.averageRating,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => ReviewSummary(
    totalReviews: json["total_reviews"],
    averageRating: json["average_rating"],
  );

  Map<String, dynamic> toJson() => {
    "total_reviews": totalReviews,
    "average_rating": averageRating,
  };
}

class Tion {
  String? id;
  String? title;
  String? handle;
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
    title: json["title"],
    handle: json["handle"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    metadata: json["metadata"],
    deletedAt: json["deleted_at"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "handle": handle,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "metadata": metadata,
    "deleted_at": deletedAt,
    "product_id": productId,
  };
}

class Image {
  String? id;
  String? url;
  dynamic metadata;
  int? rank;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? title;
  List<Value>? values;

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
    title: json["title"],
    values: json["values"] == null ? [] : List<Value>.from(json["values"]!.map((x) => Value.fromJson(x))),
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
    "title": title,
    "values": values == null ? [] : List<dynamic>.from(values!.map((x) => x.toJson())),
  };
}

class Value {
  String? id;
  String? value;
  dynamic metadata;
  String? optionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  Tion? option;

  Value({
    this.id,
    this.value,
    this.metadata,
    this.optionId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.option,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
    id: json["id"],
    value: json["value"],
    metadata: json["metadata"],
    optionId: json["option_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    option: json["option"] == null ? null : Tion.fromJson(json["option"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "value": value,
    "metadata": metadata,
    "option_id": optionId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "option": option?.toJson(),
  };
}

class ProductWishlistElement {
  String? id;
  String? customerId;
  String? productId;
  String? rating;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  ProductWishlistElement({
    this.id,
    this.customerId,
    this.productId,
    this.rating,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProductWishlistElement.fromJson(Map<String, dynamic> json) => ProductWishlistElement(
    id: json["id"],
    customerId: json["customer_id"],
    productId: json["product_id"],
    rating: json["rating"],
    description: json["description"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "product_id": productId,
    "rating": rating,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Variant {
  String? id;
  String? title;
  String? sku;
  dynamic barcode;
  dynamic ean;
  dynamic upc;
  bool? allowBackorder;
  bool? manageInventory;
  int? inventoryQuantity;
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
  List<Value>? options;
  CalculatedPrice? calculatedPrice;

  Variant({
    this.id,
    this.title,
    this.sku,
    this.barcode,
    this.ean,
    this.upc,
    this.allowBackorder,
    this.manageInventory,
    this.inventoryQuantity,
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
    this.calculatedPrice,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    id: json["id"],
    title: json["title"],
    sku: json["sku"],
    barcode: json["barcode"],
    ean: json["ean"],
    upc: json["upc"],
    allowBackorder: json["allow_backorder"],
    manageInventory: json["manage_inventory"],
    inventoryQuantity: json["inventory_quantity"],
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
    options: json["options"] == null ? [] : List<Value>.from(json["options"]!.map((x) => Value.fromJson(x))),
    calculatedPrice: json["calculated_price"] == null ? null : CalculatedPrice.fromJson(json["calculated_price"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "sku": sku,
    "barcode": barcode,
    "ean": ean,
    "upc": upc,
    "allow_backorder": allowBackorder,
    "manage_inventory": manageInventory,
    "inventory_quantity": inventoryQuantity,
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
    "calculated_price": calculatedPrice?.toJson(),
  };
}

class CalculatedPrice {
  String? id;
  bool? isCalculatedPricePriceList;
  bool? isCalculatedPriceTaxInclusive;
  num? calculatedAmount;
  RawAmount? rawCalculatedAmount;
  bool? isOriginalPricePriceList;
  bool? isOriginalPriceTaxInclusive;
  num? originalAmount;
  RawAmount? rawOriginalAmount;
  String? currencyCode;
  Price? calculatedPrice;
  Price? originalPrice;

  CalculatedPrice({
    this.id,
    this.isCalculatedPricePriceList,
    this.isCalculatedPriceTaxInclusive,
    this.calculatedAmount,
    this.rawCalculatedAmount,
    this.isOriginalPricePriceList,
    this.isOriginalPriceTaxInclusive,
    this.originalAmount,
    this.rawOriginalAmount,
    this.currencyCode,
    this.calculatedPrice,
    this.originalPrice,
  });

  factory CalculatedPrice.fromJson(Map<String, dynamic> json) => CalculatedPrice(
    id: json["id"],
    isCalculatedPricePriceList: json["is_calculated_price_price_list"],
    isCalculatedPriceTaxInclusive: json["is_calculated_price_tax_inclusive"],
    calculatedAmount: json["calculated_amount"],
    rawCalculatedAmount: json["raw_calculated_amount"] == null ? null : RawAmount.fromJson(json["raw_calculated_amount"]),
    isOriginalPricePriceList: json["is_original_price_price_list"],
    isOriginalPriceTaxInclusive: json["is_original_price_tax_inclusive"],
    originalAmount: json["original_amount"],
    rawOriginalAmount: json["raw_original_amount"] == null ? null : RawAmount.fromJson(json["raw_original_amount"]),
    currencyCode: json["currency_code"],
    calculatedPrice: json["calculated_price"] == null ? null : Price.fromJson(json["calculated_price"]),
    originalPrice: json["original_price"] == null ? null : Price.fromJson(json["original_price"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_calculated_price_price_list": isCalculatedPricePriceList,
    "is_calculated_price_tax_inclusive": isCalculatedPriceTaxInclusive,
    "calculated_amount": calculatedAmount,
    "raw_calculated_amount": rawCalculatedAmount?.toJson(),
    "is_original_price_price_list": isOriginalPricePriceList,
    "is_original_price_tax_inclusive": isOriginalPriceTaxInclusive,
    "original_amount": originalAmount,
    "raw_original_amount": rawOriginalAmount?.toJson(),
    "currency_code": currencyCode,
    "calculated_price": calculatedPrice?.toJson(),
    "original_price": originalPrice?.toJson(),
  };
}

class Price {
  String? id;
  dynamic priceListId;
  dynamic priceListType;
  dynamic minQuantity;
  dynamic maxQuantity;

  Price({
    this.id,
    this.priceListId,
    this.priceListType,
    this.minQuantity,
    this.maxQuantity,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    id: json["id"],
    priceListId: json["price_list_id"],
    priceListType: json["price_list_type"],
    minQuantity: json["min_quantity"],
    maxQuantity: json["max_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "price_list_id": priceListId,
    "price_list_type": priceListType,
    "min_quantity": minQuantity,
    "max_quantity": maxQuantity,
  };
}

class RawAmount {
  String? value;
  int? precision;

  RawAmount({
    this.value,
    this.precision,
  });

  factory RawAmount.fromJson(Map<String, dynamic> json) => RawAmount(
    value: json["value"],
    precision: json["precision"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "precision": precision,
  };
}

class ProductOption {
  String? id;
  String? title;
  List<Value>? values;

  ProductOption({this.id, this.title, this.values});

  factory ProductOption.fromJson(Map<String, dynamic> json) => ProductOption(
    id: json["id"],
    title: json["title"],
    values: json["values"] == null
        ? []
        : List<Value>.from(
        json["values"].map((x) => Value.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "values":
    values == null ? [] : List<dynamic>.from(values!.map((x) => x.toJson())),
  };
}

class ProductImage {
  String? id;
  String? url;
  dynamic metadata;
  int? rank;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  ProductImage({
    this.id,
    this.url,
    this.metadata,
    this.rank,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    id: json["id"],
    url: json["url"],
    metadata: json["metadata"],
    rank: json["rank"],
    productId: json["product_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
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
  };
}

