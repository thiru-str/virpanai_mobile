import 'dart:convert';

import 'package:waioz/model/register_response.dart';

CustomerResponse registerResponseFromJson(String str) => CustomerResponse.fromJson(json.decode(str));

String registerResponseToJson(CustomerResponse data) => json.encode(data.toJson());

class CustomerResponse {
  Customer? customer;

  CustomerResponse({
    this.customer,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) => CustomerResponse(
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "customer": customer?.toJson(),
  };
}