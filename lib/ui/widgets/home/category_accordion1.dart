import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryAccordion1 — an expandable accordion of parent categories. Each row is
// a tappable panel (thumb + title + chevron); tapping expands it (one open at a
// time, via AnimatedCrossFade) to reveal a Wrap of sub-category chips derived
// presentationally from other item titles. Tapping the thumb or a chip performs
// the redirect. Distinct from nested_list (which always shows every chip).
class CategoryAccordion1 extends StatefulWidget {
  final Content content;
  const CategoryAccordion1({super.key, required this.content});

  @override
  State<CategoryAccordion1> createState() => _CategoryAccordion1State();
}

class _CategoryAccordion1State extends State<CategoryAccordion1> {
  int _openIndex = 0; // one open at a time; -1 means all collapsed.

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
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
              ctaText: content.layoutRedirectTitle ?? '',
              onTap: () => RedirectUtils.handleContentRedirect(
                context: context,
                layoutOption: content.layoutOption ?? '',
                layoutData: items.first,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final item = items[i];
              final isOpen = _openIndex == i;
              // Derive presentational sub-category chips from other item titles.
              final chips = <String>[];
              for (var k = 1; k <= 5 && chips.length < 5; k++) {
                final t = items[(i + k) % items.length].title;
                if (t != null && t.trim().isNotEmpty) chips.add(t.trim());
              }
              return Container(
                decoration: BoxDecoration(
                  color: cmsPanel(context, Colors.white),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Parent header row — toggles the accordion.
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () =>
                          setState(() => _openIndex = isOpen ? -1 : i),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => RedirectUtils.handleContentRedirect(
                                context: context,
                                layoutOption: content.layoutOption ?? '',
                                layoutData: item,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  color: cmsCard(context, AppColors.secondary),
                                  child: merchImageOrFallback(
                                    merchImage(item),
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  item.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FontUtils.primaryFontStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        cmsCardText(context, AppColors.textColor),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: isOpen ? 0.5 : 0.0,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: cmsCardText(context, AppColors.textColor50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expandable sub-category chip panel.
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: isOpen
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: chips
                              .map(
                                (c) => GestureDetector(
                                  onTap: () =>
                                      RedirectUtils.handleContentRedirect(
                                    context: context,
                                    layoutOption: content.layoutOption ?? '',
                                    layoutData: item,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cmsCard(context, AppColors.secondary),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: Text(
                                      c,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FontUtils.primaryFontStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: cmsCardText(
                                            context, AppColors.textColor),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
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
