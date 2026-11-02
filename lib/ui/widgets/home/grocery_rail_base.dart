import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_utils.dart';
import 'homepage_merch_shared.dart';
import 'grocery_shared.dart';

// Shared horizontal grocery rail used by fresh-meats / produce / deals / buy-again.
class GroceryRail extends StatelessWidget {
  final Content content;
  const GroceryRail({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
              ctaText: content.layoutRedirectTitle ?? '',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 246,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) => GroceryTile(data: items[i], width: 132),
            ),
          ),
        ],
      ),
    );
  }
}

class FreshMeats1 extends StatelessWidget {
  final Content content;
  const FreshMeats1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => GroceryRail(content: content);
}

class FreshProduce1 extends StatelessWidget {
  final Content content;
  const FreshProduce1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => GroceryRail(content: content);
}

class GroceryDeal1 extends StatelessWidget {
  final Content content;
  const GroceryDeal1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => GroceryRail(content: content);
}

class BuyAgain1 extends StatelessWidget {
  final Content content;
  const BuyAgain1({super.key, required this.content});
  @override
  Widget build(BuildContext context) => GroceryRail(content: content);
}
