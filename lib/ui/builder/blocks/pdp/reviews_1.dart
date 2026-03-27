import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';

/// Reviews1 - Rating summary and review list.
/// Extracted from product_detail_page.dart buildReviews()
class Reviews1Widget extends StatelessWidget {
  final List<Map<String, dynamic>> reviews; // [{rating, description, customer: {firstName, lastName}}]
  final double? averageRating;
  final int? totalReviews;
  final BlockConfig config;

  const Reviews1Widget({
    super.key,
    required this.reviews,
    required this.config,
    this.averageRating,
    this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final perPage = config.getInt('reviews_per_page', defaultValue: 5);
    final displayReviews = reviews.take(perPage).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: FontUtils.primaryFontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              if (totalReviews != null)
                Text(
                  '($totalReviews)',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 13,
                    color: AppColors.textColor50,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Review cards
          ...displayReviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] as num?)?.toDouble() ?? 0;
    final description = review['description'] as String? ?? '';
    final customer = review['customer'] as Map<String, dynamic>? ?? {};
    final firstName = customer['firstName'] as String? ?? '';
    final lastName = customer['lastName'] as String? ?? '';
    final name = '$firstName $lastName'.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withAlpha(50),
            child: Text(
              initial,
              style: FontUtils.primaryFontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + rating
                Row(
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Anonymous',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(5, (i) => Icon(
                      i < rating.round() ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 13,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
