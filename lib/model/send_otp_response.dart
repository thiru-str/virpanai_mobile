// To parse this JSON data, do
//
//     final sendOtpResponse = sendOtpResponseFromJson(jsonString);

import 'dart:convert';

SendOtpResponse sendOtpResponseFromJson(String str) => SendOtpResponse.fromJson(json.decode(str));

String sendOtpResponseToJson(SendOtpResponse data) => json.encode(data.toJson());

class SendOtpResponse {
  String? message;
  String? otp;

  SendOtpResponse({
    this.message,
    this.otp,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) => SendOtpResponse(
    message: json["message"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "otp": otp,
  };
}
