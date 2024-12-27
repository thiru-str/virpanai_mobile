// To parse this JSON data, do
//
//     final homePageResponse = homePageResponseFromJson(jsonString);

import 'dart:convert';

HomePageResponse homePageResponseFromJson(String str) => HomePageResponse.fromJson(json.decode(str));

String homePageResponseToJson(HomePageResponse data) => json.encode(data.toJson());

class HomePageResponse {
  String? status;
  Data? data;

  HomePageResponse({
    this.status,
    this.data,
  });

  factory HomePageResponse.fromJson(Map<String, dynamic> json) => HomePageResponse(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
  List<Content>? content;

  Data({
    this.content,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    content: json["content"] == null ? [] : List<Content>.from(json["content"]!.map((x) => Content.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "content": content == null ? [] : List<dynamic>.from(content!.map((x) => x.toJson())),
  };
}

class Content {
  String? layoutName;
  String? layoutTitle;
  String? layoutRedirect;
  String? layoutOption;
  String? layoutSearchFilter;
  List<LayoutDatum>? layoutData;

  Content({
    this.layoutName,
    this.layoutTitle,
    this.layoutRedirect,
    this.layoutOption,
    this.layoutSearchFilter,
    this.layoutData,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    layoutName: json["layout_name"],
    layoutTitle: json["layout_title"],
    layoutRedirect: json["layout_redirect"],
    layoutOption: json["layout_option"],
    layoutSearchFilter: json["layout_search_filter"],
    layoutData: json["layout_data"] == null ? [] : List<LayoutDatum>.from(json["layout_data"]!.map((x) => LayoutDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "layout_name": layoutName,
    "layout_title": layoutTitle,
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
