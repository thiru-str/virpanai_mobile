// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) => VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) => json.encode(data.toJson());

class VerifyOtpResponse {
  String? token;
  bool? newUser;
  String? status;

  /// Why sign-in was refused, e.g. "Wait for approval" or "Account blocked."
  String? errorMessage;

  VerifyOtpResponse({
    this.token,
    this.newUser,
    this.status,
    this.errorMessage,
  });

  /// The backend answers 200 with `status: "error"` and an empty token when
  /// the account may not sign in yet.
  bool get isRefused =>
      status == 'error' || (newUser != true && (token ?? '').isEmpty);

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
    token: json["token"],
    newUser: json["newUser"],
    status: json["status"]?.toString(),
    errorMessage: json["error"] is Map ? json["error"]["message"]?.toString() : null,
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "newUser": newUser,
  };
}
