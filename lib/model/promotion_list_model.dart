class PromotionListResponse {
  final List<AvailablePromotion> promotions;

  PromotionListResponse({required this.promotions});

  factory PromotionListResponse.fromJson(Map<String, dynamic> json) {
    return PromotionListResponse(
      promotions: (json['promotions'] as List<dynamic>? ?? [])
          .map((e) => AvailablePromotion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AvailablePromotion {
  final String code;
  final String title;
  final String description;
  final String discountDisplay;
  final bool isEligible;
  final bool isApplied;
  final String? estimatedDiscountDisplay;
  final String? ineligibilityReason;

  AvailablePromotion({
    required this.code,
    required this.title,
    required this.description,
    required this.discountDisplay,
    required this.isEligible,
    required this.isApplied,
    this.estimatedDiscountDisplay,
    this.ineligibilityReason,
  });

  factory AvailablePromotion.fromJson(Map<String, dynamic> json) {
    return AvailablePromotion(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountDisplay: json['discount_display'] as String? ?? '',
      isEligible: json['is_eligible'] as bool? ?? false,
      isApplied: json['is_applied'] as bool? ?? false,
      estimatedDiscountDisplay: json['estimated_discount_display'] as String?,
      ineligibilityReason: json['ineligibility_reason'] as String?,
    );
  }
}
