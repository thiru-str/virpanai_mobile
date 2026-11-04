import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';

// CustomFaqAccordion1 — a vertical FAQ accordion of CUSTOM content. Each row is
// a question (title) with a trailing +/- toggle; tapping expands to reveal the
// answer (featureText/subTitle, maxLines 5). One row open at a time, tracked in
// setState. cmsPanel row backgrounds, rounded. No images. Editorial — NOT
// products.
class CustomFaqAccordion1 extends StatefulWidget {
  final Content content;
  const CustomFaqAccordion1({super.key, required this.content});

  @override
  State<CustomFaqAccordion1> createState() => _CustomFaqAccordion1State();
}

class _CustomFaqAccordion1State extends State<CustomFaqAccordion1> {
  int _openIndex = -1;

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
          if ((content.layoutTitle ?? '').isNotEmpty ||
              (content.layoutSubTitle ?? '').isNotEmpty) ...[
            HomeMerchSectionHeader(
              title: content.layoutTitle ?? '',
              subtitle: content.layoutSubTitle ?? '',
            ),
            const SizedBox(height: 14),
          ],
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final answer = merchSubtitle(item);
              final isOpen = _openIndex == index;
              final textColor = cmsCardText(context, AppColors.textColor);
              return Container(
                decoration: BoxDecoration(
                  color: cmsPanel(context, AppColors.secondary),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(
                            () => _openIndex = isOpen ? -1 : index),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: FontUtils.primaryFontStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isOpen
                                    ? Icons.remove_rounded
                                    : Icons.add_rounded,
                                size: 22,
                                color: cmsAccent(context, AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            answer,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 13,
                              color: cmsCardText(
                                  context, AppColors.textColor50),
                            ),
                          ),
                        ),
                        crossFadeState: isOpen && answer.isNotEmpty
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
