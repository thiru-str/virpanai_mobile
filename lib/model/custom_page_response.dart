// To parse this JSON data, do
//
//     final customPageResponse = customPageResponseFromJson(jsonString);

import 'dart:convert';

import 'home_page_response.dart';

CustomPageResponse customPageResponseFromJson(String str) => CustomPageResponse.fromJson(json.decode(str));

String customPageResponseToJson(CustomPageResponse data) => json.encode(data.toJson());

class CustomPageResponse {
  String? status;
  List<Content>? content;

  CustomPageResponse({
    this.status,
    this.content,
  });

  factory CustomPageResponse.fromJson(Map<String, dynamic> json) => CustomPageResponse(
    status: json["status"],
    content: json["content"] == null ? [] : List<Content>.from(json["content"]!.map((x) => Content.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "content": content == null ? [] : List<dynamic>.from(content!.map((x) => x.toJson())),
  };
}
