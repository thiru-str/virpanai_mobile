import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/currency_util.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';

/// Shared building blocks for the marketplace list components (sliders, banners,
/// collection lists — Slider50+, Banner8+, Collection3+). Keeps each component
/// widget thin and visually consistent, mirroring the web `RailCard` family.
typedef LcCartQtyChanged = void Function(
    int delta, LayoutDatum layoutData, int currentQty, String? currentLineItemId);

BoxDecoration? lcBackground(Content content) =>
    AppUtils.buildLayoutBackground(content);

void lcTap(BuildContext context, Content content, LayoutDatum item) {
  RedirectUtils.handleContentRedirect(
    context: context,
    layoutOption: content.layoutOption ?? '',
    layoutData: item,
  );
}

bool lcHasDiscount(LayoutDatum d) =>
    (d.prices?.originalPrice ?? '').isNotEmpty &&
    (d.prices?.originalPrice ?? '') != (d.prices?.sellingPrice ?? '');

Widget lcImage(String? url, {double? h, double? w, BoxFit fit = BoxFit.cover}) {
  if ((url ?? '').isEmpty) {
    return ImageFallbackWidget(h: h, w: w, fit: BoxFit.contain);
  }
  return Image(
    image: CachedNetworkImageProvider(Uri.encodeFull(url!)),
    height: h,
    width: w,
    fit: fit,
    errorBuilder: (_, __, ___) =>
        ImageFallbackWidget(h: h, w: w, fit: BoxFit.contain),
  );
}

/// Section header: title + optional subtitle + optional "view all".
Widget lcHeader(BuildContext context, Content content, {bool center = false}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                content.layoutTitle ?? '',
                maxLines: 2,
                textAlign: center ? TextAlign.center : TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.secondaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor),
              ),
              if ((content.layoutSubTitle ?? '').isNotEmpty)
                Text(
                  content.layoutSubTitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                      fontSize: 12,
                      color: AppColors.textColor.withOpacity(0.55)),
                ),
            ],
          ),
        ),
        if (!center && (content.layoutRedirectTitle ?? '').isNotEmpty)
          GestureDetector(
            onTap: () {
              if (content.redirectData == null) return;
              RedirectUtils.handleContentRedirectViewAll(
                  context: context, redirectData: content.redirectData!);
            },
            child: Text(
              content.layoutRedirectTitle!,
              style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor),
            ),
          ),
      ],
    ),
  );
}

Widget lcPrice(LayoutDatum d, {bool light = false}) {
  final base = light ? Colors.white : AppColors.textColor;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Flexible(
        child: Text(
          CurrencyUtil.appendCurrency(d.prices?.sellingPrice ?? '0'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FontUtils.primaryFontStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: base),
        ),
      ),
      if (lcHasDiscount(d)) ...[
        const SizedBox(width: 6),
        Text(
          CurrencyUtil.appendCurrency(d.prices?.originalPrice ?? '0'),
          style: FontUtils.primaryFontStyle(
              fontSize: 12,
              color: base.withOpacity(0.45),
              decoration: TextDecoration.lineThrough),
        ),
      ],
    ],
  );
}

Widget _badge(String text, {Color bg = Colors.black, Color fg = Colors.white}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: FontUtils.primaryFontStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );

/// Product card used across the rails/grids.
class LcProductCard extends StatelessWidget {
  final LayoutDatum item;
  final VoidCallback onTap;
  final double width; // ignored when [grid] is true
  final double imageHeight;
  final bool circular;
  final bool grid;
  final int? rank;
  const LcProductCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 172,
    this.imageHeight = 150,
    this.circular = false,
    this.grid = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final img = ClipRRect(
      borderRadius: BorderRadius.circular(circular ? 200 : 14),
      child: SizedBox(
        height: circular ? width : imageHeight,
        width: circular ? width : double.infinity,
        child: lcImage(item.image,
            h: circular ? width : imageHeight,
            w: circular ? width : double.infinity),
      ),
    );
    final content = Column(
      crossAxisAlignment:
          circular ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Stack(children: [
          img,
          if (rank != null)
            Positioned(
                left: 6,
                top: 6,
                child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.black,
                    child: Text('$rank',
                        style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)))),
          if (rank == null && (item.salesText ?? '').isNotEmpty)
            Positioned(right: 6, top: 6, child: _badge(item.salesText!)),
        ]),
        const SizedBox(height: 8),
        Text(item.title ?? '',
            maxLines: 1,
            textAlign: circular ? TextAlign.center : TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor)),
        const SizedBox(height: 4),
        lcPrice(item),
      ],
    );
    return GestureDetector(
      onTap: onTap,
      child: grid ? content : SizedBox(width: width, child: content),
    );
  }
}

/// Tall poster card with title & price laid over the image.
class LcPosterCard extends StatelessWidget {
  final LayoutDatum item;
  final VoidCallback onTap;
  final double width;
  final double height;
  const LcPosterCard(
      {super.key,
      required this.item,
      required this.onTap,
      this.width = 200,
      this.height = 270});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(fit: StackFit.expand, children: [
            lcImage(item.image, h: height, w: width),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  lcPrice(item, light: true),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Collection cover card (image with an overlaid title).
class LcCollectionCard extends StatelessWidget {
  final LayoutDatum item;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final bool circular;
  const LcCollectionCard(
      {super.key,
      required this.item,
      required this.onTap,
      this.width,
      this.height = 150,
      this.circular = false});
  @override
  Widget build(BuildContext context) {
    if (circular) {
      final d = width ?? 96;
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: d,
          child: Column(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: SizedBox(
                    height: d, width: d, child: lcImage(item.image, h: d, w: d))),
            const SizedBox(height: 6),
            Text(item.title ?? '',
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor)),
          ]),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(fit: StackFit.expand, children: [
            lcImage(item.image, h: height, w: width),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.secondaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  if ((item.featureText ?? '').isNotEmpty)
                    Text(item.featureText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Collection list row (thumbnail + name + description).
class LcCollectionRow extends StatelessWidget {
  final LayoutDatum item;
  final VoidCallback onTap;
  const LcCollectionRow({super.key, required this.item, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                  height: 60,
                  width: 60,
                  child: lcImage(item.image, h: 60, w: 60))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor)),
                if ((item.featureText ?? '').isNotEmpty)
                  Text(item.featureText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          color: AppColors.textColor.withOpacity(0.55))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textColor.withOpacity(0.5)),
        ]),
      ),
    );
  }
}

/// A horizontal rail wrapper.
Widget lcRail(List<Widget> children) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(width: 14),
        ],
      ]),
    );

/// A responsive product/collection grid.
Widget lcGrid(List<Widget> children, {int cols = 2, double ratio = 0.72}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: cols,
        childAspectRatio: ratio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      ),
    );

/// Standard section shell (background + vertical padding + header + body).
class LcSection extends StatelessWidget {
  final Content content;
  final Widget child;
  final bool centerHeader;
  const LcSection(
      {super.key,
      required this.content,
      required this.child,
      this.centerHeader = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: lcBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          lcHeader(context, content, center: centerHeader),
          child,
        ],
      ),
    );
  }
}
