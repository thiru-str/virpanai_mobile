// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse verifyOtpResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String? token;
  bool? newUser;
  Error? error;

  LoginResponse({
    this.token,
    this.newUser,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json["token"],
    newUser: json["newUser"],
    error: json["error"] == null ? null : Error.fromJson(json["error"]), // <-- Deserialize
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
    message: json["message"]
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
  };
}
