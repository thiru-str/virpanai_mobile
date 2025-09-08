// To parse this JSON data, do
//
//     final dashboardResponse = dashboardResponseFromJson(jsonString);

import 'dart:convert';

DashboardResponse dashboardResponseFromJson(String str) => DashboardResponse.fromJson(json.decode(str));

String dashboardResponseToJson(DashboardResponse data) => json.encode(data.toJson());

class DashboardResponse {
  String? totalRevenue;
  num? rawTotalRevenue;
  int? totalOrders;
  int? deliveredOrders;
  int? pendingOrders;
  int? totalProducts;
  List<GraphDatum>? graphData;

  DashboardResponse({
    this.totalRevenue,
    this.rawTotalRevenue,
    this.totalOrders,
    this.deliveredOrders,
    this.pendingOrders,
    this.totalProducts,
    this.graphData,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) => DashboardResponse(
    totalRevenue: json["total_revenue"],
    rawTotalRevenue: json["raw_total_revenue"],
    totalOrders: json["total_orders"],
    deliveredOrders: json["delivered_orders"],
    pendingOrders: json["pending_orders"],
    totalProducts: json["total_products"],
    graphData: json["graph_data"] == null ? [] : List<GraphDatum>.from(json["graph_data"]!.map((x) => GraphDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total_revenue": totalRevenue,
    "raw_total_revenue": rawTotalRevenue,
    "total_orders": totalOrders,
    "delivered_orders": deliveredOrders,
    "pending_orders": pendingOrders,
    "total_products": totalProducts,
    "graph_data": graphData == null ? [] : List<dynamic>.from(graphData!.map((x) => x.toJson())),
  };
}

class GraphDatum {
  String? title;
  int? value;
  String? label;

  GraphDatum({
    this.title,
    this.value,
    this.label,
  });

  factory GraphDatum.fromJson(Map<String, dynamic> json) => GraphDatum(
    title: json["title"],
    value: json["value"],
    label: json["label"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "value": value,
    "label": label,
  };
}
