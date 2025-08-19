// To parse this JSON data, do
//
//     final placeOrderResponse = placeOrderResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/order_history_reponse.dart';

PlaceOrderResponse placeOrderResponseFromJson(String str) => PlaceOrderResponse.fromJson(json.decode(str));

String placeOrderResponseToJson(PlaceOrderResponse data) => json.encode(data.toJson());

class PlaceOrderResponse {
  String? type;
  Order? order;

  PlaceOrderResponse({
    this.type,
    this.order,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) => PlaceOrderResponse(
    type: json["type"],
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "order": order?.toJson(),
  };
}


