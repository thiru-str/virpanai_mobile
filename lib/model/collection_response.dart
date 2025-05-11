// To parse this JSON data, do
//
//     final collectionsResponse = collectionsResponseFromJson(jsonString);

import 'dart:convert';

CollectionsResponse collectionsResponseFromJson(String str) => CollectionsResponse.fromJson(json.decode(str));

String collectionsResponseToJson(CollectionsResponse data) => json.encode(data.toJson());

class CollectionsResponse {
  List<Collection>? collections;
  int? count;
  int? offset;
  int? limit;

  CollectionsResponse({
    this.collections,
    this.count,
    this.offset,
    this.limit,
  });

  factory CollectionsResponse.fromJson(Map<String, dynamic> json) => CollectionsResponse(
    collections: json["collections"] == null ? [] : List<Collection>.from(json["collections"]!.map((x) => Collection.fromJson(x))),
    count: json["count"],
    offset: json["offset"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "collections": collections == null ? [] : List<dynamic>.from(collections!.map((x) => x.toJson())),
    "count": count,
    "offset": offset,
    "limit": limit,
  };
}

class Collection {
  String? id;
  String? title;
  String? handle;
  DateTime? createdAt;
  DateTime? updatedAt;

  Collection({
    this.id,
    this.title,
    this.handle,
    this.createdAt,
    this.updatedAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    id: json["id"],
    title: json["title"],
    handle: json["handle"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "handle": handle,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
