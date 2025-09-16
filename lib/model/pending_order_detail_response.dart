// To parse this JSON data, do
//
//     final pastOrderDetailResponse = pastOrderDetailResponseFromJson(jsonString);

import 'dart:convert';

PendingOrderDetailResponse pastOrderDetailResponseFromJson(String str) => PendingOrderDetailResponse.fromJson(json.decode(str));

String pastOrderDetailResponseToJson(PendingOrderDetailResponse data) => json.encode(data.toJson());

class PendingOrderDetailResponse {
  String? status;
  int? count;
  int? limit;
  int? offset;
  List<PastOrderDetail>? pendingOrderDetails;

  PendingOrderDetailResponse({
    this.status,
    this.count,
    this.limit,
    this.offset,
    this.pendingOrderDetails,
  });

  factory PendingOrderDetailResponse.fromJson(Map<String, dynamic> json) => PendingOrderDetailResponse(
    status: json["status"],
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
    pendingOrderDetails: json["pending_order_details"] == null ? [] : List<PastOrderDetail>.from(json["pending_order_details"]!.map((x) => PastOrderDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "count": count,
    "limit": limit,
    "offset": offset,
    "past_order_details": pendingOrderDetails == null ? [] : List<dynamic>.from(pendingOrderDetails!.map((x) => x.toJson())),
  };
}

class PastOrderDetail {
  String? id;
  int? displayId;
  String? fulfillmentId;
  String? shopName;
  String? shopImage;
  String? shopAddress;
  String? noOfProducts;
  String? totalPrice;
  String? orderStatus;
  String? paymentMethod;

  PastOrderDetail({
    this.id,
    this.displayId,
    this.fulfillmentId,
    this.shopName,
    this.shopImage,
    this.shopAddress,
    this.noOfProducts,
    this.totalPrice,
    this.orderStatus,
    this.paymentMethod,
  });

  factory PastOrderDetail.fromJson(Map<String, dynamic> json) => PastOrderDetail(
    id: json["id"],
    displayId: json["display_id"],
    fulfillmentId: json["fulfillment_id"],
    shopName: json["shop_name"],
    shopImage: json["shop_image"],
    shopAddress: json["shop_address"],
    noOfProducts: json["no_of_products"],
    totalPrice: json["total_price"],
    orderStatus: json["order_status"],
    paymentMethod: json["payment_method"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "display_id": displayId,
    "fulfillment_id": fulfillmentId,
    "shop_name": shopName,
    "shop_image": shopImage,
    "shop_address": shopAddress,
    "no_of_products": noOfProducts,
    "total_price": totalPrice,
    "order_status": orderStatus,
    "payment_method": paymentMethod,
  };
}
