// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  int? status;
  String? message;
  Data? data;
  bool? success;
  bool? maintanence;

  LoginResponse({
    this.status,
    this.message,
    this.data,
    this.success,
    this.maintanence,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
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
  String? loginTime;
  int? id;
  String? tenantSlug;
  String? employeeName;
  String? password;
  int? createdBy;
  bool? isLoggedIn;
  bool? isDeleted;
  DateTime? createdAt;
  String? color;
  String? token;

  Data({
    this.loginTime,
    this.id,
    this.tenantSlug,
    this.employeeName,
    this.password,
    this.createdBy,
    this.isLoggedIn,
    this.isDeleted,
    this.createdAt,
    this.color,
    this.token,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    loginTime: json["login_time"],
    id: json["_id"],
    tenantSlug: json["tenant_slug"],
    employeeName: json["employee_name"],
    password: json["password"],
    createdBy: json["created_by"],
    isLoggedIn: json["is_logged_in"],
    isDeleted: json["is_deleted"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    color: json["color"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "login_time": loginTime,
    "_id": id,
    "tenant_slug": tenantSlug,
    "employee_name": employeeName,
    "password": password,
    "created_by": createdBy,
    "is_logged_in": isLoggedIn,
    "is_deleted": isDeleted,
    "created_at": createdAt?.toIso8601String(),
    "color": color,
    "token": token,
  };
}
