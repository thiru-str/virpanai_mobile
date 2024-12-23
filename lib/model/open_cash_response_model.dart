// To parse this JSON data, do
//
//     final openCashResponse = openCashResponseFromJson(jsonString);

import 'dart:convert';

OpenCashResponse openCashResponseFromJson(String str) => OpenCashResponse.fromJson(json.decode(str));

String openCashResponseToJson(OpenCashResponse data) => json.encode(data.toJson());

class OpenCashResponse {
  int? status;
  String? message;
  Data? data;
  bool? success;
  bool? maintanence;

  OpenCashResponse({
    this.status,
    this.message,
    this.data,
    this.success,
    this.maintanence,
  });

  factory OpenCashResponse.fromJson(Map<String, dynamic> json) => OpenCashResponse(
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
  int? id;
  DateTime? openTime;
  int? openBalance;
  int? branchId;
  int? employeeId;
  String? tenantSlug;

  Data({
    this.id,
    this.openTime,
    this.openBalance,
    this.branchId,
    this.employeeId,
    this.tenantSlug,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    openTime: json["open_time"] == null ? null : DateTime.parse(json["open_time"]),
    openBalance: json["open_balance"],
    branchId: json["branch_id"],
    employeeId: json["employee_id"],
    tenantSlug: json["tenant_slug"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "open_time": openTime?.toIso8601String(),
    "open_balance": openBalance,
    "branch_id": branchId,
    "employee_id": employeeId,
    "tenant_slug": tenantSlug,
  };
}
