import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// TrustStripBanner1 — a full-width reassurance strip: a Row of three equal
// Expanded cells, each an icon above a short 2-line label. The labels are a
// fixed reassurance list (Free Shipping / Secure Payment / Easy Returns), each
// paired with a fixed icon. Sits on a cmsPanel surface. No CTA — the whole
// strip taps through to the component's content redirect (trivial). Distinct
// from the promo / offer banners (informational, three symmetric cells).
class TrustStripBanner1 extends StatelessWidget {
  final Content content;
  const TrustStripBanner1({super.key, required this.content});

  static const List<_TrustItem> _items = [
    _TrustItem(icon: Icons.local_shipping, label: 'Free Shipping'),
    _TrustItem(icon: Icons.verified_user, label: 'Secure Payment'),
    _TrustItem(icon: Icons.autorenew, label: 'Easy Returns'),
  ];

  @override
  Widget build(BuildContext context) {
    final panel = cmsPanel(context, const Color(0xFFF1EEFB));
    final accent = cmsAccent(context, const Color(0xFF8E6CEF));
    final labelColor = cmsText(context, const Color(0xFF1A1A1A));

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => RedirectUtils.handleContentRedirect(
          context: context,
          layoutOption: content.layoutOption ?? '',
          layoutData: content.layoutData?.isNotEmpty == true
              ? content.layoutData!.first
              : LayoutDatum(),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in _items)
                Expanded(
                  child: _TrustCell(
                    item: item,
                    accent: accent,
                    labelColor: labelColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustItem {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});
}

class _TrustCell extends StatelessWidget {
  final _TrustItem item;
  final Color accent;
  final Color labelColor;
  const _TrustCell({
    required this.item,
    required this.accent,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 20, color: accent),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
