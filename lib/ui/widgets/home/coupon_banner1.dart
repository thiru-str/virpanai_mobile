import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// CouponBanner1 — a promo COUPON card with a dashed-border "ticket" look.
// Left side = layoutTitle (offer, maxLines 2) + layoutSubTitle (terms,
// maxLines 1). A dashed vertical perforation separates it from the right
// side: a distinct cmsAccent block showing a coupon CODE (derived from
// layoutRedirectTitle, default "SAVE20") + a small "Tap to copy" caption.
// The whole card taps through via the component's layout option/data.
class CouponBanner1 extends StatelessWidget {
  final Content content;
  const CouponBanner1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Special offer';
    final terms = content.layoutSubTitle ?? '';
    final rawCode = content.layoutRedirectTitle ?? '';
    final code = rawCode.trim().isEmpty
        ? 'SAVE20'
        : rawCode.trim().split(' ').where((p) => p.isNotEmpty).join().toUpperCase();

    final accent = cmsAccent(context, const Color(0xFFE0473C));
    final onAccent = cmsOn(accent);

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: accent.withValues(alpha: 0.55),
            radius: 18,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 128,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: offer + terms.
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      color: cmsCard(context, Colors.white),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'COUPON',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: cmsCardText(context, const Color(0xFF141414)),
                            ),
                          ),
                          if (terms.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              terms,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 11,
                                color: cmsCardText(
                                    context, const Color(0x99141414)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Dashed vertical perforation.
                  const _DashedDivider(),
                  // Right: accent coupon-code block.
                  Container(
                    width: 118,
                    height: double.infinity,
                    color: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: onAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded,
                                size: 12,
                                color: onAccent.withValues(alpha: 0.85)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Tap to copy',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: onAccent.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A vertical column of short dashes forming the ticket perforation.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.5,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          9,
          (_) => Container(
            width: 1.5,
            height: 6,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

// Strokes a dashed rounded-rectangle border around the child (ticket edge).
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(
          metric.extractPath(dist, next.clamp(0, metric.length)),
          paint,
        );
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
