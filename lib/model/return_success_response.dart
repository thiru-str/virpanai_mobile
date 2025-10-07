// To parse this JSON data, do
//
//     final returnSuccessResponse = returnSuccessResponseFromJson(jsonString);

import 'dart:convert';

ReturnSuccessResponse returnSuccessResponseFromJson(String str) => ReturnSuccessResponse.fromJson(json.decode(str));

String returnSuccessResponseToJson(ReturnSuccessResponse data) => json.encode(data.toJson());

class ReturnSuccessResponse {
  bool? status;
  String? message;

  ReturnSuccessResponse({
    this.status,
    this.message,
  });

  factory ReturnSuccessResponse.fromJson(Map<String, dynamic> json) => ReturnSuccessResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
