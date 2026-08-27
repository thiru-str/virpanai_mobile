// To parse this JSON data, do
//
//     final orderDetailResponse = orderDetailResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/preference_snapshot.dart';

OrderDetailResponse orderDetailResponseFromJson(String str) => OrderDetailResponse.fromJson(json.decode(str));

String orderDetailResponseToJson(OrderDetailResponse data) => json.encode(data.toJson());

class OrderDetailResponse {
  bool? status;
  Data? data;
  Error? error;

  OrderDetailResponse({
    this.status,
    this.data,
    this.error,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) => OrderDetailResponse(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    error: json["error"] == null ? null : Error.fromJson(json["error"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "error": error?.toJson(),
  };
}

class Data {
  String? id;
  int? displayId;
  String? cartId;
  DateTime? createdAt;
  String? currencyCode;
  String? status;
  bool? isCanceled;
  String? orderCustomStatus;
  String? orderDisplayStatus;
  String? orderStatus;
  String? paymentStatus;
  String? paymentMethod;
  Prices? prices;
  List<Item>? items;
  IngAddress? shippingAddress;
  IngAddress? billingAddress;
  dynamic metadata;
  String? couponCode;

  Data({
    this.id,
    this.displayId,
    this.cartId,
    this.createdAt,
    this.currencyCode,
    this.status,
    this.isCanceled,
    this.orderCustomStatus,
    this.orderDisplayStatus,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.prices,
    this.items,
    this.shippingAddress,
    this.billingAddress,
    this.metadata,
    this.couponCode,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    displayId: json["display_id"],
    cartId: json["cart_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    currencyCode: json["currency_code"],
    status: json["status"],
    isCanceled: json["is_canceled"],
    orderCustomStatus: json["order_custom_status"],
    orderDisplayStatus: json["order_display_status"],
    orderStatus: json["order_status"],
    paymentStatus: json["payment_status"],
    paymentMethod: json["payment_method"],
    prices: json["prices"] == null ? null : Prices.fromJson(json["prices"]),
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    shippingAddress: json["shipping_address"] == null ? null : IngAddress.fromJson(json["shipping_address"]),
    billingAddress: json["billing_address"] == null ? null : IngAddress.fromJson(json["billing_address"]),
    metadata: json["metadata"],
    couponCode: json["coupon_code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "display_id": displayId,
    "cart_id": cartId,
    "created_at": createdAt?.toIso8601String(),
    "currency_code": currencyCode,
    "status": status,
    "is_canceled": isCanceled,
    "order_custom_status": orderCustomStatus,
    "order_display_status": orderDisplayStatus,
    "order_status": orderStatus,
    "payment_status": paymentStatus,
    "payment_method": paymentMethod,
    "prices": prices?.toJson(),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "shipping_address": shippingAddress?.toJson(),
    "billing_address": billingAddress?.toJson(),
  };
}

class IngAddress {
  String? id;
  dynamic customerId;
  String? company;
  String? firstName;
  String? lastName;
  String? address1;
  String? address2;
  String? city;
  String? countryCode;
  String? province;
  String? postalCode;
  String? phone;
  dynamic metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  IngAddress({
    this.id,
    this.customerId,
    this.company,
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.countryCode,
    this.province,
    this.postalCode,
    this.phone,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory IngAddress.fromJson(Map<String, dynamic> json) => IngAddress(
    id: json["id"],
    customerId: json["customer_id"],
    company: json["company"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    address1: json["address_1"],
    address2: json["address_2"],
    city: json["city"],
    countryCode: json["country_code"],
    province: json["province"],
    postalCode: json["postal_code"],
    phone: json["phone"],
    metadata: json["metadata"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "company": company,
    "first_name": firstName,
    "last_name": lastName,
    "address_1": address1,
    "address_2": address2,
    "city": city,
    "country_code": countryCode,
    "province": province,
    "postal_code": postalCode,
    "phone": phone,
    "metadata": metadata,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Item {
  String? id;
  String? productId;
  String? productTitle;
  String? variantId;
  String? variantTitle;
  String? variantSku;
  String? thumbnail;
  num? unitPrice;
  int? quantity;
  String? status;
  String? fulfillmentId;
  Detail? detail;
  bool? isReturnable;
  int? returnableQuantity;
  ItemMetadata? metadata;

  Item({
    this.id,
    this.productId,
    this.productTitle,
    this.variantId,
    this.variantTitle,
    this.variantSku,
    this.thumbnail,
    this.unitPrice,
    this.quantity,
    this.status,
    this.fulfillmentId,
    this.detail,
    this.isReturnable,
    this.returnableQuantity,
    this.metadata,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    productId: json["product_id"],
    productTitle: json["product_title"],
    variantId: json["variant_id"],
    variantTitle: json["variant_title"],
    variantSku: json["variant_sku"],
    thumbnail: json["thumbnail"],
    unitPrice: json["unit_price"],
    quantity: json["quantity"],
    status: json["status"],
    fulfillmentId: json["fulfillment_id"],
    detail: json["detail"] == null ? null : Detail.fromJson(json["detail"]),
    isReturnable: json["is_returnable"],
    returnableQuantity: json["returnable_quantity"],
    metadata: json["metadata"] == null ? null : ItemMetadata.fromJson(json["metadata"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "product_title": productTitle,
    "variant_id": variantId,
    "variant_title": variantTitle,
    "variant_sku": variantSku,
    "thumbnail": thumbnail,
    "unit_price": unitPrice,
    "quantity": quantity,
    "status": status,
    "fulfillment_id": fulfillmentId,
    "detail": detail?.toJson(),
    "is_returnable": isReturnable,
    "returnable_quantity": returnableQuantity,
    "metadata": metadata?.toJson(),
  };

  bool get isPlatformFee => metadata?.type == 'platform_fee';
}

class ItemMetadata {
  String? type;
  num? percentage;
  bool unitBasedInventory;
  int? unitQuantity;
  int? baseUnitGrams;
  String? unitType;
  String? displayUnit;
  PreferenceSnapshot? preference;

  ItemMetadata({
    this.type,
    this.percentage,
    this.unitBasedInventory = false,
    this.unitQuantity,
    this.baseUnitGrams,
    this.unitType,
    this.displayUnit,
    this.preference,
  });

  factory ItemMetadata.fromJson(Map<String, dynamic> json) => ItemMetadata(
    type: json["type"],
    percentage: json["percentage"],
    unitBasedInventory: json["unit_based_inventory"] == true ||
        json["unit_based_inventory"] == "true",
    unitQuantity: _toInt(json["unit_quantity"]),
    baseUnitGrams: _toInt(json["base_unit_grams"]),
    unitType: json["unit_type"]?.toString(),
    displayUnit: json["display_unit"]?.toString(),
    preference: PreferenceSnapshot.fromDynamic(json["preference"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "percentage": percentage,
    "unit_based_inventory": unitBasedInventory,
    "unit_quantity": unitQuantity,
    "base_unit_grams": baseUnitGrams,
    "unit_type": unitType,
    "display_unit": displayUnit,
    if (preference != null) "preference": preference!.toJson(),
  };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}

class Detail {
  String? itemId;
  int? packedQuantity;
  int? shippedQuantity;
  int? deliveredQuantity;
  int? pendingQuantity;

  Detail({
    this.itemId,
    this.packedQuantity,
    this.shippedQuantity,
    this.deliveredQuantity,
    this.pendingQuantity,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    itemId: json["item_id"],
    packedQuantity: json["packed_quantity"],
    shippedQuantity: json["shipped_quantity"],
    deliveredQuantity: json["delivered_quantity"],
    pendingQuantity: json["pending_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "packed_quantity": packedQuantity,
    "shipped_quantity": shippedQuantity,
    "delivered_quantity": deliveredQuantity,
    "pending_quantity": pendingQuantity,
  };
}

class Prices {
  num? total;
  num? itemTotal;
  num? itemSubtotal;
  num? shippingTotal;
  num? discountTotal;
  num? physicalDiscountTotal;
  num? taxTotal;

  Prices({
    this.total,
    this.itemTotal,
    this.itemSubtotal,
    this.shippingTotal,
    this.discountTotal,
    this.physicalDiscountTotal,
    this.taxTotal,
  });

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
    total: json["total"],
    itemTotal: json["item_total"],
    itemSubtotal: json["item_subtotal"],
    shippingTotal: json["shipping_total"],
    discountTotal: json["discount_total"],
    physicalDiscountTotal: json["physical_discount_amount"] ?? json["physical_discount"],
    taxTotal: json["tax_total"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "item_total": itemTotal,
    "item_subtotal": itemSubtotal,
    "shipping_total": shippingTotal,
    "discount_total": discountTotal,
    "physical_discount_amount": physicalDiscountTotal,
    "tax_total": taxTotal,
  };
}

class Error {
  Error();

  factory Error.fromJson(Map<String, dynamic> json) => Error(
  );

  Map<String, dynamic> toJson() => {
  };
}
