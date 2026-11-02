import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';

class Item16 extends StatelessWidget {
  final Content content;

  const Item16({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    if (items.isEmpty) return const SizedBox.shrink();

    final featured = items.first;
    final rest = items.length > 1
        ? items.sublist(1, items.length > 3 ? 3 : items.length)
        : <LayoutDatum>[];

    return Container(
      decoration: backgroundDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeMerchSectionHeader(
            title: content.layoutTitle ?? '',
            subtitle: content.layoutSubTitle ?? 'DISCOVERY EDIT',
            ctaText: content.layoutRedirectTitle ?? '',
            onTap: content.redirectData == null
                ? null
                : () => RedirectUtils.handleContentRedirectViewAll(
                      context: context,
                      redirectData: content.redirectData!,
                    ),
          ),
          const SizedBox(height: 14),
          HomeMerchEditorialCard(
            data: featured,
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: featured,
            ),
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < rest.length; i++) ...[
                    HomeMerchCompactCard(
                      data: rest[i],
                      showButton: false,
                      onTap: () => RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption ?? '',
                        layoutData: rest[i],
                      ),
                    ),
                    if (i != rest.length - 1) const SizedBox(width: 14),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
