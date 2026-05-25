// To parse this JSON data, do
//
//     final wishlistResponse = wishlistResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/product_response.dart';

WishlistResponse wishlistResponseFromJson(String str) =>
    WishlistResponse.fromJson(json.decode(str));

String wishlistResponseToJson(WishlistResponse data) =>
    json.encode(data.toJson());

class WishlistResponse {
  bool? success;
  List<Product>? products;
  ProductWishlistElement? wishlistElement;
  bool? enabled;
  String? displayName;
  bool? wishlistGroup;
  bool? resetCart;
  bool? overrideCart;
  bool? quantityManage;
  List<CustomerWishlistGroup>? customerWishlistGroup;
  WishlistGroupProduct? wishlistGroupProduct;
  CustomerWishlistGroup? createdWishlistGroup;

  WishlistResponse({
    this.success,
    this.products,
    this.wishlistElement,
    this.enabled,
    this.displayName,
    this.wishlistGroup,
    this.resetCart,
    this.overrideCart,
    this.quantityManage,
    this.customerWishlistGroup,
    this.wishlistGroupProduct,
    this.createdWishlistGroup,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) =>
      WishlistResponse(
        success: json["success"],
        enabled: json["enabled"],
        displayName: json["display_name"],
        wishlistGroup: json["wishlist_group"],
        resetCart: json["reset_cart"],
        overrideCart: json["override_cart"],
        quantityManage: json["quantity_manage"],
        products: json["products"] == null
            ? []
            : List<Product>.from(
                json["products"]!.map((x) => Product.fromJson(x))),
        wishlistElement: json["product_wishlist"] == null
            ? null
            : ProductWishlistElement.fromJson(json["product_wishlist"]),
        customerWishlistGroup: json["customer_wishlist_group"] is List
            ? List<CustomerWishlistGroup>.from(json["customer_wishlist_group"]!
                .map((x) => CustomerWishlistGroup.fromJson(x)))
            : [],
        wishlistGroupProduct: json["wishlist_group_products"] == null
            ? null
            : WishlistGroupProduct.fromJson(json["wishlist_group_products"]),
        createdWishlistGroup: json["customer_wishlist_group"]
                is Map<String, dynamic>
            ? CustomerWishlistGroup.fromJson(json["customer_wishlist_group"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "enabled": enabled,
        "display_name": displayName,
        "wishlist_group": wishlistGroup,
        "reset_cart": resetCart,
        "override_cart": overrideCart,
        "quantity_manage": quantityManage,
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "product_wishlist": wishlistElement?.toJson(),
        "customer_wishlist_group": customerWishlistGroup == null
            ? []
            : List<dynamic>.from(customerWishlistGroup!.map((x) => x.toJson())),
        "wishlist_group_products": wishlistGroupProduct?.toJson(),
      };
}

class FavouriteListConfig {
  bool? success;
  bool enabled;
  String displayName;
  bool wishlistGroup;
  bool resetCart;
  bool overrideCart;
  bool quantityManage;
  String icon;
  bool qtyEnabled;

  FavouriteListConfig({
    this.success,
    this.enabled = false,
    this.displayName = 'Favourite List',
    this.wishlistGroup = false,
    this.resetCart = false,
    this.overrideCart = false,
    this.quantityManage = false,
    this.icon = 'heart',
    this.qtyEnabled = false,
  });

  factory FavouriteListConfig.fromJson(Map<String, dynamic> json) =>
      FavouriteListConfig(
        success: json["success"],
        enabled: json["enabled"] == true,
        displayName: (json["display_name"] as String?)?.isNotEmpty == true
            ? json["display_name"]
            : 'Favourite List',
        wishlistGroup: json["wishlist_group"] == true,
        resetCart: json["reset_cart"] == true,
        overrideCart: json["override_cart"] == true,
        quantityManage: json["quantity_manage"] == true,
        icon: (json["icon"] as String?)?.isNotEmpty == true
            ? json["icon"]
            : 'heart',
        qtyEnabled: json["qty_enabled"] == true,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "enabled": enabled,
        "display_name": displayName,
        "wishlist_group": wishlistGroup,
        "reset_cart": resetCart,
        "override_cart": overrideCart,
        "quantity_manage": quantityManage,
        "icon": icon,
        "qty_enabled": qtyEnabled,
      };
}

class CustomerWishlistGroup {
  String? id;
  String? customerId;
  String? wishlistGroupName;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? productCount;

  CustomerWishlistGroup({
    this.id,
    this.customerId,
    this.wishlistGroupName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.productCount,
  });

  factory CustomerWishlistGroup.fromJson(Map<String, dynamic> json) =>
      CustomerWishlistGroup(
        id: json["id"],
        customerId: json["customer_id"],
        wishlistGroupName: json["wishlist_group_name"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        productCount: json["product_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "wishlist_group_name": wishlistGroupName,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "product_count": productCount,
      };
}

class WishlistGroupProduct {
  String? id;
  String? customerWishlistGroupId;
  String? customerId;
  String? productId;
  String? variantId;
  String? quantity;

  WishlistGroupProduct({
    this.id,
    this.customerWishlistGroupId,
    this.customerId,
    this.productId,
    this.variantId,
    this.quantity,
  });

  factory WishlistGroupProduct.fromJson(Map<String, dynamic> json) =>
      WishlistGroupProduct(
        id: json["id"],
        customerWishlistGroupId: json["customer_wishlist_group_id"],
        customerId: json["customer_id"],
        productId: json["product_id"],
        variantId: json["variant_id"],
        quantity: json["quantity"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_wishlist_group_id": customerWishlistGroupId,
        "customer_id": customerId,
        "product_id": productId,
        "variant_id": variantId,
        "quantity": quantity,
      };
}

class MoveFavouriteListToCartResponse {
  bool? success;
  int? addedCount;
  int? skippedCount;

  MoveFavouriteListToCartResponse({
    this.success,
    this.addedCount,
    this.skippedCount,
  });

  factory MoveFavouriteListToCartResponse.fromJson(Map<String, dynamic> json) =>
      MoveFavouriteListToCartResponse(
        success: json["success"],
        addedCount: json["added_count"],
        skippedCount: json["skipped_count"],
      );
}

// class Product {
//   String? id;
//   String? title;
//   String? handle;
//   String? subtitle;
//   String? description;
//   bool? isGiftcard;
//   String? status;
//   String? thumbnail;
//   dynamic weight;
//   dynamic length;
//   dynamic height;
//   dynamic width;
//   dynamic originCountry;
//   dynamic hsCode;
//   dynamic midCode;
//   dynamic material;
//   bool? discountable;
//   dynamic externalId;
//   dynamic metadata;
//   dynamic typeId;
//   dynamic type;
//   String? collectionId;
//   Collection? collection;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   dynamic deletedAt;
//   List<Variant>? variants;
//   dynamic productWishlist;
//
//   Product({
//     this.id,
//     this.title,
//     this.handle,
//     this.subtitle,
//     this.description,
//     this.isGiftcard,
//     this.status,
//     this.thumbnail,
//     this.weight,
//     this.length,
//     this.height,
//     this.width,
//     this.originCountry,
//     this.hsCode,
//     this.midCode,
//     this.material,
//     this.discountable,
//     this.externalId,
//     this.metadata,
//     this.typeId,
//     this.type,
//     this.collectionId,
//     this.collection,
//     this.createdAt,
//     this.updatedAt,
//     this.deletedAt,
//     this.variants,
//     this.productWishlist,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) => Product(
//     id: json["id"],
//     title: json["title"],
//     handle: json["handle"],
//     subtitle: json["subtitle"],
//     description: json["description"],
//     isGiftcard: json["is_giftcard"],
//     status: json["status"],
//     thumbnail: json["thumbnail"],
//     weight: json["weight"],
//     length: json["length"],
//     height: json["height"],
//     width: json["width"],
//     originCountry: json["origin_country"],
//     hsCode: json["hs_code"],
//     midCode: json["mid_code"],
//     material: json["material"],
//     discountable: json["discountable"],
//     externalId: json["external_id"],
//     metadata: json["metadata"],
//     typeId: json["type_id"],
//     type: json["type"],
//     collectionId: json["collection_id"],
//     collection: json["collection"] == null ? null : Collection.fromJson(json["collection"]),
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     deletedAt: json["deleted_at"],
//     variants: json["variants"] == null ? [] : List<Variant>.from(json["variants"]!.map((x) => Variant.fromJson(x))),
//     productWishlist: json["product_wishlist"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "title": title,
//     "handle": handle,
//     "subtitle": subtitle,
//     "description": description,
//     "is_giftcard": isGiftcard,
//     "status": status,
//     "thumbnail": thumbnail,
//     "weight": weight,
//     "length": length,
//     "height": height,
//     "width": width,
//     "origin_country": originCountry,
//     "hs_code": hsCode,
//     "mid_code": midCode,
//     "material": material,
//     "discountable": discountable,
//     "external_id": externalId,
//     "metadata": metadata,
//     "type_id": typeId,
//     "type": type,
//     "collection_id": collectionId,
//     "collection": collection?.toJson(),
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "deleted_at": deletedAt,
//     "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x.toJson())),
//     "product_wishlist": productWishlist,
//   };
// }

class Collection {
  String? id;

  Collection({
    this.id,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}

class ProductWishlistElement {
  String? id;
  String? customerId;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  ProductWishlistElement({
    this.id,
    this.customerId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProductWishlistElement.fromJson(Map<String, dynamic> json) =>
      ProductWishlistElement(
        id: json["id"],
        customerId: json["customer_id"],
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
        "customer_id": customerId,
        "product_id": productId,
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
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        calculatedPrice: json["calculated_price"] == null
            ? null
            : CalculatedPrice.fromJson(json["calculated_price"]),
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

  factory CalculatedPrice.fromJson(Map<String, dynamic> json) =>
      CalculatedPrice(
        id: json["id"],
        isCalculatedPricePriceList: json["is_calculated_price_price_list"],
        isCalculatedPriceTaxInclusive:
            json["is_calculated_price_tax_inclusive"],
        calculatedAmount: json["calculated_amount"],
        rawCalculatedAmount: json["raw_calculated_amount"] == null
            ? null
            : RawAmount.fromJson(json["raw_calculated_amount"]),
        isOriginalPricePriceList: json["is_original_price_price_list"],
        isOriginalPriceTaxInclusive: json["is_original_price_tax_inclusive"],
        originalAmount: json["original_amount"],
        rawOriginalAmount: json["raw_original_amount"] == null
            ? null
            : RawAmount.fromJson(json["raw_original_amount"]),
        currencyCode: json["currency_code"],
        calculatedPrice: json["calculated_price"] == null
            ? null
            : Price.fromJson(json["calculated_price"]),
        originalPrice: json["original_price"] == null
            ? null
            : Price.fromJson(json["original_price"]),
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
  num? precision;

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

class SavedItem {
  final String productId;
  final String variantId;
  final String listId;
  final String itemId;
  final String quantity;

  SavedItem({
    required this.productId,
    required this.variantId,
    required this.listId,
    required this.itemId,
    this.quantity = '1',
  });

  factory SavedItem.fromJson(Map<String, dynamic> json) => SavedItem(
        productId: json['product_id'] ?? '',
        variantId: json['variant_id'] ?? '',
        listId: json['list_id'] ?? '',
        itemId: json['item_id'] ?? '',
        quantity: json['quantity']?.toString() ?? '1',
      );
}

class SavedItemsResponse {
  final bool success;
  final List<SavedItem> items;

  SavedItemsResponse({required this.success, required this.items});

  factory SavedItemsResponse.fromJson(Map<String, dynamic> json) =>
      SavedItemsResponse(
        success: json['success'] == true,
        items: (json['items'] as List? ?? [])
            .map((e) => SavedItem.fromJson(e))
            .toList(),
      );
}
