// To parse this JSON data, do
//
//     final addCartResponse = addCartResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/order_history_reponse.dart';

import '../model/shipping_response.dart';

CartResponse addCartResponseFromJson(String str) => CartResponse.fromJson(json.decode(str));

String cartResponseToJson(CartResponse data) => json.encode(data.toJson());

class CartResponse {
  Cart? cart;

  CartResponse({
    this.cart,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
  );

  Map<String, dynamic> toJson() => {
    "cart": cart?.toJson(),
  };
}

class Cart {
  String? id;
  String? currencyCode;
  String? email;
  String? regionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic completedAt;
  num? total;
  num? subtotal;
  num? taxTotal;
  num? discountTotal;
  num? discountSubtotal;
  num? discountTaxTotal;
  num? originalTotal;
  num? originalTaxTotal;
  num? itemTotal;
  num? itemSubtotal;
  num? itemTaxTotal;
  num? originalItemTotal;
  num? originalItemSubtotal;
  num? originalItemTaxTotal;
  num? shippingTotal;
  num? shippingSubtotal;
  num? shippingTaxTotal;
  num? originalShippingTaxTotal;
  num? originalShippingSubtotal;
  num? originalShippingTotal;
  dynamic metadata;
  String? salesChannelId;
  String? shippingAddressId;
  String? customerId;
  List<Item>? items;
  List<ShippingMethod>? shippingMethods;
  ShippingAddress? shippingAddress;
  dynamic billingAddress;
  Customer? customer;
  Region? region;
  List<Promotion>? promotions;
  PaymentCollection? paymentCollection;

  Cart({
    this.id,
    this.currencyCode,
    this.email,
    this.regionId,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.total,
    this.subtotal,
    this.taxTotal,
    this.discountTotal,
    this.discountSubtotal,
    this.discountTaxTotal,
    this.originalTotal,
    this.originalTaxTotal,
    this.itemTotal,
    this.itemSubtotal,
    this.itemTaxTotal,
    this.originalItemTotal,
    this.originalItemSubtotal,
    this.originalItemTaxTotal,
    this.shippingTotal,
    this.shippingSubtotal,
    this.shippingTaxTotal,
    this.originalShippingTaxTotal,
    this.originalShippingSubtotal,
    this.originalShippingTotal,
    this.metadata,
    this.salesChannelId,
    this.shippingAddressId,
    this.customerId,
    this.items,
    this.shippingMethods,
    this.shippingAddress,
    this.billingAddress,
    this.customer,
    this.region,
    this.promotions,
    this.paymentCollection,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["id"],
    currencyCode: json["currency_code"],
    email: json["email"],
    regionId: json["region_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    completedAt: json["completed_at"],
    total: json["total"],
    subtotal: json["subtotal"],
    taxTotal: json["tax_total"],
    discountTotal: json["discount_total"],
    discountSubtotal: json["discount_subtotal"],
    discountTaxTotal: json["discount_tax_total"],
    originalTotal: json["original_total"],
    originalTaxTotal: json["original_tax_total"],
    itemTotal: json["item_total"],
    itemSubtotal: json["item_subtotal"],
    itemTaxTotal: json["item_tax_total"],
    originalItemTotal: json["original_item_total"],
    originalItemSubtotal: json["original_item_subtotal"],
    originalItemTaxTotal: json["original_item_tax_total"],
    shippingTotal: json["shipping_total"],
    shippingSubtotal: json["shipping_subtotal"],
    shippingTaxTotal: json["shipping_tax_total"],
    originalShippingTaxTotal: json["original_shipping_tax_total"],
    originalShippingSubtotal: json["original_shipping_subtotal"],
    originalShippingTotal: json["original_shipping_total"],
    metadata: json["metadata"],
    salesChannelId: json["sales_channel_id"],
    shippingAddressId: json["shipping_address_id"],
    customerId: json["customer_id"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    shippingMethods: json["shipping_methods"] == null ? [] : List<ShippingMethod>.from(json["shipping_methods"]!.map((x) => ShippingMethod.fromJson(x))),
    shippingAddress: json["shipping_address"] == null ? null : ShippingAddress.fromJson(json["shipping_address"]),
    billingAddress: json["billing_address"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    region: json["region"] == null ? null : Region.fromJson(json["region"]),
    promotions: json["promotions"] == null
        ? []
        : List<Promotion>.from(
        json["promotions"]!.where((x) => x != null).map((x) => Promotion.fromJson(x))
    ),
    paymentCollection: json["payment_collection"] == null ? null : PaymentCollection.fromJson(json["payment_collection"]),

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "email": email,
    "region_id": regionId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "completed_at": completedAt,
    "total": total,
    "subtotal": subtotal,
    "tax_total": taxTotal,
    "discount_total": discountTotal,
    "discount_subtotal": discountSubtotal,
    "discount_tax_total": discountTaxTotal,
    "original_total": originalTotal,
    "original_tax_total": originalTaxTotal,
    "item_total": itemTotal,
    "item_subtotal": itemSubtotal,
    "item_tax_total": itemTaxTotal,
    "original_item_total": originalItemTotal,
    "original_item_subtotal": originalItemSubtotal,
    "original_item_tax_total": originalItemTaxTotal,
    "shipping_total": shippingTotal,
    "shipping_subtotal": shippingSubtotal,
    "shipping_tax_total": shippingTaxTotal,
    "original_shipping_tax_total": originalShippingTaxTotal,
    "original_shipping_subtotal": originalShippingSubtotal,
    "original_shipping_total": originalShippingTotal,
    "metadata": metadata,
    "sales_channel_id": salesChannelId,
    "shipping_address_id": shippingAddressId,
    "customer_id": customerId,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "shipping_methods": shippingMethods == null ? [] : List<dynamic>.from(shippingMethods!.map((x) => x.toJson())),
    "shipping_address": shippingAddress?.toJson(),
    "billing_address": billingAddress,
    "customer": customer?.toJson(),
    "region": region?.toJson(),
    "promotions": promotions == null ? [] : List<dynamic>.from(promotions!.map((x) => x)),
    "payment_collection": paymentCollection?.toJson(),
  };
}

class Customer {
  String? id;
  String? email;
  List<dynamic>? groups;

  Customer({
    this.id,
    this.email,
    this.groups,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"],
    email: json["email"],
    groups: json["groups"] == null ? [] : List<dynamic>.from(json["groups"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "groups": groups == null ? [] : List<dynamic>.from(groups!.map((x) => x)),
  };
}


class Item {
  String? id;
  String? title;
  String? subtitle;
  String? thumbnail;
  String? variantId;
  String? productId;
  String? productTitle;
  String? productDescription;
  String? productSubtitle;
  String? productCollection;
  String? productHandle;
  String? variantSku;
  String? variantTitle;
  bool? requiresShipping;
  bool? isDiscountable;
  bool? isTaxInclusive;
  Raw? rawUnitPrice;
  bool? isCustomPrice;
  List<dynamic>? taxLines;
  List<dynamic>? adjustments;
  Metadata? metadata;
  String? cartId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic productType;
  dynamic productTypeId;
  dynamic variantBarcode;
  dynamic variantOptionValues;
  dynamic rawCompareAtUnitPrice;
  dynamic deletedAt;
  dynamic compareAtUnitPrice;
  num? unitPrice;
  int? quantity;
  Raw? rawQuantity;
  Detail? detail;
  num? subtotal;
  num? total;
  num? originalTotal;
  num? discountTotal;
  num? discountSubtotal;
  num? discountTaxTotal;
  num? taxTotal;
  num? originalTaxTotal;
  num? refundableTotalPerUnit;
  num? refundableTotal;
  num? fulfilledTotal;
  num? shippedTotal;
  num? returnRequestedTotal;
  num? returnReceivedTotal;
  num? returnDismissedTotal;
  num? writeOffTotal;
  Raw? rawSubtotal;
  Raw? rawTotal;
  Raw? rawOriginalTotal;
  Raw? rawDiscountTotal;
  Raw? rawDiscountSubtotal;
  Raw? rawDiscountTaxTotal;
  Raw? rawTaxTotal;
  Raw? rawOriginalTaxTotal;
  Raw? rawRefundableTotalPerUnit;
  Raw? rawRefundableTotal;
  Raw? rawFulfilledTotal;
  Raw? rawShippedTotal;
  Raw? rawReturnRequestedTotal;
  Raw? rawReturnReceivedTotal;
  Raw? rawReturnDismissedTotal;
  Raw? rawWriteOffTotal;
  bool? isUpdating;

  Item({
    this.id,
    this.title,
    this.subtitle,
    this.thumbnail,
    this.variantId,
    this.productId,
    this.productTitle,
    this.productDescription,
    this.productSubtitle,
    this.productCollection,
    this.productHandle,
    this.variantSku,
    this.variantTitle,
    this.requiresShipping,
    this.isDiscountable,
    this.isTaxInclusive,
    this.rawUnitPrice,
    this.isCustomPrice,
    this.taxLines,
    this.adjustments,
    this.metadata,
    this.cartId,
    this.createdAt,
    this.updatedAt,
    this.productType,
    this.productTypeId,
    this.variantBarcode,
    this.variantOptionValues,
    this.rawCompareAtUnitPrice,
    this.deletedAt,
    this.compareAtUnitPrice,
    this.unitPrice,
    this.quantity,
    this.rawQuantity,
    this.detail,
    this.subtotal,
    this.total,
    this.originalTotal,
    this.discountTotal,
    this.discountSubtotal,
    this.discountTaxTotal,
    this.taxTotal,
    this.originalTaxTotal,
    this.refundableTotalPerUnit,
    this.refundableTotal,
    this.fulfilledTotal,
    this.shippedTotal,
    this.returnRequestedTotal,
    this.returnReceivedTotal,
    this.returnDismissedTotal,
    this.writeOffTotal,
    this.rawSubtotal,
    this.rawTotal,
    this.rawOriginalTotal,
    this.rawDiscountTotal,
    this.rawDiscountSubtotal,
    this.rawDiscountTaxTotal,
    this.rawTaxTotal,
    this.rawOriginalTaxTotal,
    this.rawRefundableTotalPerUnit,
    this.rawRefundableTotal,
    this.rawFulfilledTotal,
    this.rawShippedTotal,
    this.rawReturnRequestedTotal,
    this.rawReturnReceivedTotal,
    this.rawReturnDismissedTotal,
    this.rawWriteOffTotal,
    this.isUpdating = false,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    title: json["title"],
    subtitle: json["subtitle"],
    thumbnail: json["thumbnail"],
    variantId: json["variant_id"],
    productId: json["product_id"],
    productTitle: json["product_title"],
    productDescription: json["product_description"],
    productSubtitle: json["product_subtitle"],
    productCollection: json["product_collection"],
    productHandle: json["product_handle"],
    variantSku: json["variant_sku"],
    variantTitle: json["variant_title"],
    requiresShipping: json["requires_shipping"],
    isDiscountable: json["is_discountable"],
    isTaxInclusive: json["is_tax_inclusive"],
    rawUnitPrice: json["raw_unit_price"] == null ? null : Raw.fromJson(json["raw_unit_price"]),
    isCustomPrice: json["is_custom_price"],
    taxLines: json["tax_lines"] == null ? [] : List<dynamic>.from(json["adjustments"]!.map((x) => x)),
    adjustments: json["adjustments"] == null ? [] : List<dynamic>.from(json["adjustments"]!.map((x) => x)),
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    cartId: json["cart_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    productType: json["product_type"],
    productTypeId: json["product_type_id"],
    variantBarcode: json["variant_barcode"],
    variantOptionValues: json["variant_option_values"],
    rawCompareAtUnitPrice: json["raw_compare_at_unit_price"],
    deletedAt: json["deleted_at"],
    compareAtUnitPrice: json["compare_at_unit_price"],
    unitPrice: json["unit_price"],
    quantity: json["quantity"],
    rawQuantity: json["raw_quantity"] == null ? null : Raw.fromJson(json["raw_quantity"]),
    detail: json["detail"] == null ? null : Detail.fromJson(json["detail"]),
    subtotal: json["subtotal"],
    total: json["total"]?.toDouble(),
    originalTotal: json["original_total"]?.toDouble(),
    discountTotal: json["discount_total"],
    discountSubtotal: json["discount_subtotal"],
    discountTaxTotal: json["discount_tax_total"],
    taxTotal: json["tax_total"]?.toDouble(),
    originalTaxTotal: json["original_tax_total"]?.toDouble(),
    refundableTotalPerUnit: json["refundable_total_per_unit"]?.toDouble(),
    refundableTotal: json["refundable_total"]?.toDouble(),
    fulfilledTotal: json["fulfilled_total"],
    shippedTotal: json["shipped_total"],
    returnRequestedTotal: json["return_requested_total"],
    returnReceivedTotal: json["return_received_total"],
    returnDismissedTotal: json["return_dismissed_total"],
    writeOffTotal: json["write_off_total"],
    rawSubtotal: json["raw_subtotal"] == null ? null : Raw.fromJson(json["raw_subtotal"]),
    rawTotal: json["raw_total"],
    rawOriginalTotal: json["raw_original_total"] == null ? null : Raw.fromJson(json["raw_original_total"]),
    rawDiscountTotal: json["raw_discount_total"] == null ? null : Raw.fromJson(json["raw_discount_total"]),
    rawDiscountSubtotal: json["raw_discount_total"] == null ? null : Raw.fromJson(json["raw_discount_total"]),
    rawDiscountTaxTotal: json["raw_discount_tax_total"] == null ? null : Raw.fromJson(json["raw_discount_tax_total"]),
    rawTaxTotal: json["raw_tax_total"] == null ? null : Raw.fromJson(json["raw_tax_total"]),
    rawOriginalTaxTotal: json["raw_original_tax_total"] == null ? null : Raw.fromJson(json["raw_original_tax_total"]),
    rawRefundableTotalPerUnit: json["raw_refundable_total_per_unit"] == null ? null : Raw.fromJson(json["raw_refundable_total_per_unit"]),
    rawRefundableTotal: json["raw_refundable_total"] == null ? null : Raw.fromJson(json["raw_refundable_total"]),
    rawFulfilledTotal: json["raw_fulfilled_total"] == null ? null : Raw.fromJson(json["raw_fulfilled_total"]),
    rawShippedTotal: json["raw_shipped_total"] == null ? null : Raw.fromJson(json["raw_shipped_total"]),
    rawReturnRequestedTotal: json["raw_return_requested_total"] == null ? null : Raw.fromJson(json["raw_return_requested_total"]),
    rawReturnReceivedTotal: json["raw_return_received_total"] == null ? null : Raw.fromJson(json["raw_return_received_total"]),
    rawReturnDismissedTotal: json["raw_return_received_total"] == null ? null : Raw.fromJson(json["raw_return_received_total"]),
    rawWriteOffTotal: json["raw_write_off_total"] == null ? null : Raw.fromJson(json["raw_write_off_total"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subtitle": subtitle,
    "thumbnail": thumbnail,
    "variant_id": variantId,
    "product_id": productId,
    "product_title": productTitle,
    "product_description": productDescription,
    "product_subtitle": productSubtitle,
    "product_collection": productCollection,
    "product_handle": productHandle,
    "variant_sku": variantSku,
    "variant_title": variantTitle,
    "requires_shipping": requiresShipping,
    "is_discountable": isDiscountable,
    "is_tax_inclusive": isTaxInclusive,
    "raw_unit_price": rawUnitPrice,
    "is_custom_price": isCustomPrice,
    "tax_lines": taxLines == null ? [] : List<dynamic>.from(taxLines!.map((x) => x.toJson())),
    "adjustments": adjustments == null ? [] : List<dynamic>.from(adjustments!.map((x) => x)),
    "metadata": metadata?.toJson(),
    "cart_id": cartId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "product_type": productType,
    "product_type_id": productTypeId,
    "variant_barcode": variantBarcode,
    "variant_option_values": variantOptionValues,
    "raw_compare_at_unit_price": rawCompareAtUnitPrice,
    "deleted_at": deletedAt,
    "compare_at_unit_price": compareAtUnitPrice,
    "unit_price": unitPrice,
    "quantity": quantity,
    "raw_quantity": rawQuantity,
    "detail": detail?.toJson(),
    "subtotal": subtotal,
    "total": total,
    "original_total": originalTotal,
    "discount_total": discountTotal,
    "discount_subtotal": discountSubtotal,
    "discount_tax_total": discountTaxTotal,
    "tax_total": taxTotal,
    "original_tax_total": originalTaxTotal,
    "refundable_total_per_unit": refundableTotalPerUnit,
    "refundable_total": refundableTotal,
    "fulfilled_total": fulfilledTotal,
    "shipped_total": shippedTotal,
    "return_requested_total": returnRequestedTotal,
    "return_received_total": returnReceivedTotal,
    "return_dismissed_total": returnDismissedTotal,
    "write_off_total": writeOffTotal,
    "raw_subtotal": rawSubtotal,
    "raw_total": rawTotal,
    "raw_original_total": rawOriginalTotal,
    "raw_discount_total": rawDiscountTotal,
    "raw_discount_subtotal": rawDiscountSubtotal,
    "raw_discount_tax_total": rawDiscountTaxTotal,
    "raw_tax_total": rawTaxTotal,
    "raw_original_tax_total": rawOriginalTaxTotal,
    "raw_refundable_total_per_unit": rawRefundableTotalPerUnit,
    "raw_refundable_total": rawRefundableTotal,
    "raw_fulfilled_total": rawFulfilledTotal,
    "raw_shipped_total": rawShippedTotal,
    "raw_return_requested_total": rawReturnRequestedTotal,
    "raw_return_received_total": rawReturnReceivedTotal,
    "raw_return_dismissed_total": rawReturnDismissedTotal,
    "raw_write_off_total": rawWriteOffTotal,
  };
}


class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
  );

  Map<String, dynamic> toJson() => {
  };
}

class Product {
  String? id;
  String? collectionId;
  dynamic typeId;
  List<Category>? categories;
  List<dynamic>? tags;

  Product({
    this.id,
    this.collectionId,
    this.typeId,
    this.categories,
    this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    collectionId: json["collection_id"],
    typeId: json["type_id"],
    categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collection_id": collectionId,
    "type_id": typeId,
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
  };
}

class Category {
  String? id;

  Category({
    this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}

class Region {
  String? id;
  String? name;
  String? currencyCode;
  bool? automaticTaxes;
  List<Country>? countries;

  Region({
    this.id,
    this.name,
    this.currencyCode,
    this.automaticTaxes,
    this.countries,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    id: json["id"],
    name: json["name"],
    currencyCode: json["currency_code"],
    automaticTaxes: json["automatic_taxes"],
    countries: json["countries"] == null ? [] : List<Country>.from(json["countries"]!.map((x) => Country.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "currency_code": currencyCode,
    "automatic_taxes": automaticTaxes,
    "countries": countries == null ? [] : List<dynamic>.from(countries!.map((x) => x.toJson())),
  };
}

class Promotion {
  String? id;
  String? code;
  bool? isAutomatic;
  ApplicationMethod? applicationMethod;

  Promotion({
    this.id,
    this.code,
    this.isAutomatic,
    this.applicationMethod,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
    id: json["id"],
    code: json["code"],
    isAutomatic: json["is_automatic"],
    applicationMethod: json["application_method"] == null ? null : ApplicationMethod.fromJson(json["application_method"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "is_automatic": isAutomatic,
    "application_method": applicationMethod?.toJson(),
  };
}

class ApplicationMethod {
  num? value;
  String? type;
  String? currencyCode;

  ApplicationMethod({
    this.value,
    this.type,
    this.currencyCode,
  });

  factory ApplicationMethod.fromJson(Map<String, dynamic> json) => ApplicationMethod(
    value: json["value"],
    type: json["type"],
    currencyCode: json["currency_code"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "type": type,
    "currency_code": currencyCode,
  };
}

class Country {
  String? iso2;
  String? iso3;
  String? numCode;
  String? name;
  String? displayName;
  String? regionId;
  dynamic metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Country({
    this.iso2,
    this.iso3,
    this.numCode,
    this.name,
    this.displayName,
    this.regionId,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    iso2: json["iso_2"],
    iso3: json["iso_3"],
    numCode: json["num_code"],
    name: json["name"],
    displayName: json["display_name"],
    regionId: json["region_id"],
    metadata: json["metadata"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "iso_2": iso2,
    "iso_3": iso3,
    "num_code": numCode,
    "name": name,
    "display_name": displayName,
    "region_id": regionId,
    "metadata": metadata,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class ShippingAddress {
  String? id;
  dynamic firstName;
  dynamic lastName;
  dynamic company;
  String? address1;
  dynamic address2;
  dynamic city;
  dynamic postalCode;
  String? countryCode;
  dynamic province;
  dynamic phone;

  ShippingAddress({
    this.id,
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.postalCode,
    this.countryCode,
    this.province,
    this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    company: json["company"],
    address1: json["address_1"],
    address2: json["address_2"],
    city: json["city"],
    postalCode: json["postal_code"],
    countryCode: json["country_code"],
    province: json["province"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "company": company,
    "address_1": address1,
    "address_2": address2,
    "city": city,
    "postal_code": postalCode,
    "country_code": countryCode,
    "province": province,
    "phone": phone,
  };
}

class PaymentCollection {
  String? id;
  String? currencyCode;
  dynamic completedAt;
  String? status;
  dynamic metadata;
  dynamic rawAuthorizedAmount;
  dynamic rawCapturedAmount;
  dynamic rawRefundedAmount;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<PaymentSession>? paymentSessions;
  num? amount;
  dynamic authorizedAmount;
  dynamic capturedAmount;
  dynamic refundedAmount;

  PaymentCollection({
    this.id,
    this.currencyCode,
    this.completedAt,
    this.status,
    this.metadata,
    this.rawAuthorizedAmount,
    this.rawCapturedAmount,
    this.rawRefundedAmount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.paymentSessions,
    this.amount,
    this.authorizedAmount,
    this.capturedAmount,
    this.refundedAmount,
  });

  factory PaymentCollection.fromJson(Map<String, dynamic> json) => PaymentCollection(
    id: json["id"],
    currencyCode: json["currency_code"],
    completedAt: json["completed_at"],
    status: json["status"],
    metadata: json["metadata"],
    rawAuthorizedAmount: json["raw_authorized_amount"],
    rawCapturedAmount: json["raw_captured_amount"],
    rawRefundedAmount: json["raw_refunded_amount"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    paymentSessions: json["payment_sessions"] == null ? [] : List<PaymentSession>.from(json["payment_sessions"]!.map((x) => PaymentSession.fromJson(x))),
    amount: json["amount"],
    authorizedAmount: json["authorized_amount"],
    capturedAmount: json["captured_amount"],
    refundedAmount: json["refunded_amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "completed_at": completedAt,
    "status": status,
    "metadata": metadata,
    "raw_authorized_amount": rawAuthorizedAmount,
    "raw_captured_amount": rawCapturedAmount,
    "raw_refunded_amount": rawRefundedAmount,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "payment_sessions": paymentSessions == null ? [] : List<dynamic>.from(paymentSessions!.map((x) => x.toJson())),
    "amount": amount,
    "authorized_amount": authorizedAmount,
    "captured_amount": capturedAmount,
    "refunded_amount": refundedAmount,
  };
}

class PaymentSession {
  String? id;
  String? currencyCode;
  String? providerId;
  //Data? data;
  Metadata? context;
  String? status;
  dynamic authorizedAt;
  String? paymentCollectionId;
  Metadata? metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  num? amount;

  PaymentSession({
    this.id,
    this.currencyCode,
    this.providerId,
    //this.data,
    this.context,
    this.status,
    this.authorizedAt,
    this.paymentCollectionId,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.amount,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> json) => PaymentSession(
    id: json["id"],
    currencyCode: json["currency_code"],
    providerId: json["provider_id"],
    //data: json["data"] == null ? null : Data.fromJson(json["data"]),
    context: json["context"] == null ? null : Metadata.fromJson(json["context"]),
    status: json["status"],
    authorizedAt: json["authorized_at"],
    paymentCollectionId: json["payment_collection_id"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "provider_id": providerId,
    //"data": data?.toJson(),
    "context": context?.toJson(),
    "status": status,
    "authorized_at": authorizedAt,
    "payment_collection_id": paymentCollectionId,
    "metadata": metadata?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "amount": amount,
  };
}

// class Data {
//   String? id;
//
//
//   Data({
//     this.id,
//   });
//
//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     id: json["id"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//   };
// }

class ShippingMethod {
  int? amount;
  bool? isTaxInclusive;
  String? shippingOptionId;
  String? id;
  String? name;
  List<dynamic>? taxLines;
  List<dynamic>? adjustments;
  ShippingOption? shippingOption;

  ShippingMethod({
    this.amount,
    this.isTaxInclusive,
    this.shippingOptionId,
    this.id,
    this.name,
    this.taxLines,
    this.adjustments,
    this.shippingOption,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) => ShippingMethod(
    amount: json["amount"],
    isTaxInclusive: json["is_tax_inclusive"],
    shippingOptionId: json["shipping_option_id"],
    id: json["id"],
    name: json["name"],
    taxLines: json["tax_lines"] == null ? [] : List<dynamic>.from(json["tax_lines"]!.map((x) => x)),
    adjustments: json["adjustments"] == null ? [] : List<dynamic>.from(json["adjustments"]!.map((x) => x)),
    shippingOption: json["shipping_option"] == null ? null : ShippingOption.fromJson(json["shipping_option"]),
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "is_tax_inclusive": isTaxInclusive,
    "shipping_option_id": shippingOptionId,
    "id": id,
    "name": name,
    "tax_lines": taxLines == null ? [] : List<dynamic>.from(taxLines!.map((x) => x)),
    "adjustments": adjustments == null ? [] : List<dynamic>.from(adjustments!.map((x) => x)),
    "shipping_option": shippingOption?.toJson(),
  };
}

