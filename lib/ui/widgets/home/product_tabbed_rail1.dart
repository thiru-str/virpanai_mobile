import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

/// ProductTabbedRail1 — a horizontal product rail with a row of tab pills
/// (New / Popular / On Sale) above it. Selecting a tab is presentational only
/// (local state highlights the active pill); the rail shows the same items
/// regardless of tab. Each card is a shared [HomeMerchCompactCard] wired to
/// add-to-cart. Composed from the shared merch helpers so theming is inherited
/// (no hardcoded text colours).
class ProductTabbedRail1 extends StatefulWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductTabbedRail1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  State<ProductTabbedRail1> createState() => _ProductTabbedRail1State();
}

class _ProductTabbedRail1State extends State<ProductTabbedRail1> {
  static const _tabs = ['New', 'Popular', 'On Sale'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
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
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tab pills — local selection state, presentational.
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _TabPill(
                label: _tabs[i],
                selected: i == _selected,
                onTap: () => setState(() => _selected = i),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 384,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return HomeMerchCompactCard(
                  data: item,
                  onTap: () => RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? '',
                    layoutData: item,
                  ),
                  onCartQtyChanged: widget.onCartQtyChanged,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = cmsAccent(context, Colors.black);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? accent : cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent : Colors.black12,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FontUtils.primaryFontStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected
                ? cmsOn(accent)
                : cmsCardText(context, AppColors.textColor),
          ),
        ),
      ),
    );
  }
}
