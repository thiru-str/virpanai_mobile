import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';

class Slider10 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const Slider10({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: backgroundDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? 'QUICK PICKS',
            ctaText: content.layoutRedirectTitle ?? '',
            onTap: content.redirectData == null
                ? null
                : () => RedirectUtils.handleContentRedirectViewAll(
                      context: context,
                      redirectData: content.redirectData!,
                    ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  HomeMerchCompactCard(
                    data: items[i],
                    onTap: () => RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content.layoutOption ?? '',
                      layoutData: items[i],
                    ),
                    onCartQtyChanged: onCartQtyChanged,
                  ),
                  if (i != items.length - 1) const SizedBox(width: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
