// To parse this JSON data, do
//
//     final paymentMethodResponse = paymentMethodResponseFromJson(jsonString);

import 'dart:convert';

PaymentMethodResponse paymentMethodResponseFromJson(String str) => PaymentMethodResponse.fromJson(json.decode(str));

String paymentMethodResponseToJson(PaymentMethodResponse data) => json.encode(data.toJson());

class PaymentMethodResponse {
  PaymentCollection? paymentCollection;

  PaymentMethodResponse({
    this.paymentCollection,
  });

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) => PaymentMethodResponse(
    paymentCollection: json["payment_collection"] == null ? null : PaymentCollection.fromJson(json["payment_collection"]),
  );

  Map<String, dynamic> toJson() => {
    "payment_collection": paymentCollection?.toJson(),
  };
}

class PaymentCollection {
  String? id;
  String? currencyCode;
  int? amount;
  List<PaymentSession>? paymentSessions;

  PaymentCollection({
    this.id,
    this.currencyCode,
    this.amount,
    this.paymentSessions,
  });

  factory PaymentCollection.fromJson(Map<String, dynamic> json) => PaymentCollection(
    id: json["id"],
    currencyCode: json["currency_code"],
    amount: json["amount"],
    paymentSessions: json["payment_sessions"] == null ? [] : List<PaymentSession>.from(json["payment_sessions"]!.map((x) => PaymentSession.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "amount": amount,
    "payment_sessions": paymentSessions == null ? [] : List<dynamic>.from(paymentSessions!.map((x) => x.toJson())),
  };
}

class PaymentSession {
  String? id;
  String? currencyCode;
  String? providerId;
  Context? data;
  Context? context;
  String? status;
  dynamic authorizedAt;
  String? paymentCollectionId;
  Context? metadata;
  RawAmount? rawAmount;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? amount;

  PaymentSession({
    this.id,
    this.currencyCode,
    this.providerId,
    this.data,
    this.context,
    this.status,
    this.authorizedAt,
    this.paymentCollectionId,
    this.metadata,
    this.rawAmount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.amount,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> json) => PaymentSession(
    id: json["id"],
    currencyCode: json["currency_code"],
    providerId: json["provider_id"],
    data: json["data"] == null ? null : Context.fromJson(json["data"]),
    context: json["context"] == null ? null : Context.fromJson(json["context"]),
    status: json["status"],
    authorizedAt: json["authorized_at"],
    paymentCollectionId: json["payment_collection_id"],
    metadata: json["metadata"] == null ? null : Context.fromJson(json["metadata"]),
    rawAmount: json["raw_amount"] == null ? null : RawAmount.fromJson(json["raw_amount"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "provider_id": providerId,
    "data": data?.toJson(),
    "context": context?.toJson(),
    "status": status,
    "authorized_at": authorizedAt,
    "payment_collection_id": paymentCollectionId,
    "metadata": metadata?.toJson(),
    "raw_amount": rawAmount?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "amount": amount,
  };
}

class Context {
  Context();

  factory Context.fromJson(Map<String, dynamic> json) => Context(
  );

  Map<String, dynamic> toJson() => {
  };
}

class RawAmount {
  String? value;
  int? precision;

  RawAmount({
    this.value,
    this.precision,
  });

  factory RawAmount.fromJson(Map<String, dynamic> json) => RawAmount(
    value: json["value"],
    precision: json["precision"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "precision": precision,
  };
}
