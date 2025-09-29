// To parse this JSON data, do
//
//     final resetResponse = resetResponseFromJson(jsonString);

import 'dart:convert';

ResetResponse resetResponseFromJson(String str) => ResetResponse.fromJson(json.decode(str));

String resetResponseToJson(ResetResponse data) => json.encode(data.toJson());

class ResetResponse {
  bool? status;
  String? message;

  ResetResponse({
    this.status,
    this.message,
  });

  factory ResetResponse.fromJson(Map<String, dynamic> json) => ResetResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
