// To parse this JSON data, do
//
//     final paymentMethodResponse = paymentMethodResponseFromJson(jsonString);

import 'dart:convert';

import '../ui/cart_response.dart';

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
  num? amount;
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


class Context {
  Context();

  factory Context.fromJson(Map<String, dynamic> json) => Context(
  );

  Map<String, dynamic> toJson() => {
  };
}

class RawAmount {
  String? value;
  num? precision;

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
