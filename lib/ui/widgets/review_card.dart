import 'package:flutter/material.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../utility/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String reviewText;
  final double rating;
  final String timestamp;

  const ReviewCard({
    Key? key,
    required this.profileImageUrl,
    required this.name,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE5E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                  child: Container(
                    child: Center(
                      child: Text(
                          name.isNotEmpty ? name.substring(0,1) : "C",
                          style: FontUtils.primaryFontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                      ),
                    ),
                  )
                /*backgroundImage: NetworkImage(profileImageUrl),*/
              ),
              const SizedBox(width: 12),
              // Name and Rating
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: UiTypography.cardTitle(color: Colors.black87)
                          .copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.primary,
                            size: 16,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review Text
          Text(
            reviewText,
            style: UiTypography.cardSubtitle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          // Timestamp
          Text(
            timestamp,
            style: UiTypography.cardMeta(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
