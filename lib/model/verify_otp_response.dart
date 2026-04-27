// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) => VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) => json.encode(data.toJson());

class VerifyOtpResponse {
  String? token;
  bool? newUser;
  Error? error;

  VerifyOtpResponse({
    this.token,
    this.newUser,
    this.error,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
    token: json["token"],
    newUser: json["newUser"],
    error: json["error"] == null ? null : Error.fromJson(json["error"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "newUser": newUser,
    "error": error?.toJson(),
  };
}

class Error {
  String? code;
  String? message;

  Error({
    this.code,
    this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
    code: json["code"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
  };
}
