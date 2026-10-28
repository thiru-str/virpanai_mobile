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
  String? status;
  bool? success;
  String? message;
  String? reason;
  VerifyOtpError? error;

  VerifyOtpResponse({
    this.token,
    this.newUser,
    this.status,
    this.success,
    this.message,
    this.reason,
    this.error,
  });

  /// Why sign-in was refused, e.g. "Wait for approval" or "Account blocked."
  String? get errorMessage => error?.message;

  /// The backend answers 200 with `status: "error"` and an empty token when
  /// the account may not sign in yet.
  bool get isRefused =>
      status == 'error' || (newUser != true && (token ?? '').isEmpty);

  bool get hasFailure =>
      status == 'error' || success == false || (error?.hasDetails ?? false);

  String get failureMessage =>
      error?.message ?? message ?? reason ?? 'Unable to log in';

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        token: json["token"],
        newUser: json["newUser"],
        status: json["status"]?.toString(),
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
        "status": status,
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
        code: json['code']?.toString(),
        message: json['message']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };
}
