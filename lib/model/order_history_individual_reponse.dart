// To parse this JSON data, do
//
//     final orderHistoryResponse = orderHistoryResponseFromJson(jsonString);

import 'dart:convert';

import 'package:waioz/model/order_history_reponse.dart';
import 'package:waioz/model/shipping_response.dart';
import 'package:waioz/ui/cart_response.dart';

// To parse this JSON data, do
//
//     final orderHistoryResponse = orderHistoryResponseFromJson(jsonString);

import 'dart:convert';

OrderHistoryIndividualReponse orderHistoryResponseFromJson(String str) => OrderHistoryIndividualReponse.fromJson(json.decode(str));

String orderHistoryResponseToJson(OrderHistoryIndividualReponse data) => json.encode(data.toJson());

class OrderHistoryIndividualReponse {
  Order? order;

  OrderHistoryIndividualReponse({
    this.order
  });

  factory OrderHistoryIndividualReponse.fromJson(Map<String, dynamic> json) => OrderHistoryIndividualReponse(
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
  );

  Map<String, dynamic> toJson() => {
    "order": order?.toJson(),
  };
}

