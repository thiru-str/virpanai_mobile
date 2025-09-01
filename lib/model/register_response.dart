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
  List<Address>? addresses;

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
  dynamic company;
  String? customerId;
  String? firstName;
  String? lastName;
  String? address1;
  dynamic address2;
  String? city;
  String? province;
  String? postalCode;
  String? countryCode;
  String? phone;
  Metadata? metadata;
  bool? isDefaultShipping;
  bool? isDefaultBilling;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? addressName;

  Address({
    this.id,
    this.company,
    this.customerId,
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.postalCode,
    this.countryCode,
    this.phone,
    this.metadata,
    this.isDefaultShipping,
    this.isDefaultBilling,
    this.createdAt,
    this.updatedAt,
    this.addressName,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["id"],
    company: json["company"],
    customerId: json["customer_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    address1: json["address_1"],
    address2: json["address_2"],
    city: json["city"],
    province: json["province"],
    postalCode: json["postal_code"],
    countryCode: json["country_code"],
    phone: json["phone"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    isDefaultShipping: json["is_default_shipping"],
    isDefaultBilling: json["is_default_billing"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    addressName: json["address_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "customer_id": customerId,
    "first_name": firstName,
    "last_name": lastName,
    "address_1": address1,
    "address_2": address2,
    "city": city,
    "province": province,
    "postal_code": postalCode,
    "country_code": countryCode,
    "phone": phone,
    "metadata": metadata?.toJson(),
    "is_default_shipping": isDefaultShipping,
    "is_default_billing": isDefaultBilling,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "address_name": addressName,
  };
}

class Metadata {
  bool? isGst;
  String? status;
  String? country;
  String? dealerId;
  String? deviceId;
  String? lastUsed;
  String? shopName;
  String? lastLogin;
  String? postalCode;
  String? countryCode;
  String? shopCounterImage;
  String? shopInteriorImage;
  String? shopNameBoardImage;
  String? latitude;
  String? longitude;

  Metadata({
    this.isGst,
    this.status,
    this.country,
    this.dealerId,
    this.deviceId,
    this.lastUsed,
    this.shopName,
    this.lastLogin,
    this.postalCode,
    this.countryCode,
    this.shopCounterImage,
    this.shopInteriorImage,
    this.shopNameBoardImage,
    this.latitude,
    this.longitude,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    isGst: json["is_gst"],
    status: json["status"],
    country: json["country"],
    dealerId: json["dealer_id"],
    deviceId: json["device_id"],
    lastUsed: json["last_used"],
    shopName: json["shop_name"],
    lastLogin: json["last_login"],
    postalCode: json["postal_code"],
    countryCode: json["country_code"],
    shopCounterImage: json["shop_counter_image"],
    shopInteriorImage: json["shop_interior_image"],
    shopNameBoardImage: json["shop_name_board_image"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "is_gst": isGst,
    "status": status,
    "country": country,
    "dealer_id": dealerId,
    "device_id": deviceId,
    "last_used": lastUsed,
    "shop_name": shopName,
    "last_login": lastLogin,
    "postal_code": postalCode,
    "country_code": countryCode,
    "shop_counter_image": shopCounterImage,
    "shop_interior_image": shopInteriorImage,
    "shop_name_board_image": shopNameBoardImage,
    "latitude": latitude,
    "longitude": longitude,
  };
}

