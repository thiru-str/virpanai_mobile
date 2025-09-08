// To parse this JSON data, do
//
//     final customerMetaDataResponse = customerMetaDataResponseFromJson(jsonString);

import 'dart:convert';

CustomerMetaDataResponse customerMetaDataResponseFromJson(String str) => CustomerMetaDataResponse.fromJson(json.decode(str));

String customerMetaDataResponseToJson(CustomerMetaDataResponse data) => json.encode(data.toJson());

class CustomerMetaDataResponse {
  bool? status;
  String? cartId;
  Metadata? metadata;

  CustomerMetaDataResponse({
    this.status,
    this.cartId,
    this.metadata,
  });

  factory CustomerMetaDataResponse.fromJson(Map<String, dynamic> json) => CustomerMetaDataResponse(
    status: json["status"],
    cartId: json["cart_id"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "cart_id": cartId,
    "metadata": metadata?.toJson(),
  };
}

class Metadata {
  String? customerDetails;

  Metadata({
    this.customerDetails,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    customerDetails: json["customer_details"],
  );

  Map<String, dynamic> toJson() => {
    "customer_details": customerDetails,
  };
}
