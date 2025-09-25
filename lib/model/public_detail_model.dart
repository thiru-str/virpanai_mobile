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
  StoreDetails? storeDetails;

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
    this.storeDetails,
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
    storeDetails: json["storeDetails"] == null ? null : StoreDetails.fromJson(json["storeDetails"]),
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
    "storeDetails": storeDetails?.toJson(),
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

class StoreDetails {
  StoreMetadata? storeMetadata;

  StoreDetails({
    this.storeMetadata,
  });

  factory StoreDetails.fromJson(Map<String, dynamic> json) => StoreDetails(
    storeMetadata: json["storeMetadata"] == null ? null : StoreMetadata.fromJson(json["storeMetadata"]),
  );

  Map<String, dynamic> toJson() => {
    "storeMetadata": storeMetadata?.toJson(),
  };
}

class StoreMetadata {
  String? android;
  String? versionCheck;
  String? invoiceUrl;
  String? customerSupport;

  StoreMetadata({
    this.android,
    this.versionCheck,
    this.invoiceUrl,
    this.customerSupport,
  });

  factory StoreMetadata.fromJson(Map<String, dynamic> json) => StoreMetadata(
    android: json["android"],
    versionCheck: json["version_check"],
    invoiceUrl: json["invoice_url"],
    customerSupport: json["customer_support"],
  );

  Map<String, dynamic> toJson() => {
    "android": android,
    "version_check": versionCheck,
    "invoice_url": invoiceUrl,
    "customer_support": customerSupport,
  };
}

class Theme {
  String? fontFamily;
  String? primaryColor;
  String? secondaryColor;
  String? fontColor;
  String? titleFont;
  String? contentFont;
  String? header;
  String? productView;

  Theme({
    this.fontFamily,
    this.primaryColor,
    this.secondaryColor,
    this.fontColor,
    this.titleFont,
    this.contentFont,
    this.header,
    this.productView,
  });

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
    fontFamily: json["fontFamily"],
    primaryColor: json["primaryColor"],
    secondaryColor: json["secondaryColor"],
    fontColor: json["fontColor"],
    titleFont: json["titleFont"],
    contentFont: json["contentFont"],
    header: json["header"],
    productView: json["productView"],
  );

  Map<String, dynamic> toJson() => {
    "fontFamily": fontFamily,
    "primaryColor": primaryColor,
    "secondaryColor": secondaryColor,
    "fontColor": fontColor,
    "titleFont": titleFont,
    "contentFont": contentFont,
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
