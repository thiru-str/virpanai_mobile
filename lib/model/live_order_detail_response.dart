// To parse this JSON data, do
//
//     final liveOrderDetailResponse = liveOrderDetailResponseFromJson(jsonString);

import 'dart:convert';

LiveOrderDetailResponse liveOrderDetailResponseFromJson(String str) => LiveOrderDetailResponse.fromJson(json.decode(str));

String liveOrderDetailResponseToJson(LiveOrderDetailResponse data) => json.encode(data.toJson());

class LiveOrderDetailResponse {
  String? status;
  int? count;
  int? limit;
  int? offset;
  Data? data;

  LiveOrderDetailResponse({
    this.status,
    this.count,
    this.limit,
    this.offset,
    this.data,
  });

  factory LiveOrderDetailResponse.fromJson(Map<String, dynamic> json) => LiveOrderDetailResponse(
    status: json["status"],
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "count": count,
    "limit": limit,
    "offset": offset,
    "data": data?.toJson(),
  };
}

class Data {
  String? orderId;
  int? displayId;
  String? orderStatus;
  String? fulfillmentId;
  String? shopName;
  String? shopImage;
  String? shopAddress;
  String? totalPrice;
  List<Product>? products;

  Data({
    this.orderId,
    this.displayId,
    this.orderStatus,
    this.fulfillmentId,
    this.shopName,
    this.shopImage,
    this.shopAddress,
    this.totalPrice,
    this.products,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    orderId: json["order_id"],
    displayId: json["display_id"],
    orderStatus: json["order_status"],
    fulfillmentId: json["fulfillment_id"],
    shopName: json["shop_name"],
    shopImage: json["shop_image"],
    shopAddress: json["shop_address"],
    totalPrice: json["total_price"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "display_id": displayId,
    "order_status": orderStatus,
    "fulfillment_id": fulfillmentId,
    "shop_name": shopName,
    "shop_image": shopImage,
    "shop_address": shopAddress,
    "total_price": totalPrice,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}

class Product {
  String? productId;
  String? variantId;
  String? productImage;
  String? productTitle;
  String? quantity;
  String? variantTitle;
  String? total;

  Product({
    this.productId,
    this.variantId,
    this.productImage,
    this.productTitle,
    this.quantity,
    this.variantTitle,
    this.total,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json["product_id"],
    variantId: json["variant_id"],
    productImage: json["product_image"],
    productTitle: json["product_title"],
    quantity: json["quantity"],
    variantTitle: json["variant_title"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "variant_id": variantId,
    "product_image": productImage,
    "product_title": productTitle,
    "quantity": quantity,
    "variant_title": variantTitle,
    "total": total,
  };
}
