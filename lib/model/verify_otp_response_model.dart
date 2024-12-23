// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) => VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) => json.encode(data.toJson());

class VerifyOtpResponse {
  int? status;
  String? message;
  Data? data;
  bool? success;
  bool? maintanence;

  VerifyOtpResponse({
    this.status,
    this.message,
    this.data,
    this.success,
    this.maintanence,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    success: json["success"],
    maintanence: json["maintanence"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "success": success,
    "maintanence": maintanence,
  };
}

class Data {
  String? tenantId;

  Data({
    this.tenantId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    tenantId: json["tenant_id"],
  );

  Map<String, dynamic> toJson() => {
    "tenant_id": tenantId,
  };
}
