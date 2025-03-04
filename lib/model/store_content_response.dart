// To parse this JSON data, do
//
//     final storeContentResponse = storeContentResponseFromJson(jsonString);

import 'dart:convert';

StoreContentResponse storeContentResponseFromJson(String str) => StoreContentResponse.fromJson(json.decode(str));

String storeContentResponseToJson(StoreContentResponse data) => json.encode(data.toJson());

class StoreContentResponse {
  String? status;
  List<ContentData>? data;

  StoreContentResponse({
    this.status,
    this.data,
  });

  factory StoreContentResponse.fromJson(Map<String, dynamic> json) => StoreContentResponse(
    status: json["status"],
    data: json["data"] == null ? [] : List<ContentData>.from(json["data"]!.map((x) => ContentData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ContentData {
  String? name;
  Content? content;

  ContentData({
    this.name,
    this.content,
  });

  factory ContentData.fromJson(Map<String, dynamic> json) => ContentData(
    name: json["name"],
    content: json["content"] == null ? null : Content.fromJson(json["content"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "content": content?.toJson(),
  };
}

class Content {
  String? id;
  String? name;
  String? slug;
  String? handle;
  String? data;

  Content({
    this.id,
    this.name,
    this.slug,
    this.handle,
    this.data,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    handle: json["handle"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "handle": handle,
    "data": data,
  };
}
