// To parse this JSON data, do
//
//     final duplicateResponse = duplicateResponseFromJson(jsonString);

import 'dart:convert';

DuplicateResponse duplicateResponseFromJson(String str) => DuplicateResponse.fromJson(json.decode(str));

String duplicateResponseToJson(DuplicateResponse data) => json.encode(data.toJson());

class DuplicateResponse {
  bool? status;
  Error? error;

  DuplicateResponse({
    this.status,
    this.error,
  });

  factory DuplicateResponse.fromJson(Map<String, dynamic> json) => DuplicateResponse(
    status: json["status"],
    error: json["error"] == null ? null : Error.fromJson(json["error"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error?.toJson(),
  };
}

class Error {
  String? message;

  Error({
    this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
