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


