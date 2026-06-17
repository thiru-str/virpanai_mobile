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
    addresses: json["addresses"] == null ? [] : List<Address>.from(json["addresses"]!.map((x) => Address.fromJson(x))),
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
    "addresses": addresses == null ? [] : List<dynamic>.from(addresses!.map((x) => x.toJson())),
  };
}

class Address {
  String? id;
  String? addressName;
  bool? isDefaultShipping;
  bool? isDefaultBilling;
  dynamic company;
  dynamic firstName;
  dynamic lastName;
  String? address1;
  String? address2;
  String? city;
  String? countryCode;
  String? province;
  String? postalCode;
  String? phone;
  Metadata? metadata;
  String? customerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Address({
    this.id,
    this.addressName,
    this.isDefaultShipping,
    this.isDefaultBilling,
    this.company,
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.countryCode,
    this.province,
    this.postalCode,
    this.phone,
    this.metadata,
    this.customerId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["id"],
    addressName: json["address_name"],
    isDefaultShipping: json["is_default_shipping"],
    isDefaultBilling: json["is_default_billing"],
    company: json["company"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    address1: json["address_1"],
    address2: json["address_2"],
    city: json["city"],
    countryCode: json["country_code"],
    province: json["province"],
    postalCode: json["postal_code"],
    phone: json["phone"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    customerId: json["customer_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "address_name": addressName,
    "is_default_shipping": isDefaultShipping,
    "is_default_billing": isDefaultBilling,
    "company": company,
    "first_name": firstName,
    "last_name": lastName,
    "address_1": address1,
    "address_2": address2,
    "city": city,
    "country_code": countryCode,
    "province": province,
    "postal_code": postalCode,
    "phone": phone,
    "metadata": metadata?.toJson(),
    "customer_id": customerId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Metadata {
  String? shopName;
  String? latitude;
  String? longitude;

  Metadata({
    this.shopName,
    this.latitude,
    this.longitude,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    shopName: json["shop_name"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "shop_name": shopName,
    "latitude": latitude,
    "longitude": longitude,
  };
}
