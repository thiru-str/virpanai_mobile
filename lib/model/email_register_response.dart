// To parse this JSON data, do
//
//     final emailRegisterResponse = emailRegisterResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/register_response.dart';

EmailRegisterResponse emailRegisterResponseFromJson(String str) => EmailRegisterResponse.fromJson(json.decode(str));

String emailRegisterResponseToJson(EmailRegisterResponse data) => json.encode(data.toJson());

class EmailRegisterResponse {
  bool? status;
  String? token;
  Error? error;
  Customer? customer;

  EmailRegisterResponse({
    this.status,
    this.token,
    this.error,
    this.customer,
  });

  factory EmailRegisterResponse.fromJson(Map<String, dynamic> json) => EmailRegisterResponse(
    status: json["status"],
    token: json["token"],
    error: json["error"] == null ? null : Error.fromJson(json["error"]),
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "token": token,
    "error": error?.toJson(),
    "customer": customer?.toJson(),
  };
}

class Error {
  Error();

  factory Error.fromJson(Map<String, dynamic> json) => Error(
  );

  Map<String, dynamic> toJson() => {
  };
}
