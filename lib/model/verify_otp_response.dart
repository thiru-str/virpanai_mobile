// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) =>
    VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) =>
    json.encode(data.toJson());

class VerifyOtpResponse {
  String? token;
  bool? newUser;
  bool? success;
  String? message;
  String? reason;
  VerifyOtpError? error;

  VerifyOtpResponse({
    this.token,
    this.newUser,
    this.success,
    this.message,
    this.reason,
    this.error,
  });

  bool get hasFailure => success == false || (error?.hasDetails ?? false);

  String get failureMessage =>
      error?.message ?? message ?? reason ?? 'Unable to log in';

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        token: json["token"],
        newUser: json["newUser"],
        success: json["success"],
        message: json["message"],
        reason: json["reason"],
        error: json["error"] is Map<String, dynamic>
            ? VerifyOtpError.fromJson(json["error"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "newUser": newUser,
        "success": success,
        "message": message,
        "reason": reason,
        "error": error?.toJson(),
      };
}

class VerifyOtpError {
  String? code;
  String? message;

  VerifyOtpError({this.code, this.message});

  bool get hasDetails =>
      (code?.trim().isNotEmpty ?? false) ||
      (message?.trim().isNotEmpty ?? false);

  factory VerifyOtpError.fromJson(Map<String, dynamic> json) => VerifyOtpError(
        code: json['code'],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };
}
