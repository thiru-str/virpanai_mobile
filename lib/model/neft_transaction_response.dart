// To parse this JSON data, do
//
//     final neftTransactionResponse = neftTransactionResponseFromJson(jsonString);

import 'dart:convert';

NeftTransactionResponse neftTransactionResponseFromJson(String str) => NeftTransactionResponse.fromJson(json.decode(str));

String neftTransactionResponseToJson(NeftTransactionResponse data) => json.encode(data.toJson());

class NeftTransactionResponse {
  bool? success;
  List<NeftPayment>? neftPayment;

  NeftTransactionResponse({
    this.success,
    this.neftPayment,
  });

  factory NeftTransactionResponse.fromJson(Map<String, dynamic> json) => NeftTransactionResponse(
    success: json["success"],
    neftPayment: json["neft_payment"] == null ? [] : List<NeftPayment>.from(json["neft_payment"]!.map((x) => NeftPayment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "neft_payment": neftPayment == null ? [] : List<dynamic>.from(neftPayment!.map((x) => x.toJson())),
  };
}

class NeftPayment {
  String? id;
  String? orderId;
  String? image;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  NeftPayment({
    this.id,
    this.orderId,
    this.image,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory NeftPayment.fromJson(Map<String, dynamic> json) => NeftPayment(
    id: json["id"],
    orderId: json["order_id"],
    image: json["image"],
    description: json["description"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "image": image,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
