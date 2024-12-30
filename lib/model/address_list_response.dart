
import 'dart:convert';

import 'package:waioz/model/register_response.dart';

GetAddressListResponse getAddressListFromJson(String str) => GetAddressListResponse.fromJson(json.decode(str));

String getAddressListToJson(GetAddressListResponse data) => json.encode(data.toJson());

class GetAddressListResponse {
  List<Address>? addresses;
  int? count;
  int? offset;
  int? limit;

  GetAddressListResponse({
    this.addresses,
    this.count,
    this.offset,
    this.limit,
  });

  factory GetAddressListResponse.fromJson(Map<String, dynamic> json) => GetAddressListResponse(
    addresses: json["addresses"] == null ? [] : List<Address>.from(json["addresses"]!.map((x) => Address.fromJson(x))),
    count: json["count"],
    offset: json["offset"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "addresses": addresses == null ? [] : List<dynamic>.from(addresses!.map((x) => x.toJson())),
    "count": count,
    "offset": offset,
    "limit": limit,
  };
}