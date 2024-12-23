// To parse this JSON data, do
//
//     final createOrderResponse = createOrderResponseFromJson(jsonString);

import 'dart:convert';

CreateOrderResponse createOrderResponseFromJson(String str) => CreateOrderResponse.fromJson(json.decode(str));

String createOrderResponseToJson(CreateOrderResponse data) => json.encode(data.toJson());

class CreateOrderResponse {
  int? status;
  String? message;
  Data? data;
  bool? success;
  bool? maintanence;

  CreateOrderResponse({
    this.status,
    this.message,
    this.data,
    this.success,
    this.maintanence,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) => CreateOrderResponse(
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
  List<String>? productsIds;
  List<ProductsDatum>? productsData;
  PriceData? priceData;
  List<String>? discountId;
  List<DiscountDatum>? discountData;
  String? totalPrice;
  String? dateOfOrderFormated;
  int? id;
  DateTime? dateOfOrder;
  int? userId;
  int? employeeId;
  int? invoiceNumber;
  String? paymentMethod;
  String? orderStatus;
  String? totalPriceWithOutTax;
  int? branchId;
  String? reference;
  String? tenantSlug;
  String? fiscalYear;

  Data({
    this.productsIds,
    this.productsData,
    this.priceData,
    this.discountId,
    this.discountData,
    this.totalPrice,
    this.dateOfOrderFormated,
    this.id,
    this.dateOfOrder,
    this.userId,
    this.employeeId,
    this.invoiceNumber,
    this.paymentMethod,
    this.orderStatus,
    this.totalPriceWithOutTax,
    this.branchId,
    this.reference,
    this.tenantSlug,
    this.fiscalYear,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    productsIds: json["products_ids"] == null ? [] : List<String>.from(json["products_ids"]!.map((x) => x)),
    productsData: json["products_data"] == null ? [] : List<ProductsDatum>.from(json["products_data"]!.map((x) => ProductsDatum.fromJson(x))),
    priceData: json["price_data"] == null ? null : PriceData.fromJson(json["price_data"]),
    discountId: json["discount_id"] == null ? [] : List<String>.from(json["discount_id"]!.map((x) => x)),
    discountData: json["discount_data"] == null ? [] : List<DiscountDatum>.from(json["discount_data"]!.map((x) => DiscountDatum.fromJson(x))),
    totalPrice: json["total_price"],
    dateOfOrderFormated: json["date_of_order_formated"],
    id: json["_id"],
    dateOfOrder: json["date_of_order"] == null ? null : DateTime.parse(json["date_of_order"]),
    userId: json["user_id"],
    employeeId: json["employee_id"],
    invoiceNumber: json["invoice_number"],
    paymentMethod: json["Payment_method"],
    orderStatus: json["order_status"],
    totalPriceWithOutTax: json["total_price_with_out_tax"],
    branchId: json["branch_id"],
    reference: json["reference"],
    tenantSlug: json["tenant_slug"],
    fiscalYear: json["fiscal_year"],
  );

  Map<String, dynamic> toJson() => {
    "products_ids": productsIds == null ? [] : List<dynamic>.from(productsIds!.map((x) => x)),
    "products_data": productsData == null ? [] : List<dynamic>.from(productsData!.map((x) => x.toJson())),
    "price_data": priceData?.toJson(),
    "discount_id": discountId == null ? [] : List<dynamic>.from(discountId!.map((x) => x)),
    "discount_data": discountData == null ? [] : List<dynamic>.from(discountData!.map((x) => x.toJson())),
    "total_price": totalPrice,
    "date_of_order_formated": dateOfOrderFormated,
    "_id": id,
    "date_of_order": dateOfOrder?.toIso8601String(),
    "user_id": userId,
    "employee_id": employeeId,
    "invoice_number": invoiceNumber,
    "Payment_method": paymentMethod,
    "order_status": orderStatus,
    "total_price_with_out_tax": totalPriceWithOutTax,
    "branch_id": branchId,
    "reference": reference,
    "tenant_slug": tenantSlug,
    "fiscal_year": fiscalYear,
  };
}

class DiscountDatum {
  String? type;
  int? amount;
  int? quantity;

  DiscountDatum({
    this.type,
    this.amount,
    this.quantity,
  });

  factory DiscountDatum.fromJson(Map<String, dynamic> json) => DiscountDatum(
    type: json["type"],
    amount: json["amount"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "amount": amount,
    "quantity": quantity,
  };
}

class PriceData {
  List<PriceDatum>? priceData;
  String? totalPriceWithTax;
  String? totalPriceWithoutIva;
  String? totalPayable;
  String? totalPayWithoutTax;

  PriceData({
    this.priceData,
    this.totalPriceWithTax,
    this.totalPriceWithoutIva,
    this.totalPayable,
    this.totalPayWithoutTax,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) => PriceData(
    priceData: json["price_data"] == null ? [] : List<PriceDatum>.from(json["price_data"]!.map((x) => PriceDatum.fromJson(x))),
    totalPriceWithTax: json["total_price_with_tax"],
    totalPriceWithoutIva: json["total_price_without_iva"],
    totalPayable: json["total_payable"],
    totalPayWithoutTax: json["total_pay_without_tax"],
  );

  Map<String, dynamic> toJson() => {
    "price_data": priceData == null ? [] : List<dynamic>.from(priceData!.map((x) => x.toJson())),
    "total_price_with_tax": totalPriceWithTax,
    "total_price_without_iva": totalPriceWithoutIva,
    "total_payable": totalPayable,
    "total_pay_without_tax": totalPayWithoutTax,
  };
}

class PriceDatum {
  int? id;
  String? productName;
  String? discountId;
  String? discountName;
  int? discountPrice;
  String? discountType;
  int? haveDiscount;
  int? beanValue;
  String? price;

  PriceDatum({
    this.id,
    this.productName,
    this.discountId,
    this.discountName,
    this.discountPrice,
    this.discountType,
    this.haveDiscount,
    this.beanValue,
    this.price,
  });

  factory PriceDatum.fromJson(Map<String, dynamic> json) => PriceDatum(
    id: json["_id"],
    productName: json["product_name"],
    discountId: json["discount_id"],
    discountName: json["discount_name"],
    discountPrice: json["discount_price"],
    discountType: json["discount_type"],
    haveDiscount: json["have_discount"],
    beanValue: json["bean_value"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "product_name": productName,
    "discount_id": discountId,
    "discount_name": discountName,
    "discount_price": discountPrice,
    "discount_type": discountType,
    "have_discount": haveDiscount,
    "bean_value": beanValue,
    "price": price,
  };
}

class ProductsDatum {
  int? id;
  String? productName;
  int? price;
  int? totalPrice;
  int? quantity;
  String? discountId;
  String? discountName;
  int? discountPrice;
  String? discountType;
  int? haveDiscount;
  int? beanValue;
  int? taxPercent;
  int? tax;
  int? categoryId;

  ProductsDatum({
    this.id,
    this.productName,
    this.price,
    this.totalPrice,
    this.quantity,
    this.discountId,
    this.discountName,
    this.discountPrice,
    this.discountType,
    this.haveDiscount,
    this.beanValue,
    this.taxPercent,
    this.tax,
    this.categoryId,
  });

  factory ProductsDatum.fromJson(Map<String, dynamic> json) => ProductsDatum(
    id: json["_id"],
    productName: json["product_name"],
    price: json["price"],
    totalPrice: json["total_price"],
    quantity: json["quantity"],
    discountId: json["discount_id"],
    discountName: json["discount_name"],
    discountPrice: json["discount_price"],
    discountType: json["discount_type"],
    haveDiscount: json["have_discount"],
    beanValue: json["bean_value"],
    taxPercent: json["tax_percent"],
    tax: json["tax"],
    categoryId: json["category_id"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "product_name": productName,
    "price": price,
    "total_price": totalPrice,
    "quantity": quantity,
    "discount_id": discountId,
    "discount_name": discountName,
    "discount_price": discountPrice,
    "discount_type": discountType,
    "have_discount": haveDiscount,
    "bean_value": beanValue,
    "tax_percent": taxPercent,
    "tax": tax,
    "category_id": categoryId,
  };
}
