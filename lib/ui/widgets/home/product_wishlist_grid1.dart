import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/currency_util.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/redirect_utils.dart';
import 'cms_text_color.dart';
import 'homepage_merch_shared.dart';
import 'product_cards_shared.dart';

/// ProductWishlistGrid1 — a native 2-column grid where each tile carries a
/// Heart toggle (saved / not-saved) over the image, then title, price and a
/// small ADD. The heart keeps local UI state via the private [_WishTile]
/// StatefulWidget, while add-to-cart, redirection and theming reuse the shared
/// merch/cart helpers so behaviour matches the other product widgets.
class ProductWishlistGrid1 extends StatelessWidget {
  final Content content;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const ProductWishlistGrid1({
    super.key,
    required this.content,
    this.onCartQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Width-independent cell height for the image + heart, title,
              // price and ADD row — generous so nothing overflows on narrow
              // phones.
              mainAxisExtent: 250,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _WishTile(
                data: item,
                onTap: () => RedirectUtils.handleContentRedirect(
                  context: context,
                  layoutOption: content.layoutOption ?? '',
                  layoutData: item,
                ),
                onCartQtyChanged: onCartQtyChanged,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WishTile extends StatefulWidget {
  final LayoutDatum data;
  final VoidCallback onTap;
  final void Function(int delta, String variantId)? onCartQtyChanged;

  const _WishTile({
    required this.data,
    required this.onTap,
    this.onCartQtyChanged,
  });

  @override
  State<_WishTile> createState() => _WishTileState();
}

class _WishTileState extends State<_WishTile> {
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final image = merchImage(data);
    final sellingPrice = merchSellingPrice(data);
    final originalPrice = merchOriginalPrice(data);
    final hasDiscount = originalPrice != '0' && originalPrice != sellingPrice;
    final variantId = variantIdOf(data);
    final accent = cmsAccent(context, Colors.black);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cmsCard(context, Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 132,
                    width: double.infinity,
                    color: AppColors.secondary,
                    child: merchImageOrFallback(
                      image,
                      fit: BoxFit.cover,
                      height: 132,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: GestureDetector(
                    onTap: () => setState(() => saved = !saved),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: cmsCard(context, Colors.white),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                        size: 17,
                        color: saved
                            ? accent
                            : cmsCardText(context, AppColors.textColor50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyUtil.appendCurrency(sellingPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: cmsCardText(context, AppColors.textColor),
                        ),
                      ),
                      if (hasDiscount)
                        Text(
                          CurrencyUtil.appendCurrency(originalPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 11,
                            color: cmsCardText(context, AppColors.textColor50),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (variantId.isNotEmpty && widget.onCartQtyChanged != null)
                  AddStepper(
                    count: cartQtyOf(data),
                    accent: accent,
                    onInc: () => widget.onCartQtyChanged!.call(1, variantId),
                    onDec: () => widget.onCartQtyChanged!.call(-1, variantId),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
