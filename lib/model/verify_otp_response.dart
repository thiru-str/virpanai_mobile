// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) => VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) => json.encode(data.toJson());

class VerifyOtpResponse {
  String? token;
  bool? newUser;

  VerifyOtpResponse({
    this.token,
    this.newUser,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
    token: json["token"],
    newUser: json["newUser"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "newUser": newUser,
  };
}
