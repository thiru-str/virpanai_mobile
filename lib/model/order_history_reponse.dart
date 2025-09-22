// To parse this JSON data, do
//
//     final orderHistoryResponse = orderHistoryResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/shipping_response.dart';
import 'package:waioz/ui/cart_response.dart';

// To parse this JSON data, do
//
//     final orderHistoryResponse = orderHistoryResponseFromJson(jsonString);

import 'dart:convert';

OrderHistoryResponse orderHistoryResponseFromJson(String str) => OrderHistoryResponse.fromJson(json.decode(str));

String orderHistoryResponseToJson(OrderHistoryResponse data) => json.encode(data.toJson());

class OrderHistoryResponse {
  List<Order>? orders;
  num? count;
  num? offset;
  num? limit;

  OrderHistoryResponse({
    this.orders,
    this.count,
    this.offset,
    this.limit,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) => OrderHistoryResponse(
    orders: json["orders"] == null ? [] : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
    count: json["count"],
    offset: json["offset"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "orders": orders == null ? [] : List<dynamic>.from(orders!.map((x) => x.toJson())),
    "count": count,
    "offset": offset,
    "limit": limit,
  };
}

class Order {
  String? id;
  String? status;
  Summary? summary;
  num? displayId;
  num? total;
  String? currencyCode;
  Metadata? metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  num? subtotal;
  num? taxTotal;
  num? version;
  List<Item>? items;
  List<PaymentCollection>? paymentCollections;
  Cart? cart;
  String? paymentStatus;
  String? fulfillmentStatus;

  Order({
    this.id,
    this.status,
    this.summary,
    this.displayId,
    this.total,
    this.currencyCode,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.subtotal,
    this.taxTotal,
    this.version,
    this.items,
    this.paymentCollections,
    this.cart,
    this.paymentStatus,
    this.fulfillmentStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    status: json["status"],
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    displayId: json["display_id"],
    total: json["total"],
    currencyCode: json["currency_code"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    subtotal: json["subtotal"],
    taxTotal: json["tax_total"],
    version: json["version"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    paymentCollections: json["payment_collections"] == null ? [] : List<PaymentCollection>.from(json["payment_collections"]!.map((x) => PaymentCollection.fromJson(x))),
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
    paymentStatus: json["payment_status"],
    fulfillmentStatus: json["fulfillment_status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "summary": summary?.toJson(),
    "display_id": displayId,
    "total": total,
    "currency_code": currencyCode,
    "metadata": metadata?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "subtotal": subtotal,
    "tax_total": taxTotal,
    "version": version,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "payment_collections": paymentCollections == null ? [] : List<dynamic>.from(paymentCollections!.map((x) => x.toJson())),
    "cart": cart?.toJson(),
    "payment_status": paymentStatus,
    "fulfillment_status": fulfillmentStatus,
  };
}

class Metadata {
  String? fulfillmentStatus;
  String? invoice;

  Metadata({
    this.fulfillmentStatus,
    this.invoice,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    fulfillmentStatus: json["fulfillment_status"],
    invoice: json["invoice"],
  );

  Map<String, dynamic> toJson() => {
    "fulfillment_status": fulfillmentStatus,
    "invoice": invoice,
  };
}

class Cart {
  String? id;
  ShippingAddress? shippingAddress;

  Cart({
    this.id,
    this.shippingAddress,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["id"],
    shippingAddress: json["shipping_address"] == null ? null : ShippingAddress.fromJson(json["shipping_address"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "shipping_address": shippingAddress?.toJson(),
  };
}

class ShippingAddress {
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

  ShippingAddress({
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

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
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
  List<Adjustment>? adjustments;
  Metadata? metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic productType;
  dynamic productTypeId;
  dynamic variantBarcode;
  dynamic variantOptionValues;
  Raw? rawCompareAtUnitPrice;
  dynamic deletedAt;
  num? compareAtUnitPrice;
  num? unitPrice;
  num? quantity;
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
    taxLines: json["tax_lines"] == null ? [] : List<dynamic>.from(json["tax_lines"]!.map((x) => x)),
    adjustments: json["adjustments"] == null ? [] : List<Adjustment>.from(json["adjustments"]!.map((x) => Adjustment.fromJson(x))),
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    productType: json["product_type"],
    productTypeId: json["product_type_id"],
    variantBarcode: json["variant_barcode"],
    variantOptionValues: json["variant_option_values"],
    rawCompareAtUnitPrice: json["raw_compare_at_unit_price"] == null ? null : Raw.fromJson(json["raw_compare_at_unit_price"]),
    deletedAt: json["deleted_at"],
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
    "raw_unit_price": rawUnitPrice?.toJson(),
    "is_custom_price": isCustomPrice,
    "tax_lines": taxLines == null ? [] : List<dynamic>.from(taxLines!.map((x) => x)),
    "adjustments": adjustments == null ? [] : List<dynamic>.from(adjustments!.map((x) => x.toJson())),
    "metadata": metadata?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "product_type": productType,
    "product_type_id": productTypeId,
    "variant_barcode": variantBarcode,
    "variant_option_values": variantOptionValues,
    "raw_compare_at_unit_price": rawCompareAtUnitPrice?.toJson(),
    "deleted_at": deletedAt,
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
  };
}

class Adjustment {
  String? id;
  dynamic description;
  String? promotionId;
  String? code;
  Raw? rawAmount;
  String? providerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? itemId;
  num? amount;
  num? subtotal;
  num? total;
  Raw? rawSubtotal;
  Raw? rawTotal;

  Adjustment({
    this.id,
    this.description,
    this.promotionId,
    this.code,
    this.rawAmount,
    this.providerId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.itemId,
    this.amount,
    this.subtotal,
    this.total,
    this.rawSubtotal,
    this.rawTotal,
  });

  factory Adjustment.fromJson(Map<String, dynamic> json) => Adjustment(
    id: json["id"],
    description: json["description"],
    promotionId: json["promotion_id"],
    code: json["code"],
    rawAmount: json["raw_amount"] == null ? null : Raw.fromJson(json["raw_amount"]),
    providerId: json["provider_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    itemId: json["item_id"],
    amount: json["amount"],
    subtotal: json["subtotal"],
    total: json["total"],
    rawSubtotal: json["raw_subtotal"] == null ? null : Raw.fromJson(json["raw_subtotal"]),
    rawTotal: json["raw_total"] == null ? null : Raw.fromJson(json["raw_total"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "promotion_id": promotionId,
    "code": code,
    "raw_amount": rawAmount?.toJson(),
    "provider_id": providerId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "item_id": itemId,
    "amount": amount,
    "subtotal": subtotal,
    "total": total,
    "raw_subtotal": rawSubtotal?.toJson(),
    "raw_total": rawTotal?.toJson(),
  };
}

class Raw {
  String? value;
  num? precision;

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

class Detail {
  String? id;
  String? orderId;
  num? version;
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
  num? quantity;
  num? fulfilledQuantity;
  num? deliveredQuantity;
  num? shippedQuantity;
  num? returnRequestedQuantity;
  num? returnReceivedQuantity;
  num? returnDismissedQuantity;
  num? writtenOffQuantity;

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

class PaymentCollection {
  String? status;
  num? amount;
  num? capturedAmount;
  num? refundedAmount;
  String? id;
  List<Payment>? payments;

  PaymentCollection({
    this.status,
    this.amount,
    this.capturedAmount,
    this.refundedAmount,
    this.id,
    this.payments,
  });

  factory PaymentCollection.fromJson(Map<String, dynamic> json) => PaymentCollection(
    status: json["status"],
    amount: json["amount"],
    capturedAmount: json["captured_amount"],
    refundedAmount: json["refunded_amount"],
    id: json["id"],
    payments: json["payments"] == null ? [] : List<Payment>.from(json["payments"]!.map((x) => Payment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "amount": amount,
    "captured_amount": capturedAmount,
    "refunded_amount": refundedAmount,
    "id": id,
    "payments": payments == null ? [] : List<dynamic>.from(payments!.map((x) => x.toJson())),
  };
}

class Payment {
  String? id;
  String? currencyCode;
  String? providerId;
  Data? data;
  dynamic metadata;
  DateTime? capturedAt;
  dynamic canceledAt;
  String? paymentCollectionId;
  Data? paymentSession;
  Raw? rawAmount;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? paymentSessionId;
  num? amount;

  Payment({
    this.id,
    this.currencyCode,
    this.providerId,
    this.data,
    this.metadata,
    this.capturedAt,
    this.canceledAt,
    this.paymentCollectionId,
    this.paymentSession,
    this.rawAmount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.paymentSessionId,
    this.amount,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    currencyCode: json["currency_code"],
    providerId: json["provider_id"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    metadata: json["metadata"],
    capturedAt: json["captured_at"] == null ? null : DateTime.parse(json["captured_at"]),
    canceledAt: json["canceled_at"],
    paymentCollectionId: json["payment_collection_id"],
    paymentSession: json["payment_session"] == null ? null : Data.fromJson(json["payment_session"]),
    rawAmount: json["raw_amount"] == null ? null : Raw.fromJson(json["raw_amount"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    paymentSessionId: json["payment_session_id"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "provider_id": providerId,
    "data": data?.toJson(),
    "metadata": metadata,
    "captured_at": capturedAt?.toIso8601String(),
    "canceled_at": canceledAt,
    "payment_collection_id": paymentCollectionId,
    "payment_session": paymentSession?.toJson(),
    "raw_amount": rawAmount?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "payment_session_id": paymentSessionId,
    "amount": amount,
  };
}