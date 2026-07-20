import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'homepage_merch_shared.dart';

// HomeCollection1 — home & living room collections (large image cards).
class HomeCollection1 extends StatelessWidget {
  final Content content;
  const HomeCollection1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(2).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? '',
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            if (i != 0) const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  const AspectRatio(
                    aspectRatio: 16 / 10,
                    child: ImageFallbackWidget(fit: BoxFit.cover),
                  ),
                  Positioned(
                    left: 16, bottom: 16, right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          items[i].title ?? '',
                          style: FontUtils.primaryFontStyle(
                            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textColor),
                        ),
                        if ((items[i].featureText ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              items[i].featureText!,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColor50),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
