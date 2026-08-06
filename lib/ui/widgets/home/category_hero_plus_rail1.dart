import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// CategoryHeroPlusRail1 — one LARGE hero category card (the first item: a
// rounded ~180h image with a bottom scrim and big title overlay) on top, then a
// horizontal rail of small rounded thumbs (the remaining items, ~72 wide) with
// labels below. Combines a feature card with a mini rail.
class CategoryHeroPlusRail1 extends StatelessWidget {
  final Content content;
  const CategoryHeroPlusRail1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final hero = items.first;
    final rest = items.length > 1 ? items.sublist(1) : const <LayoutDatum>[];

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
          // Hero card.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: hero,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    merchImageOrFallback(
                      merchImage(hero),
                      width: double.infinity,
                      height: 180,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xCC000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Text(
                        hero.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: rest.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final item = rest[i];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: content.layoutOption ?? '',
                      layoutData: item,
                    ),
                    child: SizedBox(
                      width: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: merchImageOrFallback(
                              merchImage(item),
                              width: 72,
                              height: 72,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cmsText(context, AppColors.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
