// To parse this JSON data, do
//
//     final liveOrderDetailResponse = liveOrderDetailResponseFromJson(jsonString);

import 'dart:convert';

LiveOrderDetailResponse liveOrderDetailResponseFromJson(String str) =>
    LiveOrderDetailResponse.fromJson(json.decode(str));

String liveOrderDetailResponseToJson(LiveOrderDetailResponse data) =>
    json.encode(data.toJson());

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

  factory LiveOrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      LiveOrderDetailResponse(
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
  String? paymentMethod;
  String? totalPrice;
  OrderSummary? orderSummary;
  String? phone;
  String? date;
  List<Product>? products;

  Data({
    this.orderId,
    this.displayId,
    this.orderStatus,
    this.fulfillmentId,
    this.shopName,
    this.shopImage,
    this.shopAddress,
    this.paymentMethod,
    this.totalPrice,
    this.orderSummary,
    this.phone,
    this.date,
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
        orderSummary: json["order_summary"] == null
            ? null
            : OrderSummary.fromJson(json["order_summary"]),
        paymentMethod: json["payment_method"],
        phone: json["phone"],
        date: json["date"],
        products: json["products"] == null
            ? []
            : List<Product>.from(
                json["products"]!.map((x) => Product.fromJson(x))),
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
        "order_summary": orderSummary?.toJson(),
        "payment_method": paymentMethod,
        "phone": phone,
        "date": date,
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
      };
}

class OrderSummary {
  String? itemTotal;
  num? rawItemTotal;
  String? shippingTotal;
  num? rawShippingTotal;
  String? taxTotal;
  num? rawTaxTotal;
  String? walletAmount;
  num? rawWalletAmount;
  String? loyaltyAmount;
  num? rawLoyaltyAmount;
  String? discountAmount;
  num? rawDiscountAmount;
  String? platformFee;
  num? rawPlatformFee;
  String? finalTotal;
  num? rawFinalTotal;

  OrderSummary({
    this.itemTotal,
    this.rawItemTotal,
    this.shippingTotal,
    this.rawShippingTotal,
    this.taxTotal,
    this.rawTaxTotal,
    this.walletAmount,
    this.rawWalletAmount,
    this.loyaltyAmount,
    this.rawLoyaltyAmount,
    this.discountAmount,
    this.rawDiscountAmount,
    this.platformFee,
    this.rawPlatformFee,
    this.finalTotal,
    this.rawFinalTotal,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
        itemTotal: json["item_total"],
        rawItemTotal: json["raw_item_total"],
        shippingTotal: json["shipping_total"],
        rawShippingTotal: json["raw_shipping_total"],
        taxTotal: json["tax_total"],
        rawTaxTotal: json["raw_tax_total"],
        walletAmount: json["wallet_amount"],
        rawWalletAmount: json["raw_wallet_amount"],
        loyaltyAmount: json["loyalty_amount"],
        rawLoyaltyAmount: json["raw_loyalty_amount"],
        discountAmount: json["discount_amount"],
        rawDiscountAmount: json["raw_discount_amount"],
        platformFee: json["platform_fee"],
        rawPlatformFee: json["raw_platform_fee"],
        finalTotal: json["final_total"],
        rawFinalTotal: json["raw_final_total"],
      );

  Map<String, dynamic> toJson() => {
        "item_total": itemTotal,
        "raw_item_total": rawItemTotal,
        "shipping_total": shippingTotal,
        "raw_shipping_total": rawShippingTotal,
        "tax_total": taxTotal,
        "raw_tax_total": rawTaxTotal,
        "wallet_amount": walletAmount,
        "raw_wallet_amount": rawWalletAmount,
        "loyalty_amount": loyaltyAmount,
        "raw_loyalty_amount": rawLoyaltyAmount,
        "discount_amount": discountAmount,
        "raw_discount_amount": rawDiscountAmount,
        "platform_fee": platformFee,
        "raw_platform_fee": rawPlatformFee,
        "final_total": finalTotal,
        "raw_final_total": rawFinalTotal,
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
