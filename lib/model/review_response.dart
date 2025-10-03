// To parse this JSON data, do
//
//     final reviewResponse = reviewResponseFromJson(jsonString);

import 'dart:convert';

ReviewResponse reviewResponseFromJson(String str) => ReviewResponse.fromJson(json.decode(str));

String reviewResponseToJson(ReviewResponse data) => json.encode(data.toJson());

class ReviewResponse {
  bool? status;
  bool? isOrdered;
  Data? data;
  String? message;

  ReviewResponse({
    this.status,
    this.isOrdered,
    this.data,
    this.message,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) => ReviewResponse(
    status: json["status"],
    isOrdered: json["is_ordered"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "is_ordered": isOrdered,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  CustomerReview? customerReview;
  List<ProductReview>? productReviews;
  int? count;
  int? limit;
  int? offset;

  Data({
    this.customerReview,
    this.productReviews,
    this.count,
    this.limit,
    this.offset,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    customerReview: json["customer_review"] == null ? null : CustomerReview.fromJson(json["customer_review"]),
    productReviews: json["product_reviews"] == null ? [] : List<ProductReview>.from(json["product_reviews"]!.map((x) => ProductReview.fromJson(x))),
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
  );

  Map<String, dynamic> toJson() => {
    "customer_review": customerReview?.toJson(),
    "product_reviews": productReviews == null ? [] : List<dynamic>.from(productReviews!.map((x) => x.toJson())),
    "count": count,
    "limit": limit,
    "offset": offset,
  };
}

class CustomerReview {
  CustomerReview();

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
  );

  Map<String, dynamic> toJson() => {
  };
}

class ProductReview {
  String? id;
  String? rating;
  String? description;
  Customer? customer;

  ProductReview({
    this.id,
    this.rating,
    this.description,
    this.customer,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
    id: json["id"],
    rating: json["rating"],
    description: json["description"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rating": rating,
    "description": description,
    "customer": customer?.toJson(),
  };
}

class Customer {
  String? firstName;
  String? lastName;
  String? id;

  Customer({
    this.firstName,
    this.lastName,
    this.id,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    firstName: json["first_name"],
    lastName: json["last_name"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "id": id,
  };
}
