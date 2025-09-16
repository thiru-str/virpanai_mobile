// To parse this JSON data, do
//
//     final liveOrdersResponse = liveOrdersResponseFromJson(jsonString);

import 'dart:convert';

LiveOrdersResponse liveOrdersResponseFromJson(String str) => LiveOrdersResponse.fromJson(json.decode(str));

String liveOrdersResponseToJson(LiveOrdersResponse data) => json.encode(data.toJson());

class LiveOrdersResponse {
  String? status;
  int? count;
  int? limit;
  int? offset;
  String? ledgerBalance;
  bool? hasPending;
  num? rawLedgerBalance;
  List<LiveOrder>? liveOrders;

  LiveOrdersResponse({
    this.status,
    this.count,
    this.limit,
    this.offset,
    this.ledgerBalance,
    this.hasPending,
    this.rawLedgerBalance,
    this.liveOrders,
  });

  factory LiveOrdersResponse.fromJson(Map<String, dynamic> json) => LiveOrdersResponse(
    status: json["status"],
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
    ledgerBalance: json["ledger_balance"],
    hasPending: json["has_pending"],
    rawLedgerBalance: json["raw_ledger_balance"],
    liveOrders: json["live_orders"] == null ? [] : List<LiveOrder>.from(json["live_orders"]!.map((x) => LiveOrder.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "count": count,
    "limit": limit,
    "offset": offset,
    "ledger_balance": ledgerBalance,
    "has_pending": hasPending,
    "raw_ledger_balance": rawLedgerBalance,
    "live_orders": liveOrders == null ? [] : List<dynamic>.from(liveOrders!.map((x) => x.toJson())),
  };
}

class LiveOrder {
  String? id;
  int? displayId;
  String? shopName;
  String? shopImage;
  String? shopAddress;
  String? noOfProducts;
  String? totalPrice;

  LiveOrder({
    this.id,
    this.displayId,
    this.shopName,
    this.shopImage,
    this.shopAddress,
    this.noOfProducts,
    this.totalPrice,
  });

  factory LiveOrder.fromJson(Map<String, dynamic> json) => LiveOrder(
    id: json["id"],
    displayId: json["display_id"],
    shopName: json["shop_name"],
    shopImage: json["shop_image"],
    shopAddress: json["shop_address"],
    noOfProducts: json["no_of_products"],
    totalPrice: json["total_price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "display_id": displayId,
    "shop_name": shopName,
    "shop_image": shopImage,
    "shop_address": shopAddress,
    "no_of_products": noOfProducts,
    "total_price": totalPrice,
  };
}
