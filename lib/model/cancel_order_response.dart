// To parse this JSON data, do
//
//     final cancelOrderResponse = cancelOrderResponseFromJson(jsonString);

import 'dart:convert';

CancelOrderResponse cancelOrderResponseFromJson(String str) => CancelOrderResponse.fromJson(json.decode(str));

String cancelOrderResponseToJson(CancelOrderResponse data) => json.encode(data.toJson());

class CancelOrderResponse {
  bool? status;
  Error? error;

  CancelOrderResponse({
    this.status,
    this.error,
  });

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) => CancelOrderResponse(
    status: json["status"],
    error: json["error"] == null ? null : Error.fromJson(json["error"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error?.toJson(),
  };
}

class Error {
  Error();

  factory Error.fromJson(Map<String, dynamic> json) => Error(
  );

  Map<String, dynamic> toJson() => {
  };
}
