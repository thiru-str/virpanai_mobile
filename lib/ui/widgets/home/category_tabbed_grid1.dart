import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryTabbedGrid1 — a row of tab pills built from the FIRST few category
// titles sits above a 3-column grid of the REMAINING categories rendered as
// rounded-square image tiles with a label. Selecting a tab is presentational:
// it only re-highlights the pill; the grid stays put. Categories only —
// no prices/ratings/cart.
class CategoryTabbedGrid1 extends StatefulWidget {
  final Content content;
  const CategoryTabbedGrid1({super.key, required this.content});

  @override
  State<CategoryTabbedGrid1> createState() => _CategoryTabbedGrid1State();
}

class _CategoryTabbedGrid1State extends State<CategoryTabbedGrid1> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    // First few titles become presentational tab pills; the rest fill the grid.
    final tabCount = items.length > 4 ? 4 : items.length;
    final tabs = items.take(tabCount).toList();
    final gridItems =
        items.length > tabCount ? items.sublist(tabCount) : items;

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
              ctaText: content.layoutRedirectTitle ?? '',
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _selectedTab;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = i),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected
                          ? cmsAccent(context, Colors.black)
                          : cmsCard(context, Colors.white),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      tabs[i].title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? cmsOn(cmsAccent(context, Colors.black))
                            : cmsCardText(context, AppColors.textColor),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              mainAxisExtent: 120,
            ),
            itemBuilder: (context, i) {
              final item = gridItems[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 88,
                        width: double.infinity,
                        color: cmsCard(context, AppColors.secondary),
                        child: merchImageOrFallback(
                          merchImage(item),
                          width: double.infinity,
                          height: 88,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cmsCardText(context, AppColors.textColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
