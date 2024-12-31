// To parse this JSON data, do
//
//     final addCartResponse = addCartResponseFromJson(jsonString);

import 'dart:convert';

CartResponse addCartResponseFromJson(String str) => CartResponse.fromJson(json.decode(str));

String cartResponseToJson(CartResponse data) => json.encode(data.toJson());

class CartResponse {
  Cart? cart;

  CartResponse({
    this.cart,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
  );

  Map<String, dynamic> toJson() => {
    "cart": cart?.toJson(),
  };
}

class Cart {
  String? id;
  String? currencyCode;
  String? email;
  String? regionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic completedAt;
  num? total;
  num? subtotal;
  num? taxTotal;
  int? discountTotal;
  num? discountSubtotal;
  num? discountTaxTotal;
  num? originalTotal;
  num? originalTaxTotal;
  num? itemTotal;
  num? itemSubtotal;
  num? itemTaxTotal;
  num? originalItemTotal;
  num? originalItemSubtotal;
  num? originalItemTaxTotal;
  num? shippingTotal;
  num? shippingSubtotal;
  num? shippingTaxTotal;
  num? originalShippingTaxTotal;
  num? originalShippingSubtotal;
  num? originalShippingTotal;
  dynamic metadata;
  String? salesChannelId;
  String? shippingAddressId;
  String? customerId;
  List<Item>? items;
  List<dynamic>? shippingMethods;
  ShippingAddress? shippingAddress;
  dynamic billingAddress;
  Customer? customer;
  Region? region;
  List<dynamic>? promotions;

  Cart({
    this.id,
    this.currencyCode,
    this.email,
    this.regionId,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.total,
    this.subtotal,
    this.taxTotal,
    this.discountTotal,
    this.discountSubtotal,
    this.discountTaxTotal,
    this.originalTotal,
    this.originalTaxTotal,
    this.itemTotal,
    this.itemSubtotal,
    this.itemTaxTotal,
    this.originalItemTotal,
    this.originalItemSubtotal,
    this.originalItemTaxTotal,
    this.shippingTotal,
    this.shippingSubtotal,
    this.shippingTaxTotal,
    this.originalShippingTaxTotal,
    this.originalShippingSubtotal,
    this.originalShippingTotal,
    this.metadata,
    this.salesChannelId,
    this.shippingAddressId,
    this.customerId,
    this.items,
    this.shippingMethods,
    this.shippingAddress,
    this.billingAddress,
    this.customer,
    this.region,
    this.promotions,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["id"],
    currencyCode: json["currency_code"],
    email: json["email"],
    regionId: json["region_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    completedAt: json["completed_at"],
    total: json["total"],
    subtotal: json["subtotal"],
    taxTotal: json["tax_total"],
    discountTotal: json["discount_total"],
    discountSubtotal: json["discount_subtotal"],
    discountTaxTotal: json["discount_tax_total"],
    originalTotal: json["original_total"],
    originalTaxTotal: json["original_tax_total"],
    itemTotal: json["item_total"],
    itemSubtotal: json["item_subtotal"],
    itemTaxTotal: json["item_tax_total"],
    originalItemTotal: json["original_item_total"],
    originalItemSubtotal: json["original_item_subtotal"],
    originalItemTaxTotal: json["original_item_tax_total"],
    shippingTotal: json["shipping_total"],
    shippingSubtotal: json["shipping_subtotal"],
    shippingTaxTotal: json["shipping_tax_total"],
    originalShippingTaxTotal: json["original_shipping_tax_total"],
    originalShippingSubtotal: json["original_shipping_subtotal"],
    originalShippingTotal: json["original_shipping_total"],
    metadata: json["metadata"],
    salesChannelId: json["sales_channel_id"],
    shippingAddressId: json["shipping_address_id"],
    customerId: json["customer_id"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    shippingMethods: json["shipping_methods"] == null ? [] : List<dynamic>.from(json["shipping_methods"]!.map((x) => x)),
    shippingAddress: json["shipping_address"] == null ? null : ShippingAddress.fromJson(json["shipping_address"]),
    billingAddress: json["billing_address"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    region: json["region"] == null ? null : Region.fromJson(json["region"]),
    promotions: json["promotions"] == null ? [] : List<dynamic>.from(json["promotions"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_code": currencyCode,
    "email": email,
    "region_id": regionId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "completed_at": completedAt,
    "total": total,
    "subtotal": subtotal,
    "tax_total": taxTotal,
    "discount_total": discountTotal,
    "discount_subtotal": discountSubtotal,
    "discount_tax_total": discountTaxTotal,
    "original_total": originalTotal,
    "original_tax_total": originalTaxTotal,
    "item_total": itemTotal,
    "item_subtotal": itemSubtotal,
    "item_tax_total": itemTaxTotal,
    "original_item_total": originalItemTotal,
    "original_item_subtotal": originalItemSubtotal,
    "original_item_tax_total": originalItemTaxTotal,
    "shipping_total": shippingTotal,
    "shipping_subtotal": shippingSubtotal,
    "shipping_tax_total": shippingTaxTotal,
    "original_shipping_tax_total": originalShippingTaxTotal,
    "original_shipping_subtotal": originalShippingSubtotal,
    "original_shipping_total": originalShippingTotal,
    "metadata": metadata,
    "sales_channel_id": salesChannelId,
    "shipping_address_id": shippingAddressId,
    "customer_id": customerId,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "shipping_methods": shippingMethods == null ? [] : List<dynamic>.from(shippingMethods!.map((x) => x)),
    "shipping_address": shippingAddress?.toJson(),
    "billing_address": billingAddress,
    "customer": customer?.toJson(),
    "region": region?.toJson(),
    "promotions": promotions == null ? [] : List<dynamic>.from(promotions!.map((x) => x)),
  };
}

class Customer {
  String? id;
  String? email;
  List<dynamic>? groups;

  Customer({
    this.id,
    this.email,
    this.groups,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"],
    email: json["email"],
    groups: json["groups"] == null ? [] : List<dynamic>.from(json["groups"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "groups": groups == null ? [] : List<dynamic>.from(groups!.map((x) => x)),
  };
}

class Item {
  String? id;
  String? thumbnail;
  String? variantId;
  String? productId;
  dynamic productTypeId;
  String? productTitle;
  String? productDescription;
  String? productSubtitle;
  dynamic productType;
  String? productCollection;
  String? productHandle;
  String? variantSku;
  dynamic variantBarcode;
  String? variantTitle;
  bool? requiresShipping;
  Metadata? metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? title;
  int? quantity;
  num? unitPrice;
  dynamic compareAtUnitPrice;
  bool? isTaxInclusive;
  List<dynamic>? taxLines;
  List<dynamic>? adjustments;
  Product? product;

  Item({
    this.id,
    this.thumbnail,
    this.variantId,
    this.productId,
    this.productTypeId,
    this.productTitle,
    this.productDescription,
    this.productSubtitle,
    this.productType,
    this.productCollection,
    this.productHandle,
    this.variantSku,
    this.variantBarcode,
    this.variantTitle,
    this.requiresShipping,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.quantity,
    this.unitPrice,
    this.compareAtUnitPrice,
    this.isTaxInclusive,
    this.taxLines,
    this.adjustments,
    this.product,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    thumbnail: json["thumbnail"],
    variantId: json["variant_id"],
    productId: json["product_id"],
    productTypeId: json["product_type_id"],
    productTitle: json["product_title"],
    productDescription: json["product_description"],
    productSubtitle: json["product_subtitle"],
    productType: json["product_type"],
    productCollection: json["product_collection"],
    productHandle: json["product_handle"],
    variantSku: json["variant_sku"],
    variantBarcode: json["variant_barcode"],
    variantTitle: json["variant_title"],
    requiresShipping: json["requires_shipping"],
    metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    title: json["title"],
    quantity: json["quantity"],
    unitPrice: json["unit_price"],
    compareAtUnitPrice: json["compare_at_unit_price"],
    isTaxInclusive: json["is_tax_inclusive"],
    taxLines: json["tax_lines"] == null ? [] : List<dynamic>.from(json["tax_lines"]!.map((x) => x)),
    adjustments: json["adjustments"] == null ? [] : List<dynamic>.from(json["adjustments"]!.map((x) => x)),
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "thumbnail": thumbnail,
    "variant_id": variantId,
    "product_id": productId,
    "product_type_id": productTypeId,
    "product_title": productTitle,
    "product_description": productDescription,
    "product_subtitle": productSubtitle,
    "product_type": productType,
    "product_collection": productCollection,
    "product_handle": productHandle,
    "variant_sku": variantSku,
    "variant_barcode": variantBarcode,
    "variant_title": variantTitle,
    "requires_shipping": requiresShipping,
    "metadata": metadata?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "title": title,
    "quantity": quantity,
    "unit_price": unitPrice,
    "compare_at_unit_price": compareAtUnitPrice,
    "is_tax_inclusive": isTaxInclusive,
    "tax_lines": taxLines == null ? [] : List<dynamic>.from(taxLines!.map((x) => x)),
    "adjustments": adjustments == null ? [] : List<dynamic>.from(adjustments!.map((x) => x)),
    "product": product?.toJson(),
  };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
  );

  Map<String, dynamic> toJson() => {
  };
}

class Product {
  String? id;
  String? collectionId;
  dynamic typeId;
  List<Category>? categories;
  List<dynamic>? tags;

  Product({
    this.id,
    this.collectionId,
    this.typeId,
    this.categories,
    this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    collectionId: json["collection_id"],
    typeId: json["type_id"],
    categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collection_id": collectionId,
    "type_id": typeId,
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
  };
}

class Category {
  String? id;

  Category({
    this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}

class Region {
  String? id;
  String? name;
  String? currencyCode;
  bool? automaticTaxes;
  List<Country>? countries;

  Region({
    this.id,
    this.name,
    this.currencyCode,
    this.automaticTaxes,
    this.countries,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    id: json["id"],
    name: json["name"],
    currencyCode: json["currency_code"],
    automaticTaxes: json["automatic_taxes"],
    countries: json["countries"] == null ? [] : List<Country>.from(json["countries"]!.map((x) => Country.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "currency_code": currencyCode,
    "automatic_taxes": automaticTaxes,
    "countries": countries == null ? [] : List<dynamic>.from(countries!.map((x) => x.toJson())),
  };
}

class Country {
  String? iso2;
  String? iso3;
  String? numCode;
  String? name;
  String? displayName;
  String? regionId;
  dynamic metadata;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Country({
    this.iso2,
    this.iso3,
    this.numCode,
    this.name,
    this.displayName,
    this.regionId,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    iso2: json["iso_2"],
    iso3: json["iso_3"],
    numCode: json["num_code"],
    name: json["name"],
    displayName: json["display_name"],
    regionId: json["region_id"],
    metadata: json["metadata"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "iso_2": iso2,
    "iso_3": iso3,
    "num_code": numCode,
    "name": name,
    "display_name": displayName,
    "region_id": regionId,
    "metadata": metadata,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class ShippingAddress {
  String? id;
  dynamic firstName;
  dynamic lastName;
  dynamic company;
  dynamic address1;
  dynamic address2;
  dynamic city;
  dynamic postalCode;
  String? countryCode;
  dynamic province;
  dynamic phone;

  ShippingAddress({
    this.id,
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.postalCode,
    this.countryCode,
    this.province,
    this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    company: json["company"],
    address1: json["address_1"],
    address2: json["address_2"],
    city: json["city"],
    postalCode: json["postal_code"],
    countryCode: json["country_code"],
    province: json["province"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "company": company,
    "address_1": address1,
    "address_2": address2,
    "city": city,
    "postal_code": postalCode,
    "country_code": countryCode,
    "province": province,
    "phone": phone,
  };
}
