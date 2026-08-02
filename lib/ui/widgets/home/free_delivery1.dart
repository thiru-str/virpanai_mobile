import 'package:flutter/material.dart';
import 'cms_text_color.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';

// FreeDelivery1 — slim free-delivery / min-order reassurance banner.
class FreeDelivery1 extends StatelessWidget {
  final Content content;
  const FreeDelivery1({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kFresh.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kFresh.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              height: 38, width: 38,
              decoration: BoxDecoration(color: kFresh, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content.layoutTitle?.isNotEmpty == true
                        ? content.layoutTitle!
                        : 'Free delivery over Rs 199',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: cmsCardText(context, AppColors.textColor)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content.layoutSubTitle?.isNotEmpty == true
                        ? content.layoutSubTitle!
                        : 'Delivered in 30 minutes or less',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 12, fontWeight: FontWeight.w400, color: cmsCardText(context, AppColors.textColor50)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
