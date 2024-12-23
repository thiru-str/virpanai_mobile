// To parse this JSON data, do
//
//     final applyBeanResponse = applyBeanResponseFromJson(jsonString);

import 'dart:convert';

ApplyBeanResponse applyBeanResponseFromJson(String str) => ApplyBeanResponse.fromJson(json.decode(str));

String applyBeanResponseToJson(ApplyBeanResponse data) => json.encode(data.toJson());

class ApplyBeanResponse {
  int? status;
  String? message;
  Data? data;
  bool? success;
  bool? maintanence;

  ApplyBeanResponse({
    this.status,
    this.message,
    this.data,
    this.success,
    this.maintanence,
  });

  factory ApplyBeanResponse.fromJson(Map<String, dynamic> json) => ApplyBeanResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    success: json["success"],
    maintanence: json["maintanence"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "success": success,
    "maintanence": maintanence,
  };
}

class Data {
  int? beanEarned;
  String? discountPrice;
  String? totalPrice;

  Data({
    this.beanEarned,
    this.discountPrice,
    this.totalPrice,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    beanEarned: json["bean_earned"],
    discountPrice: json["discount_price"],
    totalPrice: json["total_price"],
  );

  Map<String, dynamic> toJson() => {
    "bean_earned": beanEarned,
    "discount_price": discountPrice,
    "total_price": totalPrice,
  };
}
