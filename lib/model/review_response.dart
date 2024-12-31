// To parse this JSON data, do
//
//     final reviewResponse = reviewResponseFromJson(jsonString);

import 'dart:convert';

ReviewResponse reviewResponseFromJson(String str) => ReviewResponse.fromJson(json.decode(str));

String reviewResponseToJson(ReviewResponse data) => json.encode(data.toJson());

class ReviewResponse {
  double? overallRating;
  List<Review>? customerReview;
  List<Review>? productReviews;
  int? count;
  int? limit;
  int? offset;

  ReviewResponse({
    this.overallRating,
    this.customerReview,
    this.productReviews,
    this.count,
    this.limit,
    this.offset,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) => ReviewResponse(
    overallRating: json["overall_rating"]?.toDouble(),
    customerReview: json["customer_review"] == null ? [] : List<Review>.from(json["customer_review"]!.map((x) => Review.fromJson(x))),
    productReviews: json["product_reviews"] == null ? [] : List<Review>.from(json["product_reviews"]!.map((x) => Review.fromJson(x))),
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
  );

  Map<String, dynamic> toJson() => {
    "overall_rating": overallRating,
    "customer_review": customerReview == null ? [] : List<dynamic>.from(customerReview!.map((x) => x.toJson())),
    "product_reviews": productReviews == null ? [] : List<dynamic>.from(productReviews!.map((x) => x.toJson())),
    "count": count,
    "limit": limit,
    "offset": offset,
  };
}

class Review {
  String? id;
  String? customerId;
  String? productId;
  String? rating;
  String? description;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  Customer? customer;

  Review({
    this.id,
    this.customerId,
    this.productId,
    this.rating,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.customer,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json["id"],
    customerId: json["customer_id"],
    productId: json["product_id"],
    rating: json["rating"],
    description: json["description"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "product_id": productId,
    "rating": rating,
    "description": description,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
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
