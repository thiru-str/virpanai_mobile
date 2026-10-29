import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';

// PaymentOffersBanner1 — a bank / payment offers strip: a short heading line
// (layoutTitle) followed by a horizontal rail of 3–4 fixed offer chips, each a
// leading payment icon + a short 2-line offer label. Chips use cmsCard so they
// read as tappable tiles. The whole banner taps through via the component's
// layout option/data. Distinct from the promo / trust / offer-grid banners
// (payment-method framing, horizontally scrolling chips).
class PaymentOffersBanner1 extends StatelessWidget {
  final Content content;
  const PaymentOffersBanner1({super.key, required this.content});

  static const List<_PayOffer> _offers = [
    _PayOffer(icon: Icons.credit_card, label: '10% off on HDFC'),
    _PayOffer(icon: Icons.account_balance, label: 'No Cost EMI'),
    _PayOffer(icon: Icons.qr_code, label: '5% UPI cashback'),
    _PayOffer(icon: Icons.savings, label: 'Extra Rs 100 off'),
  ];

  @override
  Widget build(BuildContext context) {
    final panel = cmsPanel(context, const Color(0xFFF1EEFB));
    final accent = cmsAccent(context, const Color(0xFF8E6CEF));
    final title = content.layoutTitle?.isNotEmpty == true
        ? content.layoutTitle!
        : 'Bank & payment offers';

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cmsText(context, const Color(0xFF1A1A1A)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _offers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _OfferChip(
                    offer: _offers[i],
                    accent: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayOffer {
  final IconData icon;
  final String label;
  const _PayOffer({required this.icon, required this.label});
}

class _OfferChip extends StatelessWidget {
  final _PayOffer offer;
  final Color accent;
  const _OfferChip({required this.offer, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cmsCard(context, Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(offer.icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              offer.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, const Color(0xFF1A1A1A)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
