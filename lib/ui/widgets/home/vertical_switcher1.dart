import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import 'homepage_merch_shared.dart';
import 'verticals_shared.dart';

// VerticalSwitcher1 — super-app style shortcuts that combine collections from
// different verticals (grocery, food, pharmacy, electronics, fashion, beauty).
class VerticalSwitcher1 extends StatelessWidget {
  final Content content;
  const VerticalSwitcher1({super.key, required this.content});

  static const _palette = [
    [Icons.shopping_basket, 0xFF1BA672],
    [Icons.restaurant, 0xFFEF6C1A],
    [Icons.medical_services, 0xFF0E9C95],
    [Icons.devices_other, 0xFF3B5BDB],
    [Icons.checkroom, 0xFF8E6CEF],
    [Icons.spa, 0xFFD6336C],
  ];

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((content.layoutTitle ?? '').isNotEmpty) ...[
            HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
            ),
            const SizedBox(height: 12),
          ],
          GridView.builder(
            itemCount: items.length > 6 ? 6 : items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 124,
            ),
            itemBuilder: (context, i) {
              final p = _palette[i % _palette.length];
              return VerticalTile(
                label: items[i].title ?? '',
                subLabel: items[i].featureText ?? '',
                icon: p[0] as IconData,
                color: Color(p[1] as int),
              );
            },
          ),
        ],
      ),
    );
  }
}
