import 'dart:convert';

import 'package:waioz/ui/cart_response.dart';

ProductInfoResponse productInfoResponseFromJson(String str) =>
    ProductInfoResponse.fromJson(json.decode(str));

String productInfoResponseToJson(ProductInfoResponse data) =>
    json.encode(data.toJson());

class ProductInfoResponse {
  Cart? cart;
  bool? productOnWishlist;
  String? productWishlistId;
  int? addOnProductCount;
  int? relatedProductCount;
  int? crossSellingProductCount;
  int? upSellingProductCount;
  List<ProductVideo>? productVideo;
  String? warrantyInformation;
  String? deliveryAndShipping;
  PdWhatsappSettings? pdWhatsappSettings;
  bool? rzpIsEnabled;

  ProductInfoResponse({
    this.cart,
    this.productOnWishlist,
    this.productWishlistId,
    this.addOnProductCount,
    this.relatedProductCount,
    this.crossSellingProductCount,
    this.upSellingProductCount,
    this.productVideo,
    this.warrantyInformation,
    this.deliveryAndShipping,
    this.pdWhatsappSettings,
    this.rzpIsEnabled,
  });

  factory ProductInfoResponse.fromJson(Map<String, dynamic> json) =>
      ProductInfoResponse(
        cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
        productOnWishlist: json["product_on_wishlist"],
        productWishlistId: json["product_wishlist_id"],
        addOnProductCount: json["addon_product_count"],
        relatedProductCount: json["related_product_count"],
        crossSellingProductCount: json["cross_selling_product_count"],
        upSellingProductCount: json["up_selling_product_count"],
        productVideo: json["product_video"] == null
            ? []
            : List<ProductVideo>.from(
                json["product_video"]!.map((x) => ProductVideo.fromJson(x))),
        warrantyInformation: json["warranty_information"],
        deliveryAndShipping: json["delivery_and_shipping"],
        pdWhatsappSettings: json["pd_whatsapp_settings"] == null
            ? null
            : PdWhatsappSettings.fromJson(json["pd_whatsapp_settings"]),
        rzpIsEnabled: json["rzp_isEnabled"],
      );

  Map<String, dynamic> toJson() => {
        "cart": cart?.toJson(),
        "product_on_wishlist": productOnWishlist,
        "product_wishlist_id": productWishlistId,
        "addon_product_count": addOnProductCount,
        "related_product_count": relatedProductCount,
        "cross_selling_product_count": crossSellingProductCount,
        "up_selling_product_count": upSellingProductCount,
        "product_video": productVideo == null
            ? []
            : List<dynamic>.from(productVideo!.map((x) => x.toJson())),
        "warranty_information": warrantyInformation,
        "delivery_and_shipping": deliveryAndShipping,
        "pd_whatsapp_settings": pdWhatsappSettings?.toJson(),
        "rzp_isEnabled": rzpIsEnabled,
      };
}

class PdWhatsappSettings {
  bool? isEnabled;
  String? themeColor;
  String? whatsappNumber;
  String? defaultMessage;

  PdWhatsappSettings({
    this.isEnabled,
    this.themeColor,
    this.whatsappNumber,
    this.defaultMessage,
  });

  factory PdWhatsappSettings.fromJson(Map<String, dynamic> json) =>
      PdWhatsappSettings(
        isEnabled: json["isEnabled"],
        themeColor: json["themeColor"],
        whatsappNumber: json["whatsappNumber"],
        defaultMessage: json["defaultMessage"],
      );

  Map<String, dynamic> toJson() => {
        "isEnabled": isEnabled,
        "themeColor": themeColor,
        "whatsappNumber": whatsappNumber,
        "defaultMessage": defaultMessage,
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
