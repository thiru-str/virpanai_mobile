// To parse this JSON data, do
//
//     final shippingResponse = shippingResponseFromJson(jsonString);

import 'dart:convert';

ShippingResponse shippingResponseFromJson(String str) => ShippingResponse.fromJson(json.decode(str));

String shippingResponseToJson(ShippingResponse data) => json.encode(data.toJson());

class ShippingResponse {
  List<ShippingOption>? shippingOptions;

  ShippingResponse({
    this.shippingOptions,
  });

  factory ShippingResponse.fromJson(Map<String, dynamic> json) => ShippingResponse(
    shippingOptions: json["shipping_options"] == null ? [] : List<ShippingOption>.from(json["shipping_options"]!.map((x) => ShippingOption.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "shipping_options": shippingOptions == null ? [] : List<dynamic>.from(shippingOptions!.map((x) => x.toJson())),
  };
}

class ShippingOption {
  String? id;
  String? name;
  String? priceType;
  String? serviceZoneId;
  String? shippingProfileId;
  String? providerId;
  Data? data;
  ServiceZone? serviceZone;
  Type? type;
  Provider? provider;
  List<Rule>? rules;
  CalculatedPrice? calculatedPrice;
  List<PriceElement>? prices;
  num? amount;
  bool? isTaxInclusive;

  ShippingOption({
    this.id,
    this.name,
    this.priceType,
    this.serviceZoneId,
    this.shippingProfileId,
    this.providerId,
    this.data,
    this.serviceZone,
    this.type,
    this.provider,
    this.rules,
    this.calculatedPrice,
    this.prices,
    this.amount,
    this.isTaxInclusive,
  });

  factory ShippingOption.fromJson(Map<String, dynamic> json) => ShippingOption(
    id: json["id"],
    name: json["name"],
    priceType: json["price_type"],
    serviceZoneId: json["service_zone_id"],
    shippingProfileId: json["shipping_profile_id"],
    providerId: json["provider_id"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    serviceZone: json["service_zone"] == null ? null : ServiceZone.fromJson(json["service_zone"]),
    type: json["type"] == null ? null : Type.fromJson(json["type"]),
    provider: json["provider"] == null ? null : Provider.fromJson(json["provider"]),
    rules: json["rules"] == null ? [] : List<Rule>.from(json["rules"]!.map((x) => Rule.fromJson(x))),
    calculatedPrice: json["calculated_price"] == null ? null : CalculatedPrice.fromJson(json["calculated_price"]),
    prices: json["prices"] == null ? [] : List<PriceElement>.from(json["prices"]!.map((x) => PriceElement.fromJson(x))),
    amount: json["amount"],
    isTaxInclusive: json["is_tax_inclusive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price_type": priceType,
    "service_zone_id": serviceZoneId,
    "shipping_profile_id": shippingProfileId,
    "provider_id": providerId,
    "data": data?.toJson(),
    "service_zone": serviceZone?.toJson(),
    "type": type?.toJson(),
    "provider": provider?.toJson(),
    "rules": rules == null ? [] : List<dynamic>.from(rules!.map((x) => x.toJson())),
    "calculated_price": calculatedPrice?.toJson(),
    "prices": prices == null ? [] : List<dynamic>.from(prices!.map((x) => x.toJson())),
    "amount": amount,
    "is_tax_inclusive": isTaxInclusive,
  };
}

class CalculatedPrice {
  String? id;
  bool? isCalculatedPricePriceList;
  bool? isCalculatedPriceTaxInclusive;
  num? calculatedAmount;
  RawAmount? rawCalculatedAmount;
  bool? isOriginalPricePriceList;
  bool? isOriginalPriceTaxInclusive;
  num? originalAmount;
  RawAmount? rawOriginalAmount;
  String? currencyCode;
  Price? calculatedPrice;
  Price? originalPrice;

  CalculatedPrice({
    this.id,
    this.isCalculatedPricePriceList,
    this.isCalculatedPriceTaxInclusive,
    this.calculatedAmount,
    this.rawCalculatedAmount,
    this.isOriginalPricePriceList,
    this.isOriginalPriceTaxInclusive,
    this.originalAmount,
    this.rawOriginalAmount,
    this.currencyCode,
    this.calculatedPrice,
    this.originalPrice,
  });

  factory CalculatedPrice.fromJson(Map<String, dynamic> json) => CalculatedPrice(
    id: json["id"],
    isCalculatedPricePriceList: json["is_calculated_price_price_list"],
    isCalculatedPriceTaxInclusive: json["is_calculated_price_tax_inclusive"],
    calculatedAmount: json["calculated_amount"],
    rawCalculatedAmount: json["raw_calculated_amount"] == null ? null : RawAmount.fromJson(json["raw_calculated_amount"]),
    isOriginalPricePriceList: json["is_original_price_price_list"],
    isOriginalPriceTaxInclusive: json["is_original_price_tax_inclusive"],
    originalAmount: json["original_amount"],
    rawOriginalAmount: json["raw_original_amount"] == null ? null : RawAmount.fromJson(json["raw_original_amount"]),
    currencyCode: json["currency_code"],
    calculatedPrice: json["calculated_price"] == null ? null : Price.fromJson(json["calculated_price"]),
    originalPrice: json["original_price"] == null ? null : Price.fromJson(json["original_price"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_calculated_price_price_list": isCalculatedPricePriceList,
    "is_calculated_price_tax_inclusive": isCalculatedPriceTaxInclusive,
    "calculated_amount": calculatedAmount,
    "raw_calculated_amount": rawCalculatedAmount?.toJson(),
    "is_original_price_price_list": isOriginalPricePriceList,
    "is_original_price_tax_inclusive": isOriginalPriceTaxInclusive,
    "original_amount": originalAmount,
    "raw_original_amount": rawOriginalAmount?.toJson(),
    "currency_code": currencyCode,
    "calculated_price": calculatedPrice?.toJson(),
    "original_price": originalPrice?.toJson(),
  };
}

class Price {
  String? id;
  dynamic priceListId;
  dynamic priceListType;
  dynamic minQuantity;
  dynamic maxQuantity;

  Price({
    this.id,
    this.priceListId,
    this.priceListType,
    this.minQuantity,
    this.maxQuantity,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    id: json["id"],
    priceListId: json["price_list_id"],
    priceListType: json["price_list_type"],
    minQuantity: json["min_quantity"],
    maxQuantity: json["max_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "price_list_id": priceListId,
    "price_list_type": priceListType,
    "min_quantity": minQuantity,
    "max_quantity": maxQuantity,
  };
}

class RawAmount {
  String? value;
  num? precision;

  RawAmount({
    this.value,
    this.precision,
  });

  factory RawAmount.fromJson(Map<String, dynamic> json) => RawAmount(
    value: json["value"],
    precision: json["precision"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "precision": precision,
  };
}

class Data {
  String? id;
  String? clientSecret;

  Data({
    this.id,
    this.clientSecret,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    clientSecret: json["client_secret"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "client_secret": clientSecret,
  };
}

class PriceElement {
  String? id;
  dynamic title;
  String? currencyCode;
  dynamic minQuantity;
  dynamic maxQuantity;
  int? rulesCount;
  String? priceSetId;
  dynamic priceListId;
  dynamic priceList;
  RawAmount? rawAmount;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<PriceRule>? priceRules;
  num? amount;

  PriceElement({
    this.id,
    this.title,
    this.currencyCode,
    this.minQuantity,
    this.maxQuantity,
    this.rulesCount,
    this.priceSetId,
    this.priceListId,
    this.priceList,
    this.rawAmount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.priceRules,
    this.amount,
  });

  factory PriceElement.fromJson(Map<String, dynamic> json) => PriceElement(
    id: json["id"],
    title: json["title"],
    currencyCode: json["currency_code"],
    minQuantity: json["min_quantity"],
    maxQuantity: json["max_quantity"],
    rulesCount: json["rules_count"],
    priceSetId: json["price_set_id"],
    priceListId: json["price_list_id"],
    priceList: json["price_list"],
    rawAmount: json["raw_amount"] == null ? null : RawAmount.fromJson(json["raw_amount"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    priceRules: json["price_rules"] == null ? [] : List<PriceRule>.from(json["price_rules"]!.map((x) => PriceRule.fromJson(x))),
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "currency_code": currencyCode,
    "min_quantity": minQuantity,
    "max_quantity": maxQuantity,
    "rules_count": rulesCount,
    "price_set_id": priceSetId,
    "price_list_id": priceListId,
    "price_list": priceList,
    "raw_amount": rawAmount?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "price_rules": priceRules == null ? [] : List<dynamic>.from(priceRules!.map((x) => x.toJson())),
    "amount": amount,
  };
}

class PriceRule {
  String? id;
  String? attribute;
  String? value;
  String? priceRuleOperator;
  int? priority;
  String? priceId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  PriceRule({
    this.id,
    this.attribute,
    this.value,
    this.priceRuleOperator,
    this.priority,
    this.priceId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory PriceRule.fromJson(Map<String, dynamic> json) => PriceRule(
    id: json["id"],
    attribute: json["attribute"],
    value: json["value"],
    priceRuleOperator: json["operator"],
    priority: json["priority"],
    priceId: json["price_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attribute": attribute,
    "value": value,
    "operator": priceRuleOperator,
    "priority": priority,
    "price_id": priceId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Provider {
  String? id;
  bool? isEnabled;

  Provider({
    this.id,
    this.isEnabled,
  });

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
    id: json["id"],
    isEnabled: json["is_enabled"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_enabled": isEnabled,
  };
}

class Rule {
  String? attribute;
  String? value;
  String? ruleOperator;

  Rule({
    this.attribute,
    this.value,
    this.ruleOperator,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
    attribute: json["attribute"],
    value: json["value"],
    ruleOperator: json["operator"],
  );

  Map<String, dynamic> toJson() => {
    "attribute": attribute,
    "value": value,
    "operator": ruleOperator,
  };
}

class ServiceZone {
  String? fulfillmentSetId;
  String? id;
  FulfillmentSet? fulfillmentSet;

  ServiceZone({
    this.fulfillmentSetId,
    this.id,
    this.fulfillmentSet,
  });

  factory ServiceZone.fromJson(Map<String, dynamic> json) => ServiceZone(
    fulfillmentSetId: json["fulfillment_set_id"],
    id: json["id"],
    fulfillmentSet: json["fulfillment_set"] == null
        ? null
        : FulfillmentSet.fromJson(json["fulfillment_set"]),
  );

  Map<String, dynamic> toJson() => {
    "fulfillment_set_id": fulfillmentSetId,
    "id": id,
    "fulfillment_set": fulfillmentSet?.toJson(),
  };
}

class FulfillmentSet {
  String? id;
  String? type;
  String? name;

  FulfillmentSet({
    this.id,
    this.type,
    this.name,
  });

  factory FulfillmentSet.fromJson(Map<String, dynamic> json) => FulfillmentSet(
    id: json["id"],
    type: json["type"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
  };
}

class Type {
  String? id;
  String? label;
  String? description;
  String? code;

  Type({
    this.id,
    this.label,
    this.description,
    this.code,
  });

  factory Type.fromJson(Map<String, dynamic> json) => Type(
    id: json["id"],
    label: json["label"],
    description: json["description"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "label": label,
    "description": description,
    "code": code,
  };
}
