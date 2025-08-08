// To parse this JSON data, do
//
//     final checkPinCodeResponse = checkPinCodeResponseFromJson(jsonString);

import 'dart:convert';

CheckPinCodeResponse checkPinCodeResponseFromJson(String str) => CheckPinCodeResponse.fromJson(json.decode(str));

String checkPinCodeResponseToJson(CheckPinCodeResponse data) => json.encode(data.toJson());

class CheckPinCodeResponse {
  bool? status;
  Error? error;

  CheckPinCodeResponse({
    this.status,
    this.error,
  });

  factory CheckPinCodeResponse.fromJson(Map<String, dynamic> json) => CheckPinCodeResponse(
    status: json["status"],
    error: json["error"] == null ? null : Error.fromJson(json["error"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error?.toJson(),
  };
}

class Error {
  String? message;

  Error({
    this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
