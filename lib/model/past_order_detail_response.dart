// To parse this JSON data, do
//
//     final pastOrderDetailResponse = pastOrderDetailResponseFromJson(jsonString);

import 'dart:convert';

PastOrderDetailResponse pastOrderDetailResponseFromJson(String str) => PastOrderDetailResponse.fromJson(json.decode(str));

String pastOrderDetailResponseToJson(PastOrderDetailResponse data) => json.encode(data.toJson());

class PastOrderDetailResponse {
  String? status;
  int? count;
  int? limit;
  int? offset;
  List<PastOrderDetail>? pastOrderDetails;

  PastOrderDetailResponse({
    this.status,
    this.count,
    this.limit,
    this.offset,
    this.pastOrderDetails,
  });

  factory PastOrderDetailResponse.fromJson(Map<String, dynamic> json) => PastOrderDetailResponse(
    status: json["status"],
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
    pastOrderDetails: json["past_order_details"] == null ? [] : List<PastOrderDetail>.from(json["past_order_details"]!.map((x) => PastOrderDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "count": count,
    "limit": limit,
    "offset": offset,
    "past_order_details": pastOrderDetails == null ? [] : List<dynamic>.from(pastOrderDetails!.map((x) => x.toJson())),
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
