// To parse this JSON data, do
//
//     final contentResponse = contentResponseFromJson(jsonString);

import 'dart:convert';

ContentResponse contentResponseFromJson(String str) => ContentResponse.fromJson(json.decode(str));

String contentResponseToJson(ContentResponse data) => json.encode(data.toJson());

class ContentResponse {
  bool? status;
  String? message;
  Data? data;

  ContentResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ContentResponse.fromJson(Map<String, dynamic> json) => ContentResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? content;

  Data({
    this.content,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "content": content,
  };
}
