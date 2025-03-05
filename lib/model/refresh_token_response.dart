// To parse this JSON data, do
//
//     final refreshTokenResponse = refreshTokenResponseFromJson(jsonString);

import 'dart:convert';

RefreshTokenResponse refreshTokenResponseFromJson(String str) => RefreshTokenResponse.fromJson(json.decode(str));

String refreshTokenResponseToJson(RefreshTokenResponse data) => json.encode(data.toJson());

class RefreshTokenResponse {
  String? token;

  RefreshTokenResponse({
    this.token,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) => RefreshTokenResponse(
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
  };
}
