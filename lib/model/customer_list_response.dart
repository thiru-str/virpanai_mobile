// To parse this JSON data, do
//
//     final customerListResponse = customerListResponseFromJson(jsonString);

import 'dart:convert';

CustomerListResponse customerListResponseFromJson(String str) => CustomerListResponse.fromJson(json.decode(str));

String customerListResponseToJson(CustomerListResponse data) => json.encode(data.toJson());

class CustomerListResponse {
  String? status;
  List<Customer>? customers;
  int? count;
  int? limit;
  int? offset;

  CustomerListResponse({
    this.status,
    this.customers,
    this.count,
    this.limit,
    this.offset,
  });

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) => CustomerListResponse(
    status: json["status"],
    customers: json["customers"] == null ? [] : List<Customer>.from(json["customers"]!.map((x) => Customer.fromJson(x))),
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "customers": customers == null ? [] : List<dynamic>.from(customers!.map((x) => x.toJson())),
    "count": count,
    "limit": limit,
    "offset": offset,
  };
}

class Customer {
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

  Customer({
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

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
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
  String? city;
  bool? isGst;
  String? status;
  String? address;
  String? country;
  String? dealerId;
  String? shopName;
  String? postalCode;
  String? countryCode;
  String? shopGstImage;
  String? shopCounterImage;
  String? shopInteriorImage;
  String? shopNameBoardImage;

  Metadata({
    this.city,
    this.isGst,
    this.status,
    this.address,
    this.country,
    this.dealerId,
    this.shopName,
    this.postalCode,
    this.countryCode,
    this.shopGstImage,
    this.shopCounterImage,
    this.shopInteriorImage,
    this.shopNameBoardImage,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    city: json["city"],
    isGst: json["is_gst"],
    status: json["status"],
    address: json["address"],
    country: json["country"],
    dealerId: json["dealer_id"],
    shopName: json["shop_name"],
    postalCode: json["postal_code"],
    countryCode: json["country_code"],
    shopGstImage: json["shop_gst_image"],
    shopCounterImage: json["shop_counter_image"],
    shopInteriorImage: json["shop_interior_image"],
    shopNameBoardImage: json["shop_name_board_image"],
  );

  Map<String, dynamic> toJson() => {
    "city": city,
    "is_gst": isGst,
    "status": status,
    "address": address,
    "country": country,
    "dealer_id": dealerId,
    "shop_name": shopName,
    "postal_code": postalCode,
    "country_code": countryCode,
    "shop_gst_image": shopGstImage,
    "shop_counter_image": shopCounterImage,
    "shop_interior_image": shopInteriorImage,
    "shop_name_board_image": shopNameBoardImage,
  };
}
