import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

// BogoBanner1 — a "Buy One Get One" offer strip. Left = an accent column with
// a big "BOGO" label + the offer text (layoutTitle). Right = a Row of the
// first two layoutData product thumbnails with a "+" between and a small
// "Add to cart to unlock" caption. Guards when there are no items. The whole
// strip taps through on the first item.
class BogoBanner1 extends StatelessWidget {
  final Content content;
  const BogoBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final thumbs = items.length > 2 ? items.sublist(0, 2) : items;

    final offer = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Buy one, get one free';
    final caption = content.layoutSubTitle?.isNotEmpty == true
        ? content.layoutSubTitle!
        : 'Add to cart to unlock';

    final accent = cmsAccent(context, const Color(0xFF7A3FF2));
    final onAccent = cmsOn(accent);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: items.first,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left accent label column.
                Container(
                  width: 132,
                  height: double.infinity,
                  color: accent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'BOGO',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: onAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: onAccent.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: two thumbnails with a "+" between + caption.
                Expanded(
                  child: Container(
                    height: double.infinity,
                    color: cmsCard(context, Colors.white),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _Thumb(url: merchImage(thumbs.first)),
                            _PlusBadge(color: accent, onColor: onAccent),
                            if (thumbs.length > 1)
                              _Thumb(url: merchImage(thumbs[1]))
                            else
                              _Thumb(url: merchImage(thumbs.first)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_shopping_cart_rounded,
                                size: 13,
                                color: cmsCardText(
                                    context, const Color(0x99141414))),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cmsCardText(
                                      context, const Color(0x99141414)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  const _Thumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 62,
        width: 62,
        child: merchImageOrFallback(url, fit: BoxFit.cover),
      ),
    );
  }
}

class _PlusBadge extends StatelessWidget {
  final Color color;
  final Color onColor;
  const _PlusBadge({required this.color, required this.onColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.add_rounded, size: 16, color: onColor),
    );
  }
}
