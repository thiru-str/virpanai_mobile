// To parse this JSON data, do
//
//     final dealerResponse = dealerResponseFromJson(jsonString);

import 'dart:convert';

DealerResponse dealerResponseFromJson(String str) => DealerResponse.fromJson(json.decode(str));

String dealerResponseToJson(DealerResponse data) => json.encode(data.toJson());

class DealerResponse {
  Dealer? dealer;
  List<dynamic>? dealerDocument;

  DealerResponse({
    this.dealer,
    this.dealerDocument,
  });

  factory DealerResponse.fromJson(Map<String, dynamic> json) => DealerResponse(
    dealer: json["dealer"] == null ? null : Dealer.fromJson(json["dealer"]),
    dealerDocument: json["dealer_document"] == null ? [] : List<dynamic>.from(json["dealer_document"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "dealer": dealer?.toJson(),
    "dealer_document": dealerDocument == null ? [] : List<dynamic>.from(dealerDocument!.map((x) => x)),
  };
}

class Dealer {
  String? id;
  String? name;
  String? email;
  String? phone;
  List<String>? assignedDistricts;
  String? panNumber;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? status;
  String? gstNumber;
  Metadata? metadata;
  OutstandingSummary? outstandingSummary;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Dealer({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.assignedDistricts,
    this.panNumber,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.status,
    this.gstNumber,
    this.metadata,
    this.outstandingSummary,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) => Dealer(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    assignedDistricts: json["assigned_districts"] == null ? [] : List<String>.from(json["assigned_districts"]!.map((x) => x)),
    panNumber: json["pan_number"],
    address1: json["address_1"],
    address2: json["address_2"],
    city: json["city"],
    state: json["state"],
    postalCode: json["postal_code"],
    country: json["country"],
    status: json["status"],
    gstNumber: json["gst_number"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    outstandingSummary: json["outstanding_summary"] == null ? null : OutstandingSummary.fromJson(json["outstanding_summary"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "assigned_districts": assignedDistricts == null ? [] : List<dynamic>.from(assignedDistricts!.map((x) => x)),
    "pan_number": panNumber,
    "address_1": address1,
    "address_2": address2,
    "city": city,
    "state": state,
    "postal_code": postalCode,
    "country": country,
    "status": status,
    "gst_number": gstNumber,
    "metadata": metadata?.toJson(),
    "outstanding_summary": outstandingSummary?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Metadata {
  String? countryCode;

  Metadata({
    this.countryCode,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    countryCode: json["country_code"],
  );

  Map<String, dynamic> toJson() => {
    "country_code": countryCode,
  };
}

class OutstandingSummary {
  double? billAmount;
  double? balanceAmount;
  double? receivedAmount;

  OutstandingSummary({
    this.billAmount,
    this.balanceAmount,
    this.receivedAmount,
  });

  factory OutstandingSummary.fromJson(Map<String, dynamic> json) => OutstandingSummary(
    billAmount: json["billAmount"]?.toDouble(),
    balanceAmount: json["balanceAmount"]?.toDouble(),
    receivedAmount: json["receivedAmount"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "billAmount": billAmount,
    "balanceAmount": balanceAmount,
    "receivedAmount": receivedAmount,
  };
}
