import 'dart:convert';

import 'package:waioz/ui/cart_response.dart';

ProductInfoResponse productInfoResponseFromJson(String str) =>
    ProductInfoResponse.fromJson(json.decode(str));

String productInfoResponseToJson(ProductInfoResponse data) =>
    json.encode(data.toJson());

class ProductInfoResponse {
  Cart? cart;
  int? addOnProductCount;
  int? relatedProductCount;
  int? crossSellingProductCount;
  int? upSellingProductCount;
  List<ProductVideo>? productVideo;

  ProductInfoResponse({
    this.cart,
    this.addOnProductCount,
    this.relatedProductCount,
    this.crossSellingProductCount,
    this.upSellingProductCount,
    this.productVideo,
  });

  factory ProductInfoResponse.fromJson(Map<String, dynamic> json) =>
      ProductInfoResponse(
        cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
        addOnProductCount: json["addon_product_count"],
        relatedProductCount: json["related_product_count"],
        crossSellingProductCount: json["cross_selling_product_count"],
        upSellingProductCount: json["up_selling_product_count"],
        productVideo: json["product_video"] == null
            ? []
            : List<ProductVideo>.from(
                json["product_video"]!.map((x) => ProductVideo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cart": cart?.toJson(),
        "addon_product_count": addOnProductCount,
        "related_product_count": relatedProductCount,
        "cross_selling_product_count": crossSellingProductCount,
        "up_selling_product_count": upSellingProductCount,
        "product_video": productVideo == null
            ? []
            : List<dynamic>.from(productVideo!.map((x) => x.toJson())),
      };
}

class ProductVideo {
  String? id;
  String? productId;
  dynamic rank;
  String? url;
  dynamic metadata;

  ProductVideo({
    this.id,
    this.productId,
    this.rank,
    this.url,
    this.metadata,
  });

  factory ProductVideo.fromJson(Map<String, dynamic> json) => ProductVideo(
        id: json["id"],
        productId: json["product_id"],
        rank: json["rank"],
        url: json["url"],
        metadata: json["metadata"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "rank": rank,
        "url": url,
        "metadata": metadata,
      };
}
