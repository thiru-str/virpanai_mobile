// To parse this JSON data, do
//
//     final getOrdersResponse = getOrdersResponseFromJson(jsonString);

import 'dart:convert';

GetOrdersResponse getOrdersResponseFromJson(String str) => GetOrdersResponse.fromJson(json.decode(str));

String getOrdersResponseToJson(GetOrdersResponse data) => json.encode(data.toJson());

class GetOrdersResponse {
  int? status;
  String? message;
  Data? data;
  bool? success;
  bool? maintanence;

  GetOrdersResponse({
    this.status,
    this.message,
    this.data,
    this.success,
    this.maintanence,
  });

  factory GetOrdersResponse.fromJson(Map<String, dynamic> json) => GetOrdersResponse(
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
  List<OrderList>? orderList;
  String? reference;
  List<Discount>? discount;

  Data({
    this.orderList,
    this.reference,
    this.discount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    orderList: json["order_list"] == null ? [] : List<OrderList>.from(json["order_list"]!.map((x) => OrderList.fromJson(x))),
    reference: json["reference"],
    discount: json["discount"] == null ? [] : List<Discount>.from(json["discount"]!.map((x) => Discount.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "order_list": orderList == null ? [] : List<dynamic>.from(orderList!.map((x) => x.toJson())),
    "reference": reference,
    "discount": discount == null ? [] : List<dynamic>.from(discount!.map((x) => x.toJson())),
  };
}

class Discount {
  int? id;
  String? tenantSlug;
  dynamic discountName;
  dynamic amount;
  dynamic type;
  dynamic createdBy;
  bool? isDeleted;
  String? color;
  int? position;

  Discount({
    this.id,
    this.tenantSlug,
    this.discountName,
    this.amount,
    this.type,
    this.createdBy,
    this.isDeleted,
    this.color,
    this.position,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
    id: json["_id"],
    tenantSlug: json["tenant_slug"],
    discountName: json["discount_name"],
    amount: json["amount"],
    type: json["type"],
    createdBy: json["created_by"],
    isDeleted: json["is_deleted"],
    color: json["color"],
    position: json["position"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "tenant_slug": tenantSlug,
    "discount_name": discountName,
    "amount": amount,
    "type": type,
    "created_by": createdBy,
    "is_deleted": isDeleted,
    "color": color,
    "position": position,
  };
}

class OrderList {
  List<String>? productsIds;
  List<ProductsDatum>? productsData;
  PriceData? priceData;
  List<String>? discountId;
  List<DiscountDatum>? discountData;
  String? totalPrice;
  String? dateOfOrderFormated;
  int? id;
  String? tenantSlug;
  DateTime? dateOfOrder;
  String? reference;
  int? userId;
  int? employeeId;
  int? branchId;
  String? invoiceNumber;
  String? paymentMethod;
  String? orderStatus;
  String? totalPriceWithOutTax;
  dynamic cancelReason;
  int? isBeanAdded;
  String? fiscalYear;
  DateTime? createdAt;
  BranchInfo? branchInfo;
  EmployeeInfo? employeeInfo;
  UserInfo? userInfo;

  OrderList({
    this.productsIds,
    this.productsData,
    this.priceData,
    this.discountId,
    this.discountData,
    this.totalPrice,
    this.dateOfOrderFormated,
    this.id,
    this.tenantSlug,
    this.dateOfOrder,
    this.reference,
    this.userId,
    this.employeeId,
    this.branchId,
    this.invoiceNumber,
    this.paymentMethod,
    this.orderStatus,
    this.totalPriceWithOutTax,
    this.cancelReason,
    this.isBeanAdded,
    this.fiscalYear,
    this.createdAt,
    this.branchInfo,
    this.employeeInfo,
    this.userInfo,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
    productsIds: json["products_ids"] == null ? [] : List<String>.from(json["products_ids"]!.map((x) => x)),
    productsData: json["products_data"] == null ? [] : List<ProductsDatum>.from(json["products_data"]!.map((x) => ProductsDatum.fromJson(x))),
    priceData: json["price_data"] == null ? null : PriceData.fromJson(json["price_data"]),
    discountId: json["discount_id"] == null ? [] : List<String>.from(json["discount_id"]!.map((x) => x)),
    discountData: json["discount_data"] == null ? [] : List<DiscountDatum>.from(json["discount_data"]!.map((x) => DiscountDatum.fromJson(x))),
    totalPrice: json["total_price"],
    dateOfOrderFormated: json["date_of_order_formated"],
    id: json["_id"],
    tenantSlug: json["tenant_slug"],
    dateOfOrder: json["date_of_order"] == null ? null : DateTime.parse(json["date_of_order"]),
    reference: json["reference"],
    userId: json["user_id"],
    employeeId: json["employee_id"],
    branchId: json["branch_id"],
    invoiceNumber: json["invoice_number"],
    paymentMethod: json["Payment_method"],
    orderStatus: json["order_status"],
    totalPriceWithOutTax: json["total_price_with_out_tax"],
    cancelReason: json["cancel_reason"],
    isBeanAdded: json["is_bean_added"],
    fiscalYear: json["fiscal_year"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    branchInfo: json["branch_info"] == null ? null : BranchInfo.fromJson(json["branch_info"]),
    employeeInfo: json["employee_info"] == null ? null : EmployeeInfo.fromJson(json["employee_info"]),
    userInfo: json["user_info"] == null ? null : UserInfo.fromJson(json["user_info"]),
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
    "tenant_slug": tenantSlug,
    "date_of_order": dateOfOrder?.toIso8601String(),
    "reference": reference,
    "user_id": userId,
    "employee_id": employeeId,
    "branch_id": branchId,
    "invoice_number": invoiceNumber,
    "Payment_method": paymentMethod,
    "order_status": orderStatus,
    "total_price_with_out_tax": totalPriceWithOutTax,
    "cancel_reason": cancelReason,
    "is_bean_added": isBeanAdded,
    "fiscal_year": fiscalYear,
    "created_at": createdAt?.toIso8601String(),
    "branch_info": branchInfo?.toJson(),
    "employee_info": employeeInfo?.toJson(),
    "user_info": userInfo?.toJson(),
  };
}

class BranchInfo {
  String? lat;
  String? lng;
  int? id;
  String? tenantSlug;
  int? createdBy;
  String? branchName;
  bool? showOnApp;
  String? invoiceFrom;
  String? branchCode;
  DateTime? createdAt;

  BranchInfo({
    this.lat,
    this.lng,
    this.id,
    this.tenantSlug,
    this.createdBy,
    this.branchName,
    this.showOnApp,
    this.invoiceFrom,
    this.branchCode,
    this.createdAt,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) => BranchInfo(
    lat: json["lat"],
    lng: json["lng"],
    id: json["_id"],
    tenantSlug: json["tenant_slug"],
    createdBy: json["created_by"],
    branchName: json["branch_name"],
    showOnApp: json["show_on_app"],
    invoiceFrom: json["invoice_from"],
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
    "invoice_from": invoiceFrom,
    "branch_code": branchCode,
    "created_at": createdAt?.toIso8601String(),
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

class EmployeeInfo {
  String? loginTime;
  int? id;
  String? tenantSlug;
  String? employeeName;
  String? password;
  int? createdBy;
  bool? isLoggedIn;
  bool? isDeleted;
  DateTime? createdAt;
  dynamic color;

  EmployeeInfo({
    this.loginTime,
    this.id,
    this.tenantSlug,
    this.employeeName,
    this.password,
    this.createdBy,
    this.isLoggedIn,
    this.isDeleted,
    this.createdAt,
    this.color,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) => EmployeeInfo(
    loginTime: json["login_time"],
    id: json["_id"],
    tenantSlug: json["tenant_slug"],
    employeeName: json["employee_name"],
    password: json["password"],
    createdBy: json["created_by"],
    isLoggedIn: json["is_logged_in"],
    isDeleted: json["is_deleted"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "login_time": loginTime,
    "_id": id,
    "tenant_slug": tenantSlug,
    "employee_name": employeeName,
    "password": password,
    "created_by": createdBy,
    "is_logged_in": isLoggedIn,
    "is_deleted": isDeleted,
    "created_at": createdAt?.toIso8601String(),
    "color": color,
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

class UserInfo {
  String? fullName;
  bool? isBirthdayToday;
  String? beansEarnerd;
  int? id;
  String? tenantSlug;
  dynamic firstName;
  dynamic lastName;
  dynamic emailOtp;
  bool? isVerified;
  bool? isDeactivated;
  dynamic birthDay;
  String? email;
  String? password;
  dynamic defaultStore;
  bool? isLoggedIn;
  dynamic color;
  bool? isDeleted;
  String? beansSpent;
  String? userReferenceNumber;
  String? referralCode;
  String? deviceId;
  String? userMobile;
  dynamic mobileOtp;
  bool? isMobileVerified;
  DateTime? createdAt;

  UserInfo({
    this.fullName,
    this.isBirthdayToday,
    this.beansEarnerd,
    this.id,
    this.tenantSlug,
    this.firstName,
    this.lastName,
    this.emailOtp,
    this.isVerified,
    this.isDeactivated,
    this.birthDay,
    this.email,
    this.password,
    this.defaultStore,
    this.isLoggedIn,
    this.color,
    this.isDeleted,
    this.beansSpent,
    this.userReferenceNumber,
    this.referralCode,
    this.deviceId,
    this.userMobile,
    this.mobileOtp,
    this.isMobileVerified,
    this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    fullName: json["full_name"],
    isBirthdayToday: json["is_birthday_today"],
    beansEarnerd: json["beans_earnerd"],
    id: json["_id"],
    tenantSlug: json["tenant_slug"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    emailOtp: json["email_otp"],
    isVerified: json["is_verified"],
    isDeactivated: json["is_deactivated"],
    birthDay: json["birth_day"],
    email: json["email"],
    password: json["password"],
    defaultStore: json["default_store"],
    isLoggedIn: json["is_logged_in"],
    color: json["color"],
    isDeleted: json["is_deleted"],
    beansSpent: json["beans_spent"],
    userReferenceNumber: json["user_reference_number"],
    referralCode: json["referral_code"],
    deviceId: json["device_id"],
    userMobile: json["user_mobile"],
    mobileOtp: json["mobile_otp"],
    isMobileVerified: json["is_mobile_verified"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "is_birthday_today": isBirthdayToday,
    "beans_earnerd": beansEarnerd,
    "_id": id,
    "tenant_slug": tenantSlug,
    "first_name": firstName,
    "last_name": lastName,
    "email_otp": emailOtp,
    "is_verified": isVerified,
    "is_deactivated": isDeactivated,
    "birth_day": birthDay,
    "email": email,
    "password": password,
    "default_store": defaultStore,
    "is_logged_in": isLoggedIn,
    "color": color,
    "is_deleted": isDeleted,
    "beans_spent": beansSpent,
    "user_reference_number": userReferenceNumber,
    "referral_code": referralCode,
    "device_id": deviceId,
    "user_mobile": userMobile,
    "mobile_otp": mobileOtp,
    "is_mobile_verified": isMobileVerified,
    "created_at": createdAt?.toIso8601String(),
  };
}
