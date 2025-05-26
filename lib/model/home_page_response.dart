// To parse this JSON data, do
//
//     final homePageResponse = homePageResponseFromJson(jsonString);

import 'dart:convert';

HomePageResponse homePageResponseFromJson(String str) => HomePageResponse.fromJson(json.decode(str));

String homePageResponseToJson(HomePageResponse data) => json.encode(data.toJson());

class HomePageResponse {
  String? status;
  List<Content>? content;
  Global? global;

  HomePageResponse({
    this.status,
    this.content,
    this.global,
  });

  factory HomePageResponse.fromJson(Map<String, dynamic> json) => HomePageResponse(
    status: json["status"],
    content: json["content"] == null ? [] : List<Content>.from(json["content"]!.map((x) => Content.fromJson(x))),
    global: json["global"] == null ? null : Global.fromJson(json["global"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "content": content == null ? [] : List<dynamic>.from(content!.map((x) => x.toJson())),
    "global": global?.toJson(),
  };
}

class Content {
  String? layoutName;
  String? layoutTitle;
  String? layoutRedirectTitle;
  String? layoutRedirect;
  String? layoutOption;
  String? layoutSearchFilter;
  List<LayoutDatum>? layoutData;

  Content({
    this.layoutName,
    this.layoutTitle,
    this.layoutRedirectTitle,
    this.layoutRedirect,
    this.layoutOption,
    this.layoutSearchFilter,
    this.layoutData,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    layoutName: json["layout_name"],
    layoutTitle: json["layout_title"],
    layoutRedirectTitle: json["layout_redirect_title"],
    layoutRedirect: json["layout_redirect"],
    layoutOption: json["layout_option"],
    layoutSearchFilter: json["layout_search_filter"],
    layoutData: json["layout_data"] == null ? [] : List<LayoutDatum>.from(json["layout_data"]!.map((x) => LayoutDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "layout_name": layoutName,
    "layout_title": layoutTitle,
    "layout_redirect_title": layoutRedirectTitle,
    "layout_redirect": layoutRedirect,
    "layout_option": layoutOption,
    "layout_search_filter": layoutSearchFilter,
    "layout_data": layoutData == null ? [] : List<dynamic>.from(layoutData!.map((x) => x.toJson())),
  };
}

class LayoutDatum {
  String? id;
  String? image;
  String? title;
  String? subTitle;
  Prices? prices;
  RedirectData? redirectData;

  LayoutDatum({
    this.id,
    this.image,
    this.title,
    this.subTitle,
    this.prices,
    this.redirectData,
  });

  factory LayoutDatum.fromJson(Map<String, dynamic> json) => LayoutDatum(
    id: json["id"],
    image: json["image"],
    title: json["title"],
    subTitle: json["sub_title"],
    prices: json["prices"] == null ? null : Prices.fromJson(json["prices"]), // <-- Deserialize
    redirectData: json["redirect_data"] == null ? null : RedirectData.fromJson(json["redirect_data"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "title": title,
    "sub_title": subTitle,
    "prices": prices?.toJson(), // <-- Serialize
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

  RedirectData({
    this.redirectType,
    this.redirectProductData,
    this.redirectSearchData,
    this.redirectUrlData,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'redirect_type': redirectType,
    'redirect_product_data': redirectProductData?.toJson(),
    'redirect_search_data': redirectSearchData?.toJson(),
    'redirect_url_data': redirectUrlData?.toJson(),
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

class RedirectSearchData {
  final String? category;
  final String? brand;
  final String? minPrice;
  final String? maxPrice;

  RedirectSearchData({
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
  });

  factory RedirectSearchData.fromJson(Map<String, dynamic> json) {
    return RedirectSearchData(
      category: json['category'],
      brand: json['brand'],
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
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

  Global({
    this.paymentProvider,
    this.regionId,
    this.cartId,
    this.currencySymbol,
  });

  factory Global.fromJson(Map<String, dynamic> json) => Global(
    paymentProvider: json["payment_providers"] == null ? [] : List<PaymentProvider>.from(json["payment_providers"]!.map((x) => PaymentProvider.fromJson(x))),
    regionId: json["region_id"],
    cartId: json["cart_id"],
    currencySymbol: json["currency_symbol"],
  );

  Map<String, dynamic> toJson() => {
    "payment_providers": paymentProvider == null ? [] : List<dynamic>.from(paymentProvider!.map((x) => x.toJson())),
    "region_id": regionId,
    "cart_id": cartId,
    "currency_symbol": currencySymbol,
  };
}

class PaymentProvider {
  String? id;
  bool? isEnabled;
  String? name;

  PaymentProvider({
    this.id,
    this.isEnabled,
    this.name,
  });

  factory PaymentProvider.fromJson(Map<String, dynamic> json) => PaymentProvider(
    id: json["id"],
    isEnabled: json["is_enabled"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_enabled": isEnabled,
    "name": name,
  };
}
