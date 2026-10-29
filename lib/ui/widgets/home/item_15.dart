import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';

class Item15 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const Item15({
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? 'PREMIUM SHELF',
            ctaText: content.layoutRedirectTitle ?? '',
            onTap: content.redirectData == null
                ? null
                : () => RedirectUtils.handleContentRedirectViewAll(
                      context: context,
                      redirectData: content.redirectData!,
                    ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: items.length > 4 ? 4 : items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              // Fixed cell height (width-independent) so the card's fixed-height
              // image + title + price + MRP + rating never overflow on narrow
              // phones — childAspectRatio coupled height to width and clipped.
              mainAxisExtent: 384,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return HomeMerchCompactCard(
                data: item,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                onCartQtyChanged: onCartQtyChanged,
              );
            },
          ),
        ],
      ),
    );
  }
}
