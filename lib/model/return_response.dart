// To parse this JSON data, do
//
//     final returnResponse = returnResponseFromJson(jsonString);

import 'dart:convert';

ReturnResponse returnResponseFromJson(String str) => ReturnResponse.fromJson(json.decode(str));

String returnResponseToJson(ReturnResponse data) => json.encode(data.toJson());

class ReturnResponse {
  List<ReturnReason>? returnReasons;
  int? count;
  int? offset;
  int? limit;

  ReturnResponse({
    this.returnReasons,
    this.count,
    this.offset,
    this.limit,
  });

  factory ReturnResponse.fromJson(Map<String, dynamic> json) => ReturnResponse(
    returnReasons: json["return_reasons"] == null ? [] : List<ReturnReason>.from(json["return_reasons"]!.map((x) => ReturnReason.fromJson(x))),
    count: json["count"],
    offset: json["offset"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "return_reasons": returnReasons == null ? [] : List<dynamic>.from(returnReasons!.map((x) => x.toJson())),
    "count": count,
    "offset": offset,
    "limit": limit,
  };
}

class ReturnReason {
  String? id;
  String? value;
  String? label;
  dynamic parentReturnReasonId;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  dynamic parentReturnReason;
  List<dynamic>? returnReasonChildren;

  ReturnReason({
    this.id,
    this.value,
    this.label,
    this.parentReturnReasonId,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.parentReturnReason,
    this.returnReasonChildren,
  });

  factory ReturnReason.fromJson(Map<String, dynamic> json) => ReturnReason(
    id: json["id"],
    value: json["value"],
    label: json["label"],
    parentReturnReasonId: json["parent_return_reason_id"],
    description: json["description"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    parentReturnReason: json["parent_return_reason"],
    returnReasonChildren: json["return_reason_children"] == null ? [] : List<dynamic>.from(json["return_reason_children"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "value": value,
    "label": label,
    "parent_return_reason_id": parentReturnReasonId,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "parent_return_reason": parentReturnReason,
    "return_reason_children": returnReasonChildren == null ? [] : List<dynamic>.from(returnReasonChildren!.map((x) => x)),
  };
}
