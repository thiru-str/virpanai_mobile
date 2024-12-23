// To parse this JSON data, do
//
//     final branchResponse = branchResponseFromJson(jsonString);

import 'dart:convert';

BranchResponse branchResponseFromJson(String str) => BranchResponse.fromJson(json.decode(str));

String branchResponseToJson(BranchResponse data) => json.encode(data.toJson());

class BranchResponse {
  int? status;
  String? message;
  Data? data;
  bool? success;
  bool? maintanence;

  BranchResponse({
    this.status,
    this.message,
    this.data,
    this.success,
    this.maintanence,
  });

  factory BranchResponse.fromJson(Map<String, dynamic> json) => BranchResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    success: json["success"],
    maintanence: json["maintanence"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "success": success,
    "maintanence": maintanence,
  };
}

class Data {
  List<BranchList>? branchList;

  Data({
    this.branchList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    branchList: json["branch_list"] == null ? [] : List<BranchList>.from(json["branch_list"]!.map((x) => BranchList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "branch_list": branchList == null ? [] : List<dynamic>.from(branchList!.map((x) => x.toJson())),
  };
}

class BranchList {
  String? lat;
  String? lng;
  int? id;
  String? tenantSlug;
  int? createdBy;
  String? branchName;
  bool? showOnApp;
  //dynamic invoiceFrom;
  String? branchCode;
  DateTime? createdAt;

  BranchList({
    this.lat,
    this.lng,
    this.id,
    this.tenantSlug,
    this.createdBy,
    this.branchName,
    this.showOnApp,
    //this.invoiceFrom,
    this.branchCode,
    this.createdAt,
  });

  factory BranchList.fromJson(Map<String, dynamic> json) => BranchList(
    lat: json["lat"],
    lng: json["lng"],
    id: json["_id"],
    tenantSlug: json["tenant_slug"],
    createdBy: json["created_by"],
    branchName: json["branch_name"],
    showOnApp: json["show_on_app"],
    //invoiceFrom: json["invoice_from"],
    branchCode: json["branch_code"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
    "_id": id,
    "tenant_slug": tenantSlug,
    "created_by": createdBy,
    "branch_name": branchName,
    "show_on_app": showOnApp,
    //"invoice_from": invoiceFrom,
    "branch_code": branchCode,
    "created_at": createdAt?.toIso8601String(),
  };
}
