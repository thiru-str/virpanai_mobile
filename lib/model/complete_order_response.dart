// To parse this JSON data, do
//
//     final completeOrderResponse = completeOrderResponseFromJson(jsonString);

import 'dart:convert';

CompleteOrderResponse completeOrderResponseFromJson(String str) => CompleteOrderResponse.fromJson(json.decode(str));

String completeOrderResponseToJson(CompleteOrderResponse data) => json.encode(data.toJson());

class CompleteOrderResponse {
  String? status;
  String? message;

  CompleteOrderResponse({
    this.status,
    this.message,
  });

  factory CompleteOrderResponse.fromJson(Map<String, dynamic> json) => CompleteOrderResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
