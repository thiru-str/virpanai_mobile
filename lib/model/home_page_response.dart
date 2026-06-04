// To parse this JSON data, do
//
//     final homePageResponse = homePageResponseFromJson(jsonString);

import 'dart:convert';

HomePageResponse homePageResponseFromJson(String str) =>
    HomePageResponse.fromJson(json.decode(str));

String homePageResponseToJson(HomePageResponse data) =>
    json.encode(data.toJson());

class HomePageResponse {
  String? status;
  List<Content>? content;
  Global? global;
  int? count;
  int? offset;
  int? limit;

  HomePageResponse({
    this.status,
    this.content,
    this.global,
    this.count,
    this.offset,
    this.limit,
  });

  factory HomePageResponse.fromJson(Map<String, dynamic> json) =>
      HomePageResponse(
        status: json["status"],
        content: json["content"] == null
            ? []
            : List<Content>.from(
                json["content"]!.map((x) => Content.fromJson(x))),
        global: json["global"] == null ? null : Global.fromJson(json["global"]),
        count: json["count"],
        offset: json["offset"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "content": content == null
            ? []
            : List<dynamic>.from(content!.map((x) => x.toJson())),
        "global": global?.toJson(),
        "count": count,
        "offset": offset,
        "limit": limit,
      };
}

class Content {
  String? layoutName;
  String? layoutTitle;
  String? layoutSubTitle;
  String? layoutBannerImage;
  String? layoutLeftCardImage;
  String? layoutRightCardImage;
  String? layoutSlideTimeInterval;
  String? layoutBgColor;
  String? layoutBgImage;
  String? layoutBgType;
  String? layoutRedirectTitle;
  String? layoutRedirect;
  String? layoutOption;
  String? layoutSearchFilter;
  //int? layoutHeight;
  List<LayoutDatum>? layoutData;
  RedirectData? redirectData;

  Content({
    this.layoutName,
    this.layoutTitle,
    this.layoutSubTitle,
    this.layoutBannerImage,
    this.layoutLeftCardImage,
    this.layoutRightCardImage,
    this.layoutSlideTimeInterval,
    this.layoutBgColor,
    this.layoutBgImage,
    this.layoutBgType,
    this.layoutRedirectTitle,
    this.layoutRedirect,
    this.layoutOption,
    this.layoutSearchFilter,
    this.layoutData,
    this.redirectData,
    //this.layoutHeight,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        layoutName: json["layout_name"],
        layoutTitle: json["layout_title"],
        layoutSubTitle: json["layout_sub_title"],
        layoutBannerImage: json["layout_banner_image"],
        layoutLeftCardImage: json["layout_left_card_image"],
        layoutRightCardImage: json["layout_right_card_image"],
        layoutSlideTimeInterval: json["layout_slide_time_interval"],
        layoutBgColor: json["layout_bg_color"],
        layoutBgImage: json["layout_bg_image"],
        layoutBgType: json["layout_bg_type"],
        layoutRedirectTitle: json["layout_redirect_title"],
        layoutRedirect: json["layout_redirect"],
        layoutOption: json["layout_option"],
        layoutSearchFilter: json["layout_search_filter"],
        layoutData: json["layout_data"] == null
            ? []
            : List<LayoutDatum>.from(
                json["layout_data"]!.map((x) => LayoutDatum.fromJson(x))),
        redirectData: json["redirect_data"] == null
            ? null
            : RedirectData.fromJson(json["redirect_data"]),
        //layoutHeight: json["layout_height"],
      );

  Map<String, dynamic> toJson() => {
        "layout_name": layoutName,
        "layout_title": layoutTitle,
        "layout_sub_title": layoutSubTitle,
        "layout_banner_image": layoutBannerImage,
        "layout_left_card_image": layoutLeftCardImage,
        "layout_right_card_image": layoutRightCardImage,
        "layout_slide_time_interval": layoutSlideTimeInterval,
        "layout_bg_color": layoutBgColor,
        "layout_bg_image": layoutBgImage,
        "layout_bg_type": layoutBgType,
        "layout_redirect_title": layoutRedirectTitle,
        "layout_redirect": layoutRedirect,
        "layout_option": layoutOption,
        "layout_search_filter": layoutSearchFilter,
        "layout_data": layoutData == null
            ? []
            : List<dynamic>.from(layoutData!.map((x) => x.toJson())),
        "redirect_data": redirectData?.toJson(),
        //"layout_height": layoutHeight,
      };
}

class LayoutDatum {
  String? id;
  String? image;
  String? title;
  String? subTitle;
  String? featureText;
  String? salesText;
  SliderProductData? productData;
  Prices? prices;
  RedirectData? redirectData;
  num? rating;
  VariantDetails? variantDetails;
  CartDetails? cartDetails;

  LayoutDatum({
    this.id,
    this.image,
    this.title,
    this.subTitle,
    this.featureText,
    this.salesText,
    this.productData,
    this.prices,
    this.redirectData,
    this.rating,
    this.variantDetails,
    this.cartDetails,
  });

  factory LayoutDatum.fromJson(Map<String, dynamic> json) => LayoutDatum(
        id: json["id"],
        image: json["image"],
        title: json["title"],
        subTitle: json["sub_title"],
        featureText: json["feature_text"],
        salesText: json["sales_text"],
        productData: json["product_data"] == null
            ? null
            : SliderProductData.fromJson(json["product_data"]),
        prices: json["prices"] == null
            ? null
            : Prices.fromJson(json["prices"]), // <-- Deserialize
        redirectData: json["redirect_data"] == null
            ? null
            : RedirectData.fromJson(json["redirect_data"]),
        rating: json["rating"],
        variantDetails: json["variant_details"] == null
            ? null
            : VariantDetails.fromJson(json["variant_details"]),
        cartDetails: json["cart_details"] == null
            ? null
            : CartDetails.fromJson(json["cart_details"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "title": title,
        "feature_text": featureText,
        "sales_text": salesText,
        "sub_title": subTitle,
        "product_data": productData?.toJson(),
        "prices": prices?.toJson(), // <-- Serialize
        "rating": rating,
        "variant_details": variantDetails?.toJson(),
        "cart_details": cartDetails?.toJson(),
        "redirect_data": redirectData?.toJson(),
      };
}

class SliderProductData {
  String? id;
  String? refId;
  String? image;
  String? title;
  String? subTitle;
  String? description;
  Prices? prices;
  VariantDetails? variantDetails;
  CartDetails? cartDetails;
  RedirectData? redirectData;

  SliderProductData({
    this.id,
    this.refId,
    this.image,
    this.title,
    this.subTitle,
    this.description,
    this.prices,
    this.variantDetails,
    this.cartDetails,
    this.redirectData,
  });

  factory SliderProductData.fromJson(Map<String, dynamic> json) =>
      SliderProductData(
        id: json["id"],
        refId: json["ref_id"],
        image: json["image"],
        title: json["title"],
        subTitle: json["sub_title"],
        description: json["description"],
        prices: json["prices"] == null ? null : Prices.fromJson(json["prices"]),
        variantDetails: json["variant_details"] == null
            ? null
            : VariantDetails.fromJson(json["variant_details"]),
        cartDetails: json["cart_details"] == null
            ? null
            : CartDetails.fromJson(json["cart_details"]),
        redirectData: json["redirect_data"] == null
            ? null
            : RedirectData.fromJson(json["redirect_data"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ref_id": refId,
        "image": image,
        "title": title,
        "sub_title": subTitle,
        "description": description,
        "prices": prices?.toJson(),
        "variant_details": variantDetails?.toJson(),
        "cart_details": cartDetails?.toJson(),
        "redirect_data": redirectData?.toJson(),
      };
}

class CartDetails {
  String? cartId;
  String? lineItemId;
  String? variantId;
  int? quantity;
  bool unitBasedInventory;
  int? unitQuantity;

  CartDetails({
    this.cartId,
    this.lineItemId,
    this.variantId,
    this.quantity,
    this.unitBasedInventory = false,
    this.unitQuantity,
  });

  factory CartDetails.fromJson(Map<String, dynamic> json) => CartDetails(
        cartId: json["cart_id"],
        lineItemId: json["line_item_id"],
        variantId: json["variant_id"],
        quantity: json["quantity"],
        unitBasedInventory: json["unit_based_inventory"] == true ||
            json["unit_based_inventory"] == "true",
        unitQuantity: _parseInt(json["unit_quantity"]),
      );

  Map<String, dynamic> toJson() => {
        "cart_id": cartId,
        "line_item_id": lineItemId,
        "variant_id": variantId,
        "quantity": quantity,
        "unit_based_inventory": unitBasedInventory,
        "unit_quantity": unitQuantity,
      };
}

class VariantDetails {
  String? variantId;
  String? variantTitle;
  String? variantSku;
  String? variantPrice;
  String? originalVariantPrice;
  bool unitBasedInventory;
  int? baseUnitGrams;
  int? defaultUnitQuantity;
  List<int> presetOptions;
  List<VariantOption>? variantOptions;

  VariantDetails({
    this.variantId,
    this.variantTitle,
    this.variantSku,
    this.variantPrice,
    this.originalVariantPrice,
    this.unitBasedInventory = false,
    this.baseUnitGrams,
    this.defaultUnitQuantity,
    this.presetOptions = const [],
    this.variantOptions,
  });

  factory VariantDetails.fromJson(Map<String, dynamic> json) => VariantDetails(
        variantId: json["variant_id"],
        variantTitle: json["variant_title"],
        variantSku: json["variant_sku"],
        variantPrice: json["variant_price"],
        originalVariantPrice: json["original_variant_price"],
        unitBasedInventory: json["unit_based_inventory"] == true ||
            json["unit_based_inventory"] == "true",
        baseUnitGrams: _parseInt(json["base_unit_grams"]),
        defaultUnitQuantity: _parseInt(json["default_unit_quantity"]),
        presetOptions: _parseIntList(json["preset_options"]),
        variantOptions: json["variant_options"] == null
            ? []
            : List<VariantOption>.from(
                json["variant_options"]!.map((x) => VariantOption.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "variant_id": variantId,
        "variant_title": variantTitle,
        "variant_sku": variantSku,
        "variant_price": variantPrice,
        "original_variant_price": originalVariantPrice,
        "unit_based_inventory": unitBasedInventory,
        "base_unit_grams": baseUnitGrams,
        "default_unit_quantity": defaultUnitQuantity,
        "preset_options": presetOptions,
        "variant_options": variantOptions == null
            ? []
            : List<dynamic>.from(variantOptions!.map((x) => x.toJson())),
      };
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return null;
  return int.tryParse(value.toString());
}

List<int> _parseIntList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map(_parseInt)
      .whereType<int>()
      .toList(growable: false);
}

class VariantOption {
  String? optionTitle;
  String? optionValue;

  VariantOption({
    this.optionTitle,
    this.optionValue,
  });

  factory VariantOption.fromJson(Map<String, dynamic> json) => VariantOption(
        optionTitle: json["option_title"],
        optionValue: json["option_value"],
      );

  Map<String, dynamic> toJson() => {
        "option_title": optionTitle,
        "option_value": optionValue,
      };
}

class Prices {
  String? sellingPrice;
  String? originalPrice;
  String? discountedPrice;
  String? discountPercentage;

  Prices({
    this.sellingPrice,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
  });

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
        sellingPrice: json["selling_price"],
        originalPrice: json["original_price"],
        discountedPrice: json["discounted_price"],
        discountPercentage: json["discount_Percentage"],
      );

  Map<String, dynamic> toJson() => {
        "selling_price": sellingPrice,
        "original_price": originalPrice,
        "discounted_price": discountedPrice,
        "discount_Percentage": discountPercentage,
      };
}

class RedirectData {
  final String? redirectType;
  final RedirectProductData? redirectProductData;
  final RedirectSearchData? redirectSearchData;
  final RedirectUrlData? redirectUrlData;
  final RedirectOrderData? redirectOrderData;
  final RedirectPageData? redirectPageData;

  RedirectData({
    this.redirectType,
    this.redirectProductData,
    this.redirectSearchData,
    this.redirectUrlData,
    this.redirectOrderData,
    this.redirectPageData,
  });

  factory RedirectData.fromJson(Map<String, dynamic> json) {
    return RedirectData(
      redirectType: json['redirect_type'],
      redirectProductData: json['redirect_product_data'] != null
          ? RedirectProductData.fromJson(json['redirect_product_data'])
          : null,
      redirectSearchData: json['redirect_search_data'] != null
          ? RedirectSearchData.fromJson(json['redirect_search_data'])
          : null,
      redirectUrlData: json['redirect_url_data'] != null
          ? RedirectUrlData.fromJson(json['redirect_url_data'])
          : null,
      redirectOrderData: json['redirect_order_data'] != null
          ? RedirectOrderData.fromJson(json['redirect_order_data'])
          : null,
      redirectPageData: json['redirect_page_data'] != null
          ? RedirectPageData.fromJson(json['redirect_page_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'redirect_type': redirectType,
        'redirect_product_data': redirectProductData?.toJson(),
        'redirect_search_data': redirectSearchData?.toJson(),
        'redirect_url_data': redirectUrlData?.toJson(),
        'redirect_page_data': redirectPageData?.toJson(),
      };
}

class RedirectProductData {
  final String? productId;
  final String? variantId;

  RedirectProductData({this.productId, this.variantId});

  factory RedirectProductData.fromJson(Map<String, dynamic> json) {
    return RedirectProductData(
      productId: json['product_id'],
      variantId: json['variant_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'variant_id': variantId,
      };
}

class RedirectOrderData {
  final String? orderId;

  RedirectOrderData({this.orderId});

  factory RedirectOrderData.fromJson(Map<String, dynamic> json) {
    return RedirectOrderData(
      orderId: json['order_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
      };
}

class RedirectPageData {
  final String? slug;

  RedirectPageData({this.slug});

  factory RedirectPageData.fromJson(Map<String, dynamic> json) {
    return RedirectPageData(
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() => {
        'slug': slug,
      };
}

class RedirectSearchData {
  final String? category;
  final String? tag;
  final String? collection;
  final String? brand;
  final String? minPrice;
  final String? maxPrice;

  RedirectSearchData({
    this.category,
    this.tag,
    this.collection,
    this.brand,
    this.minPrice,
    this.maxPrice,
  });

  factory RedirectSearchData.fromJson(Map<String, dynamic> json) {
    return RedirectSearchData(
      category: json['category'],
      tag: json['tag'],
      collection: json['collection'],
      brand: json['brand'],
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'tag': tag,
        'collection': collection,
        'brand': brand,
        'min_price': minPrice,
        'max_price': maxPrice,
      };
}

class RedirectUrlData {
  final String? url;

  RedirectUrlData({this.url});

  factory RedirectUrlData.fromJson(Map<String, dynamic> json) {
    return RedirectUrlData(
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
      };
}

class Global {
  List<PaymentProvider>? paymentProvider;
  String? regionId;
  String? cartId;
  String? currencySymbol;
  String? approximateDeliveryTime;

  Global({
    this.paymentProvider,
    this.regionId,
    this.cartId,
    this.currencySymbol,
    this.approximateDeliveryTime,
  });

  factory Global.fromJson(Map<String, dynamic> json) => Global(
        paymentProvider: json["payment_providers"] == null
            ? []
            : List<PaymentProvider>.from(json["payment_providers"]!
                .map((x) => PaymentProvider.fromJson(x))),
        regionId: json["region_id"],
        cartId: json["cart_id"],
        currencySymbol: json["currency_symbol"],
        approximateDeliveryTime:
            json["approximate_delivery_time"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "payment_providers": paymentProvider == null
            ? []
            : List<dynamic>.from(paymentProvider!.map((x) => x.toJson())),
        "region_id": regionId,
        "cart_id": cartId,
        "currency_symbol": currencySymbol,
        "approximate_delivery_time": approximateDeliveryTime,
      };
}

class PaymentProvider {
  String? id;
  bool? isEnabled;
  String? name;
  String? apiKey;

  PaymentProvider({
    this.id,
    this.isEnabled,
    this.name,
    this.apiKey,
  });

  factory PaymentProvider.fromJson(Map<String, dynamic> json) =>
      PaymentProvider(
        id: json["id"],
        isEnabled: json["is_enabled"],
        name: json["name"],
        apiKey: json["api_key"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_enabled": isEnabled,
        "name": name,
        "api_key": apiKey,
      };
}
