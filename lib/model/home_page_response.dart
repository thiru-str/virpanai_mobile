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

  LayoutDatum({
    this.id,
    this.image,
    this.title,
    this.subTitle,
  });

  factory LayoutDatum.fromJson(Map<String, dynamic> json) => LayoutDatum(
    id: json["id"],
    image: json["image"],
    title: json["title"],
    subTitle: json["sub_title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "title": title,
    "sub_title": subTitle,
  };
}

class Global {
  List<PaymentProvider>? paymentProvider;
  String? regionId;
  String? cartId;
  String? currencySymbol;
  num? minimumOrderValue;

  Global({
    this.paymentProvider,
    this.regionId,
    this.cartId,
    this.currencySymbol,
    this.minimumOrderValue,
  });

  factory Global.fromJson(Map<String, dynamic> json) => Global(
    paymentProvider: json["payment_providers"] == null ? [] : List<PaymentProvider>.from(json["payment_providers"]!.map((x) => PaymentProvider.fromJson(x))),
    regionId: json["region_id"],
    cartId: json["cart_id"],
    currencySymbol: json["currency_symbol"],
    minimumOrderValue: json["minimum_order_value"],

  );

  Map<String, dynamic> toJson() => {
    "payment_providers": paymentProvider == null ? [] : List<dynamic>.from(paymentProvider!.map((x) => x.toJson())),
    "region_id": regionId,
    "cart_id": cartId,
    "currency_symbol": currencySymbol,
    "minimum_order_value": minimumOrderValue,
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
