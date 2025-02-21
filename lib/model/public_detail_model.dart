// To parse this JSON data, do
//
//     final publicDetailsResponse = publicDetailsResponseFromJson(jsonString);

import 'dart:convert';

PublicDetailsResponse publicDetailsResponseFromJson(String str) => PublicDetailsResponse.fromJson(json.decode(str));

String publicDetailsResponseToJson(PublicDetailsResponse data) => json.encode(data.toJson());

class PublicDetailsResponse {
  bool? maintainance;
  String? token;
  Theme? theme;
  bool? googleMapUsage;
  bool? showLocationAtStart;
  bool? restrictLocation;
  bool? singleShippingAddress;
  String? restrictLocationBy;
  BankDetails? bankDetails;
  UpiDetails? upiDetails;

  PublicDetailsResponse({
    this.maintainance,
    this.token,
    this.theme,
    this.googleMapUsage,
    this.showLocationAtStart,
    this.restrictLocation,
    this.singleShippingAddress,
    this.restrictLocationBy,
    this.bankDetails,
    this.upiDetails,
  });

  factory PublicDetailsResponse.fromJson(Map<String, dynamic> json) => PublicDetailsResponse(
    maintainance: json["maintainance"],
    token: json["token"],
    theme: json["theme"] == null ? null : Theme.fromJson(json["theme"]),
    googleMapUsage: json["googleMapUsage"],
    showLocationAtStart: json["showLocationAtStart"],
    restrictLocation: json["restrictLocation"],
    singleShippingAddress: json["singleShippingAddress"],
    restrictLocationBy: json["restrictLocationBy"],
    bankDetails: json["bankDetails"] == null ? null : BankDetails.fromJson(json["bankDetails"]),
    upiDetails: json["upiDetails"] == null ? null : UpiDetails.fromJson(json["upiDetails"]),
  );

  Map<String, dynamic> toJson() => {
    "maintainance": maintainance,
    "token": token,
    "theme": theme?.toJson(),
    "googleMapUsage": googleMapUsage,
    "showLocationAtStart": showLocationAtStart,
    "restrictLocation": restrictLocation,
    "singleShippingAddress": singleShippingAddress,
    "restrictLocationBy": restrictLocationBy,
    "bankDetails": bankDetails?.toJson(),
    "upiDetails": upiDetails?.toJson(),
  };
}

class BankDetails {
  String? bankName;
  String? branchName;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? bankNotes;

  BankDetails({
    this.bankName,
    this.branchName,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.bankNotes,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    bankName: json["bankName"],
    branchName: json["branchName"],
    accountHolderName: json["accountHolderName"],
    accountNumber: json["accountNumber"],
    ifscCode: json["ifscCode"],
    bankNotes: json["bankNotes"],
  );

  Map<String, dynamic> toJson() => {
    "bankName": bankName,
    "branchName": branchName,
    "accountHolderName": accountHolderName,
    "accountNumber": accountNumber,
    "ifscCode": ifscCode,
    "bankNotes": bankNotes,
  };
}

class Theme {
  String? fontFamily;
  String? primaryColor;
  String? secondaryColor;
  String? header;
  String? productView;

  Theme({
    this.fontFamily,
    this.primaryColor,
    this.secondaryColor,
    this.header,
    this.productView,
  });

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
    fontFamily: json["fontFamily"],
    primaryColor: json["primaryColor"],
    secondaryColor: json["secondaryColor"],
    header: json["header"],
    productView: json["productView"],
  );

  Map<String, dynamic> toJson() => {
    "fontFamily": fontFamily,
    "primaryColor": primaryColor,
    "secondaryColor": secondaryColor,
    "header": header,
    "productView": productView,
  };
}

class UpiDetails {
  String? upiId;
  String? qrCode;
  String? upiNotes;

  UpiDetails({
    this.upiId,
    this.qrCode,
    this.upiNotes,
  });

  factory UpiDetails.fromJson(Map<String, dynamic> json) => UpiDetails(
    upiId: json["upiId"],
    qrCode: json["qrCode"],
    upiNotes: json["upiNotes"],
  );

  Map<String, dynamic> toJson() => {
    "upiId": upiId,
    "qrCode": qrCode,
    "upiNotes": upiNotes,
  };
}
