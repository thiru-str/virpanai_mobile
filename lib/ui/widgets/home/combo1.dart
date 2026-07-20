import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import 'homepage_merch_shared.dart';
import 'grocery_shared.dart';

// Combo1 — grocery combo / value pack (bundle of items at one price).
class Combo1 extends StatelessWidget {
  final Content content;
  const Combo1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = (content.layoutData ?? []).take(3).toList();
    if (items.length < 2) return const SizedBox.shrink();
    num total = 0;
    for (final it in items) {
      total += num.tryParse(merchSellingPrice(it).replaceAll(',', '')) ?? 0;
    }
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kInk.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 56,
                      width: 56,
                      child: merchImageOrFallback(merchImage(items[i]), fit: BoxFit.cover),
                    ),
                  ),
                  if (i != items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.add, size: 16, color: AppColors.textColor50),
                    ),
                ],
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Combo price',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textColor50),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyUtil.appendCurrency(total.toStringAsFixed(0)),
                      style: FontUtils.primaryFontStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kFresh, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        content.layoutRedirectTitle?.isNotEmpty == true
                            ? content.layoutRedirectTitle!
                            : 'Add combo',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
