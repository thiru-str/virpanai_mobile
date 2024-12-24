// To parse this JSON data, do
//
//     final registerResponse = registerResponseFromJson(jsonString);

import 'dart:convert';

RegisterResponse registerResponseFromJson(String str) => RegisterResponse.fromJson(json.decode(str));

String registerResponseToJson(RegisterResponse data) => json.encode(data.toJson());

class RegisterResponse {
  Customer? customer;

  RegisterResponse({
    this.customer,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "customer": customer?.toJson(),
  };
}

class Customer {
  String? id;
  String? email;
  String? companyName;
  String? firstName;
  String? lastName;
  String? phone;
  Metadata? metadata;
  bool? hasAccount;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<dynamic>? addresses;

  Customer({
    this.id,
    this.email,
    this.companyName,
    this.firstName,
    this.lastName,
    this.phone,
    this.metadata,
    this.hasAccount,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.addresses,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"],
    email: json["email"],
    companyName: json["company_name"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    phone: json["phone"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    hasAccount: json["has_account"],
    deletedAt: json["deleted_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    addresses: json["addresses"] == null ? [] : List<dynamic>.from(json["addresses"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "company_name": companyName,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "metadata": metadata?.toJson(),
    "has_account": hasAccount,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "addresses": addresses == null ? [] : List<dynamic>.from(addresses!.map((x) => x)),
  };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
  );

  Map<String, dynamic> toJson() => {
  };
}
