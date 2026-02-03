// To parse this JSON data, do
//
//     final placeOrderResponse = placeOrderResponseFromJson(jsonString);

import 'dart:convert';

PlaceOrderResponse placeOrderResponseFromJson(String str) => PlaceOrderResponse.fromJson(json.decode(str));

String placeOrderResponseToJson(PlaceOrderResponse data) => json.encode(data.toJson());

class PlaceOrderResponse {
  String? type;
  Order? order;

  PlaceOrderResponse({
    this.type,
    this.order,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) => PlaceOrderResponse(
    type: json["type"],
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "order": order?.toJson(),
  };
}

class Order {
  String? id;
  String? status;
  Summary? summary;
  String? currencyCode;
  int? displayId;
  String? regionId;
  String? email;
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
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Item>? items;
  dynamic shippingAddress;
  dynamic billingAddress;
  List<dynamic>? shippingMethods;
  List<PaymentCollection>? paymentCollections;

  Order({
    this.id,
    this.status,
    this.summary,
    this.currencyCode,
    this.displayId,
    this.regionId,
    this.email,
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
    this.createdAt,
    this.updatedAt,
    this.items,
    this.shippingAddress,
    this.billingAddress,
    this.shippingMethods,
    this.paymentCollections,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    status: json["status"],
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    currencyCode: json["currency_code"],
    displayId: json["display_id"],
    regionId: json["region_id"],
    email: json["email"],
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
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    shippingAddress: json["shipping_address"],
    billingAddress: json["billing_address"],
    shippingMethods: json["shipping_methods"] == null ? [] : List<dynamic>.from(json["shipping_methods"]!.map((x) => x)),
    paymentCollections: json["payment_collections"] == null ? [] : List<PaymentCollection>.from(json["payment_collections"]!.map((x) => PaymentCollection.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "summary": summary?.toJson(),
    "currency_code": currencyCode,
    "display_id": displayId,
    "region_id": regionId,
    "email": email,
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
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "shipping_address": shippingAddress,
    "billing_address": billingAddress,
    "shipping_methods": shippingMethods == null ? [] : List<dynamic>.from(shippingMethods!.map((x) => x)),
    "payment_collections": paymentCollections == null ? [] : List<dynamic>.from(paymentCollections!.map((x) => x.toJson())),
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
  dynamic productType;
  dynamic productTypeId;
  String? productCollection;
  String? productHandle;
  String? variantSku;
  dynamic variantBarcode;
  String? variantTitle;
  dynamic variantOptionValues;
  bool? requiresShipping;
  bool? isDiscountable;
  bool? isTaxInclusive;
  dynamic rawCompareAtUnitPrice;
  Raw? rawUnitPrice;
  bool? isCustomPrice;
  Metadata? metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<dynamic>? taxLines;
  List<dynamic>? adjustments;
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
  Variant? variant;

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
    this.productType,
    this.productTypeId,
    this.productCollection,
    this.productHandle,
    this.variantSku,
    this.variantBarcode,
    this.variantTitle,
    this.variantOptionValues,
    this.requiresShipping,
    this.isDiscountable,
    this.isTaxInclusive,
    this.rawCompareAtUnitPrice,
    this.rawUnitPrice,
    this.isCustomPrice,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.taxLines,
    this.adjustments,
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
    this.variant,
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
    productType: json["product_type"],
    productTypeId: json["product_type_id"],
    productCollection: json["product_collection"],
    productHandle: json["product_handle"],
    variantSku: json["variant_sku"],
    variantBarcode: json["variant_barcode"],
    variantTitle: json["variant_title"],
    variantOptionValues: json["variant_option_values"],
    requiresShipping: json["requires_shipping"],
    isDiscountable: json["is_discountable"],
    isTaxInclusive: json["is_tax_inclusive"],
    rawCompareAtUnitPrice: json["raw_compare_at_unit_price"],
    rawUnitPrice: json["raw_unit_price"] == null ? null : Raw.fromJson(json["raw_unit_price"]),
    isCustomPrice: json["is_custom_price"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    taxLines: json["tax_lines"] == null ? [] : List<dynamic>.from(json["tax_lines"]!.map((x) => x)),
    adjustments: json["adjustments"] == null ? [] : List<dynamic>.from(json["adjustments"]!.map((x) => x)),
    compareAtUnitPrice: json["compare_at_unit_price"],
    unitPrice: json["unit_price"],
    quantity: json["quantity"],
    rawQuantity: json["raw_quantity"] == null ? null : Raw.fromJson(json["raw_quantity"]),
    detail: json["detail"] == null ? null : Detail.fromJson(json["detail"]),
    subtotal: json["subtotal"],
    total: json["total"],
    originalTotal: json["original_total"],
    discountTotal: json["discount_total"],
    discountSubtotal: json["discount_subtotal"],
    discountTaxTotal: json["discount_tax_total"],
    taxTotal: json["tax_total"],
    originalTaxTotal: json["original_tax_total"],
    refundableTotalPerUnit: json["refundable_total_per_unit"],
    refundableTotal: json["refundable_total"],
    fulfilledTotal: json["fulfilled_total"],
    shippedTotal: json["shipped_total"],
    returnRequestedTotal: json["return_requested_total"],
    returnReceivedTotal: json["return_received_total"],
    returnDismissedTotal: json["return_dismissed_total"],
    writeOffTotal: json["write_off_total"],
    rawSubtotal: json["raw_subtotal"] == null ? null : Raw.fromJson(json["raw_subtotal"]),
    rawTotal: json["raw_total"] == null ? null : Raw.fromJson(json["raw_total"]),
    rawOriginalTotal: json["raw_original_total"] == null ? null : Raw.fromJson(json["raw_original_total"]),
    rawDiscountTotal: json["raw_discount_total"] == null ? null : Raw.fromJson(json["raw_discount_total"]),
    rawDiscountSubtotal: json["raw_discount_subtotal"] == null ? null : Raw.fromJson(json["raw_discount_subtotal"]),
    rawDiscountTaxTotal: json["raw_discount_tax_total"] == null ? null : Raw.fromJson(json["raw_discount_tax_total"]),
    rawTaxTotal: json["raw_tax_total"] == null ? null : Raw.fromJson(json["raw_tax_total"]),
    rawOriginalTaxTotal: json["raw_original_tax_total"] == null ? null : Raw.fromJson(json["raw_original_tax_total"]),
    rawRefundableTotalPerUnit: json["raw_refundable_total_per_unit"] == null ? null : Raw.fromJson(json["raw_refundable_total_per_unit"]),
    rawRefundableTotal: json["raw_refundable_total"] == null ? null : Raw.fromJson(json["raw_refundable_total"]),
    rawFulfilledTotal: json["raw_fulfilled_total"] == null ? null : Raw.fromJson(json["raw_fulfilled_total"]),
    rawShippedTotal: json["raw_shipped_total"] == null ? null : Raw.fromJson(json["raw_shipped_total"]),
    rawReturnRequestedTotal: json["raw_return_requested_total"] == null ? null : Raw.fromJson(json["raw_return_requested_total"]),
    rawReturnReceivedTotal: json["raw_return_received_total"] == null ? null : Raw.fromJson(json["raw_return_received_total"]),
    rawReturnDismissedTotal: json["raw_return_dismissed_total"] == null ? null : Raw.fromJson(json["raw_return_dismissed_total"]),
    rawWriteOffTotal: json["raw_write_off_total"] == null ? null : Raw.fromJson(json["raw_write_off_total"]),
    variant: json["variant"] == null ? null : Variant.fromJson(json["variant"]),
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
    "product_type": productType,
    "product_type_id": productTypeId,
    "product_collection": productCollection,
    "product_handle": productHandle,
    "variant_sku": variantSku,
    "variant_barcode": variantBarcode,
    "variant_title": variantTitle,
    "variant_option_values": variantOptionValues,
    "requires_shipping": requiresShipping,
    "is_discountable": isDiscountable,
    "is_tax_inclusive": isTaxInclusive,
    "raw_compare_at_unit_price": rawCompareAtUnitPrice,
    "raw_unit_price": rawUnitPrice?.toJson(),
    "is_custom_price": isCustomPrice,
    "metadata": metadata?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "tax_lines": taxLines == null ? [] : List<dynamic>.from(taxLines!.map((x) => x)),
    "adjustments": adjustments == null ? [] : List<dynamic>.from(adjustments!.map((x) => x)),
    "compare_at_unit_price": compareAtUnitPrice,
    "unit_price": unitPrice,
    "quantity": quantity,
    "raw_quantity": rawQuantity?.toJson(),
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
    "raw_subtotal": rawSubtotal?.toJson(),
    "raw_total": rawTotal?.toJson(),
    "raw_original_total": rawOriginalTotal?.toJson(),
    "raw_discount_total": rawDiscountTotal?.toJson(),
    "raw_discount_subtotal": rawDiscountSubtotal?.toJson(),
    "raw_discount_tax_total": rawDiscountTaxTotal?.toJson(),
    "raw_tax_total": rawTaxTotal?.toJson(),
    "raw_original_tax_total": rawOriginalTaxTotal?.toJson(),
    "raw_refundable_total_per_unit": rawRefundableTotalPerUnit?.toJson(),
    "raw_refundable_total": rawRefundableTotal?.toJson(),
    "raw_fulfilled_total": rawFulfilledTotal?.toJson(),
    "raw_shipped_total": rawShippedTotal?.toJson(),
    "raw_return_requested_total": rawReturnRequestedTotal?.toJson(),
    "raw_return_received_total": rawReturnReceivedTotal?.toJson(),
    "raw_return_dismissed_total": rawReturnDismissedTotal?.toJson(),
    "raw_write_off_total": rawWriteOffTotal?.toJson(),
    "variant": variant?.toJson(),
  };
}

class Detail {
  String? id;
  String? orderId;
  int? version;
  String? itemId;
  dynamic rawUnitPrice;
  dynamic rawCompareAtUnitPrice;
  Raw? rawQuantity;
  Raw? rawFulfilledQuantity;
  Raw? rawDeliveredQuantity;
  Raw? rawShippedQuantity;
  Raw? rawReturnRequestedQuantity;
  Raw? rawReturnReceivedQuantity;
  Raw? rawReturnDismissedQuantity;
  Raw? rawWrittenOffQuantity;
  dynamic metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  dynamic unitPrice;
  dynamic compareAtUnitPrice;
  int? quantity;
  int? fulfilledQuantity;
  int? deliveredQuantity;
  int? shippedQuantity;
  int? returnRequestedQuantity;
  int? returnReceivedQuantity;
  int? returnDismissedQuantity;
  int? writtenOffQuantity;

  Detail({
    this.id,
    this.orderId,
    this.version,
    this.itemId,
    this.rawUnitPrice,
    this.rawCompareAtUnitPrice,
    this.rawQuantity,
    this.rawFulfilledQuantity,
    this.rawDeliveredQuantity,
    this.rawShippedQuantity,
    this.rawReturnRequestedQuantity,
    this.rawReturnReceivedQuantity,
    this.rawReturnDismissedQuantity,
    this.rawWrittenOffQuantity,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.unitPrice,
    this.compareAtUnitPrice,
    this.quantity,
    this.fulfilledQuantity,
    this.deliveredQuantity,
    this.shippedQuantity,
    this.returnRequestedQuantity,
    this.returnReceivedQuantity,
    this.returnDismissedQuantity,
    this.writtenOffQuantity,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    orderId: json["order_id"],
    version: json["version"],
    itemId: json["item_id"],
    rawUnitPrice: json["raw_unit_price"],
    rawCompareAtUnitPrice: json["raw_compare_at_unit_price"],
    rawQuantity: json["raw_quantity"] == null ? null : Raw.fromJson(json["raw_quantity"]),
    rawFulfilledQuantity: json["raw_fulfilled_quantity"] == null ? null : Raw.fromJson(json["raw_fulfilled_quantity"]),
    rawDeliveredQuantity: json["raw_delivered_quantity"] == null ? null : Raw.fromJson(json["raw_delivered_quantity"]),
    rawShippedQuantity: json["raw_shipped_quantity"] == null ? null : Raw.fromJson(json["raw_shipped_quantity"]),
    rawReturnRequestedQuantity: json["raw_return_requested_quantity"] == null ? null : Raw.fromJson(json["raw_return_requested_quantity"]),
    rawReturnReceivedQuantity: json["raw_return_received_quantity"] == null ? null : Raw.fromJson(json["raw_return_received_quantity"]),
    rawReturnDismissedQuantity: json["raw_return_dismissed_quantity"] == null ? null : Raw.fromJson(json["raw_return_dismissed_quantity"]),
    rawWrittenOffQuantity: json["raw_written_off_quantity"] == null ? null : Raw.fromJson(json["raw_written_off_quantity"]),
    metadata: json["metadata"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    unitPrice: json["unit_price"],
    compareAtUnitPrice: json["compare_at_unit_price"],
    quantity: json["quantity"],
    fulfilledQuantity: json["fulfilled_quantity"],
    deliveredQuantity: json["delivered_quantity"],
    shippedQuantity: json["shipped_quantity"],
    returnRequestedQuantity: json["return_requested_quantity"],
    returnReceivedQuantity: json["return_received_quantity"],
    returnDismissedQuantity: json["return_dismissed_quantity"],
    writtenOffQuantity: json["written_off_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "version": version,
    "item_id": itemId,
    "raw_unit_price": rawUnitPrice,
    "raw_compare_at_unit_price": rawCompareAtUnitPrice,
    "raw_quantity": rawQuantity?.toJson(),
    "raw_fulfilled_quantity": rawFulfilledQuantity?.toJson(),
    "raw_delivered_quantity": rawDeliveredQuantity?.toJson(),
    "raw_shipped_quantity": rawShippedQuantity?.toJson(),
    "raw_return_requested_quantity": rawReturnRequestedQuantity?.toJson(),
    "raw_return_received_quantity": rawReturnReceivedQuantity?.toJson(),
    "raw_return_dismissed_quantity": rawReturnDismissedQuantity?.toJson(),
    "raw_written_off_quantity": rawWrittenOffQuantity?.toJson(),
    "metadata": metadata,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "unit_price": unitPrice,
    "compare_at_unit_price": compareAtUnitPrice,
    "quantity": quantity,
    "fulfilled_quantity": fulfilledQuantity,
    "delivered_quantity": deliveredQuantity,
    "shipped_quantity": shippedQuantity,
    "return_requested_quantity": returnRequestedQuantity,
    "return_received_quantity": returnReceivedQuantity,
    "return_dismissed_quantity": returnDismissedQuantity,
    "written_off_quantity": writtenOffQuantity,
  };
}

class Raw {
  String? value;
  int? precision;

  Raw({
    this.value,
    this.precision,
  });

  factory Raw.fromJson(Map<String, dynamic> json) => Raw(
    value: json["value"],
    precision: json["precision"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "precision": precision,
  };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
  );

  Map<String, dynamic> toJson() => {
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
  Product? product;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

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
    this.product,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
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
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
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
    "product": product?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Product {
  String? id;
  String? title;
  String? handle;
  String? subtitle;
  String? description;
  bool? isGiftcard;
  String? status;
  String? thumbnail;
  dynamic weight;
  dynamic length;
  dynamic height;
  dynamic width;
  dynamic originCountry;
  dynamic hsCode;
  dynamic midCode;
  dynamic material;
  bool? discountable;
  dynamic externalId;
  dynamic metadata;
  dynamic typeId;
  dynamic type;
  String? collectionId;
  Collection? collection;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Product({
    this.id,
    this.title,
    this.handle,
    this.subtitle,
    this.description,
    this.isGiftcard,
    this.status,
    this.thumbnail,
    this.weight,
    this.length,
    this.height,
    this.width,
    this.originCountry,
    this.hsCode,
    this.midCode,
    this.material,
    this.discountable,
    this.externalId,
    this.metadata,
    this.typeId,
    this.type,
    this.collectionId,
    this.collection,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    title: json["title"],
    handle: json["handle"],
    subtitle: json["subtitle"],
    description: json["description"],
    isGiftcard: json["is_giftcard"],
    status: json["status"],
    thumbnail: json["thumbnail"],
    weight: json["weight"],
    length: json["length"],
    height: json["height"],
    width: json["width"],
    originCountry: json["origin_country"],
    hsCode: json["hs_code"],
    midCode: json["mid_code"],
    material: json["material"],
    discountable: json["discountable"],
    externalId: json["external_id"],
    metadata: json["metadata"],
    typeId: json["type_id"],
    type: json["type"],
    collectionId: json["collection_id"],
    collection: json["collection"] == null ? null : Collection.fromJson(json["collection"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "handle": handle,
    "subtitle": subtitle,
    "description": description,
    "is_giftcard": isGiftcard,
    "status": status,
    "thumbnail": thumbnail,
    "weight": weight,
    "length": length,
    "height": height,
    "width": width,
    "origin_country": originCountry,
    "hs_code": hsCode,
    "mid_code": midCode,
    "material": material,
    "discountable": discountable,
    "external_id": externalId,
    "metadata": metadata,
    "type_id": typeId,
    "type": type,
    "collection_id": collectionId,
    "collection": collection?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

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

class PaymentCollection {
  String? id;
  String? currencyCode;
  String? regionId;
  dynamic completedAt;
  String? status;
  dynamic metadata;
  Raw? rawAmount;
  Raw? rawAuthorizedAmount;
  Raw? rawCapturedAmount;
  Raw? rawRefundedAmount;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  num? amount;
  num? authorizedAmount;
  num? capturedAmount;
  num? refundedAmount;

  PaymentCollection({
    this.id,
    this.currencyCode,
    this.regionId,
    this.completedAt,
    this.status,
    this.metadata,
    this.rawAmount,
    this.rawAuthorizedAmount,
    this.rawCapturedAmount,
    this.rawRefundedAmount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.amount,
    this.authorizedAmount,
    this.capturedAmount,
    this.refundedAmount,
  });

  factory PaymentCollection.fromJson(Map<String, dynamic> json) => PaymentCollection(
    id: json["id"],
    currencyCode: json["currency_code"],
    regionId: json["region_id"],
    completedAt: json["completed_at"],
    status: json["status"],
    metadata: json["metadata"],
    rawAmount: json["raw_amount"] == null ? null : Raw.fromJson(json["raw_amount"]),
    rawAuthorizedAmount: json["raw_authorized_amount"] == null ? null : Raw.fromJson(json["raw_authorized_amount"]),
    rawCapturedAmount: json["raw_captured_amount"] == null ? null : Raw.fromJson(json["raw_captured_amount"]),
    rawRefundedAmount: json["raw_refunded_amount"] == null ? null : Raw.fromJson(json["raw_refunded_amount"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    amount: json["amount"],
    authorizedAmount: json["authorized_amount"],
    capturedAmount: json["captured_amount"],
    refundedAmount: json["refunded_amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "region_id": regionId,
    "completed_at": completedAt,
    "status": status,
    "metadata": metadata,
    "raw_amount": rawAmount?.toJson(),
    "raw_authorized_amount": rawAuthorizedAmount?.toJson(),
    "raw_captured_amount": rawCapturedAmount?.toJson(),
    "raw_refunded_amount": rawRefundedAmount?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "amount": amount,
    "authorized_amount": authorizedAmount,
    "captured_amount": capturedAmount,
    "refunded_amount": refundedAmount,
  };
}

class Summary {
  num? paidTotal;
  num? differenceSum;
  Raw? rawPaidTotal;
  num? refundedTotal;
  num? creditLineTotal;
  num? transactionTotal;
  num? pendingDifference;
  Raw? rawDifferenceSum;
  Raw? rawRefundedTotal;
  num? currentOrderTotal;
  num? originalOrderTotal;
  Raw? rawCreditLineTotal;
  Raw? rawTransactionTotal;
  Raw? rawPendingDifference;
  Raw? rawCurrentOrderTotal;
  Raw? rawOriginalOrderTotal;

  Summary({
    this.paidTotal,
    this.differenceSum,
    this.rawPaidTotal,
    this.refundedTotal,
    this.creditLineTotal,
    this.transactionTotal,
    this.pendingDifference,
    this.rawDifferenceSum,
    this.rawRefundedTotal,
    this.currentOrderTotal,
    this.originalOrderTotal,
    this.rawCreditLineTotal,
    this.rawTransactionTotal,
    this.rawPendingDifference,
    this.rawCurrentOrderTotal,
    this.rawOriginalOrderTotal,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    paidTotal: json["paid_total"],
    differenceSum: json["difference_sum"],
    rawPaidTotal: json["raw_paid_total"] == null ? null : Raw.fromJson(json["raw_paid_total"]),
    refundedTotal: json["refunded_total"],
    creditLineTotal: json["credit_line_total"],
    transactionTotal: json["transaction_total"],
    pendingDifference: json["pending_difference"],
    rawDifferenceSum: json["raw_difference_sum"] == null ? null : Raw.fromJson(json["raw_difference_sum"]),
    rawRefundedTotal: json["raw_refunded_total"] == null ? null : Raw.fromJson(json["raw_refunded_total"]),
    currentOrderTotal: json["current_order_total"],
    originalOrderTotal: json["original_order_total"],
    rawCreditLineTotal: json["raw_credit_line_total"] == null ? null : Raw.fromJson(json["raw_credit_line_total"]),
    rawTransactionTotal: json["raw_transaction_total"] == null ? null : Raw.fromJson(json["raw_transaction_total"]),
    rawPendingDifference: json["raw_pending_difference"] == null ? null : Raw.fromJson(json["raw_pending_difference"]),
    rawCurrentOrderTotal: json["raw_current_order_total"] == null ? null : Raw.fromJson(json["raw_current_order_total"]),
    rawOriginalOrderTotal: json["raw_original_order_total"] == null ? null : Raw.fromJson(json["raw_original_order_total"]),
  );

  Map<String, dynamic> toJson() => {
    "paid_total": paidTotal,
    "difference_sum": differenceSum,
    "raw_paid_total": rawPaidTotal?.toJson(),
    "refunded_total": refundedTotal,
    "credit_line_total": creditLineTotal,
    "transaction_total": transactionTotal,
    "pending_difference": pendingDifference,
    "raw_difference_sum": rawDifferenceSum?.toJson(),
    "raw_refunded_total": rawRefundedTotal?.toJson(),
    "current_order_total": currentOrderTotal,
    "original_order_total": originalOrderTotal,
    "raw_credit_line_total": rawCreditLineTotal?.toJson(),
    "raw_transaction_total": rawTransactionTotal?.toJson(),
    "raw_pending_difference": rawPendingDifference?.toJson(),
    "raw_current_order_total": rawCurrentOrderTotal?.toJson(),
    "raw_original_order_total": rawOriginalOrderTotal?.toJson(),
  };
}

