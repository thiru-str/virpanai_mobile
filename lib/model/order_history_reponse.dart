// To parse this JSON data, do
//
//     final orderHistoryResponse = orderHistoryResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/ui/cart_response.dart';

OrderHistoryResponse orderHistoryResponseFromJson(String str) => OrderHistoryResponse.fromJson(json.decode(str));

String orderHistoryResponseToJson(OrderHistoryResponse data) => json.encode(data.toJson());

class OrderHistoryResponse {
  List<Order>? orders;
  int? count;
  int? offset;
  int? limit;

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
  int? displayId;
  double? total;
  String? currencyCode;
  dynamic metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? subtotal;
  double? taxTotal;
  int? version;
  List<Item>? items;
  String? paymentStatus;
  String? fulfillmentStatus;
  Cart? cart;

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
    this.cart,
    this.paymentStatus,
    this.fulfillmentStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    status: json["status"],
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    displayId: json["display_id"],
    total: json["total"]?.toDouble(),
    currencyCode: json["currency_code"],
    metadata: json["metadata"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    subtotal: json["subtotal"],
    taxTotal: json["tax_total"]?.toDouble(),
    version: json["version"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
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
    "metadata": metadata,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "subtotal": subtotal,
    "tax_total": taxTotal,
    "version": version,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "cart": cart?.toJson(),
    "payment_status": paymentStatus,
    "fulfillment_status": fulfillmentStatus,
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

class TaxLine {
  String? id;
  String? description;
  String? taxRateId;
  String? code;
  Raw? rawRate;
  String? providerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? itemId;
  int? rate;
  double? total;
  double? subtotal;
  Raw? rawTotal;
  Raw? rawSubtotal;

  TaxLine({
    this.id,
    this.description,
    this.taxRateId,
    this.code,
    this.rawRate,
    this.providerId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.itemId,
    this.rate,
    this.total,
    this.subtotal,
    this.rawTotal,
    this.rawSubtotal,
  });

  factory TaxLine.fromJson(Map<String, dynamic> json) => TaxLine(
    id: json["id"],
    description: json["description"],
    taxRateId: json["tax_rate_id"],
    code: json["code"],
    rawRate: json["raw_rate"] == null ? null : Raw.fromJson(json["raw_rate"]),
    providerId: json["provider_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    itemId: json["item_id"],
    rate: json["rate"],
    total: json["total"]?.toDouble(),
    subtotal: json["subtotal"]?.toDouble(),
    rawTotal: json["raw_total"] == null ? null : Raw.fromJson(json["raw_total"]),
    rawSubtotal: json["raw_subtotal"] == null ? null : Raw.fromJson(json["raw_subtotal"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "tax_rate_id": taxRateId,
    "code": code,
    "raw_rate": rawRate?.toJson(),
    "provider_id": providerId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "item_id": itemId,
    "rate": rate,
    "total": total,
    "subtotal": subtotal,
    "raw_total": rawTotal?.toJson(),
    "raw_subtotal": rawSubtotal?.toJson(),
  };
}

class Summary {
  int? paidTotal;
  int? differenceSum;
  Raw? rawPaidTotal;
  int? refundedTotal;
  int? creditLineTotal;
  int? transactionTotal;
  double? pendingDifference;
  Raw? rawDifferenceSum;
  Raw? rawRefundedTotal;
  double? currentOrderTotal;
  double? originalOrderTotal;
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
    pendingDifference: json["pending_difference"]?.toDouble(),
    rawDifferenceSum: json["raw_difference_sum"] == null ? null : Raw.fromJson(json["raw_difference_sum"]),
    rawRefundedTotal: json["raw_refunded_total"] == null ? null : Raw.fromJson(json["raw_refunded_total"]),
    currentOrderTotal: json["current_order_total"]?.toDouble(),
    originalOrderTotal: json["original_order_total"]?.toDouble(),
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
