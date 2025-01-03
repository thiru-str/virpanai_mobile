// To parse this JSON data, do
//
//     final deleteResponse = deleteResponseFromJson(jsonString);

import 'dart:convert';

DeleteResponse deleteResponseFromJson(String str) => DeleteResponse.fromJson(json.decode(str));

String deleteResponseToJson(DeleteResponse data) => json.encode(data.toJson());

class DeleteResponse {
  String? id;
  String? object;
  bool? deleted;
  Parent? parent;

  DeleteResponse({
    this.id,
    this.object,
    this.deleted,
    this.parent,
  });

  factory DeleteResponse.fromJson(Map<String, dynamic> json) => DeleteResponse(
    id: json["id"],
    object: json["object"],
    deleted: json["deleted"],
    parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "object": object,
    "deleted": deleted,
    "parent": parent?.toJson(),
  };
}

class Parent {
  String? id;

  Parent({
    this.id,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}
