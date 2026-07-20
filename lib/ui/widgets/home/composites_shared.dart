import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/currency_util.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// Shared building blocks for rich, composite (multi-element) components that
// combine collection / list / spotlight / category patterns in one section.

String _metaLine(String rating, String meta) =>
    [if (rating.isNotEmpty) rating, if (meta.isNotEmpty) meta].join(' · ');

// Horizontal list row: thumb + title + meta + price + ADD, with optional rank.
class ListRow extends StatelessWidget {
  final LayoutDatum data;
  final int? rank;
  final bool showAdd;
  const ListRow({super.key, required this.data, this.rank, this.showAdd = true});

  @override
  Widget build(BuildContext context) {
    final selling = merchSellingPrice(data);
    final meta = merchSubtitle(data);
    final rating = merchRating(data);
    return Row(
      children: [
        if (rank != null) ...[
          SizedBox(
            width: 22,
            child: Text('$rank',
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textColor50)),
          ),
          const SizedBox(width: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: const SizedBox(height: 56, width: 56, child: ImageFallbackWidget(fit: BoxFit.cover)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data.title ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColor)),
              if (_metaLine(rating, meta).isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(children: [
                  if (rating.isNotEmpty) ...[
                    const Icon(Icons.star, size: 11, color: Color(0xFFF5A623)),
                    const SizedBox(width: 2),
                    Text(rating,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColor50)),
                    if (meta.isNotEmpty)
                      Text('  ·  ',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
                  ],
                  if (meta.isNotEmpty)
                    Flexible(
                      child: Text(meta,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textColor50)),
                    ),
                ]),
              ],
              if (selling != '0') ...[
                const SizedBox(height: 3),
                Text(CurrencyUtil.appendCurrency(selling),
                  style: FontUtils.primaryFontStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textColor)),
              ],
            ],
          ),
        ),
        if (showAdd) ...[
          const SizedBox(width: 8),
          const GroceryAddButton(compact: true),
        ],
      ],
    );
  }
}

// Story-style circular collection cover with a gradient ring + label.
class StoryCircle extends StatelessWidget {
  final String label;
  final Color color;
  const StoryCircle({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 68, width: 68,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.4)]),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const ClipOval(child: ImageFallbackWidget(fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            style: FontUtils.primaryFontStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColor)),
        ],
      ),
    );
  }
}

// Compact eyebrow + title header used inside composite cards.
Widget compositeHeader(String title, String subtitle) {
  return HomeMerchSectionHeader(title: title, subtitle: subtitle);
}
