// To parse this JSON data, do
//
//     final customerDetailResponse = customerDetailResponseFromJson(jsonString);

import 'dart:convert';

CustomerDetailResponse customerDetailResponseFromJson(String str) => CustomerDetailResponse.fromJson(json.decode(str));

String customerDetailResponseToJson(CustomerDetailResponse data) => json.encode(data.toJson());

class CustomerDetailResponse {
  bool? status;
  Data? data;

  CustomerDetailResponse({
    this.status,
    this.data,
  });

  factory CustomerDetailResponse.fromJson(Map<String, dynamic> json) => CustomerDetailResponse(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  String? companyName;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  bool? hasAccount;
  Metadata? metadata;
  dynamic createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Data({
    this.id,
    this.companyName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.hasAccount,
    this.metadata,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    companyName: json["company_name"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    hasAccount: json["has_account"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company_name": companyName,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "has_account": hasAccount,
    "metadata": metadata?.toJson(),
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Metadata {
  String? deviceId;
  String? lastUsed;
  String? lastLogin;
  String? countryCode;

  Metadata({
    this.deviceId,
    this.lastUsed,
    this.lastLogin,
    this.countryCode,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    deviceId: json["device_id"],
    lastUsed: json["last_used"],
    lastLogin: json["last_login"],
    countryCode: json["country_code"],
  );

  Map<String, dynamic> toJson() => {
    "device_id": deviceId,
    "last_used": lastUsed,
    "last_login": lastLogin,
    "country_code": countryCode,
  };
}
