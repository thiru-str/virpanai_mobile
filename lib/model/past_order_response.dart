// To parse this JSON data, do
//
//     final pastOrderResponse = pastOrderResponseFromJson(jsonString);

import 'dart:convert';

PastOrderResponse pastOrderResponseFromJson(String str) => PastOrderResponse.fromJson(json.decode(str));

String pastOrderResponseToJson(PastOrderResponse data) => json.encode(data.toJson());

class PastOrderResponse {
  String? status;
  int? count;
  int? limit;
  int? offset;
  List<PastOrder>? pastOrders;

  PastOrderResponse({
    this.status,
    this.count,
    this.limit,
    this.offset,
    this.pastOrders,
  });

  factory PastOrderResponse.fromJson(Map<String, dynamic> json) => PastOrderResponse(
    status: json["status"],
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
    pastOrders: json["past_orders"] == null ? [] : List<PastOrder>.from(json["past_orders"]!.map((x) => PastOrder.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "count": count,
    "limit": limit,
    "offset": offset,
    "past_orders": pastOrders == null ? [] : List<dynamic>.from(pastOrders!.map((x) => x.toJson())),
  };
}

class PastOrder {
  String? date;
  DateTime? formatedDate;
  Data? data;

  PastOrder({
    this.date,
    this.formatedDate,
    this.data,
  });

  factory PastOrder.fromJson(Map<String, dynamic> json) => PastOrder(
    date: json["date"],
    formatedDate: json["formated_date"] == null ? null : DateTime.parse(json["formated_date"]),
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "formated_date": "${formatedDate!.year.toString().padLeft(4, '0')}-${formatedDate!.month.toString().padLeft(2, '0')}-${formatedDate!.day.toString().padLeft(2, '0')}",
    "data": data?.toJson(),
  };
}

class Data {
  String? totalPrice;
  String? noOfProducts;
  List<String>? customerImages;
  int? totalOrders;

  Data({
    this.totalPrice,
    this.noOfProducts,
    this.customerImages,
    this.totalOrders,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalPrice: json["total_price"],
    noOfProducts: json["no_of_products"],
    customerImages: json["customer_images"] == null ? [] : List<String>.from(json["customer_images"]!.map((x) => x)),
    totalOrders: json["total_orders"],
  );

  Map<String, dynamic> toJson() => {
    "total_price": totalPrice,
    "no_of_products": noOfProducts,
    "customer_images": customerImages == null ? [] : List<dynamic>.from(customerImages!.map((x) => x)),
    "total_orders": totalOrders,
  };
}
