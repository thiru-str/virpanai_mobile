import 'package:flutter/material.dart';
import 'cms_text_color.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';

// PharmacyBanner1 — pharmacy: upload prescription / order medicines band.
class PharmacyBanner1 extends StatelessWidget {
  final Content content;
  const PharmacyBanner1({super.key, required this.content});

  static const _teal = Color(0xFF0E9C95);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _teal.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _teal.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            Container(
              height: 46, width: 46,
              decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.medical_information, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content.layoutTitle?.isNotEmpty == true
                        ? content.layoutTitle!
                        : 'Order Medicines',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: cmsCardText(context, AppColors.textColor)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content.layoutSubTitle?.isNotEmpty == true
                        ? content.layoutSubTitle!
                        : 'Upload prescription • Up to 25% off',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 12, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: cmsAccent(context, _teal), borderRadius: BorderRadius.circular(10)),
              child: Text(
                content.layoutRedirectTitle?.isNotEmpty == true
                    ? content.layoutRedirectTitle!
                    : 'Upload',
                style: FontUtils.primaryFontStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: cmsOn(cmsAccent(context, _teal))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
