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
  List<String> enabledExtensions;

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
    this.enabledExtensions = const [],
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
      enabledExtensions: json["enabled_extensions"] != null
          ? List<String>.from(json["enabled_extensions"])
          : [],
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
    "enabled_extensions": enabledExtensions,
  };

  bool hasExtension(String slug) => enabledExtensions.contains(slug);
}

class StoreDetails {
  StoreMetadata? storeMetadata;
  String? loginType;

  StoreDetails({
    this.storeMetadata,
    this.loginType,
  });

  factory StoreDetails.fromJson(Map<String, dynamic> json) => StoreDetails(
    storeMetadata: json["storeMetadata"] == null ? null : StoreMetadata.fromJson(json["storeMetadata"]),
    loginType: json["loginType"],
  );

  Map<String, dynamic> toJson() => {
    "storeMetadata": storeMetadata?.toJson(),
    "loginType": loginType,
  };
}

class StoreMetadata {
  bool? skipLogin;
  String? versionCheck;
  String? invoiceUrl;
  num? minimumOrderValue;
  String? favouriteListName;

  StoreMetadata({
    this.skipLogin,
    this.versionCheck,
    this.invoiceUrl,
    this.minimumOrderValue,
    this.favouriteListName,
  });

  factory StoreMetadata.fromJson(Map<String, dynamic> json) => StoreMetadata(
    skipLogin: json["skip_login"],
    versionCheck: json["version_check"],
    invoiceUrl: json["invoice_url"],
    minimumOrderValue: json["minimum_order_value"],
    favouriteListName: json["favourite_list_name"],
  );

  Map<String, dynamic> toJson() => {
    "skip_login": skipLogin,
    "version_check": versionCheck,
    "invoice_url": invoiceUrl,
    "minimum_order_value": minimumOrderValue,
    "favourite_list_name": favouriteListName,
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
  String? titleFont;
  String? contentFont;

  Theme({
    this.fontFamily,
    this.primaryColor,
    this.secondaryColor,
    this.header,
    this.productView,
    this.titleFont,
    this.contentFont,
  });

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
    fontFamily: json["fontFamily"],
    primaryColor: json["primaryColor"],
    secondaryColor: json["secondaryColor"],
    header: json["header"],
    productView: json["productView"],
    titleFont: json["titleFont"],
    contentFont: json["contentFont"],
  );

  Map<String, dynamic> toJson() => {
    "fontFamily": fontFamily,
    "primaryColor": primaryColor,
    "secondaryColor": secondaryColor,
    "header": header,
    "productView": productView,
    "titleFont": titleFont,
    "contentFont": contentFont,
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
