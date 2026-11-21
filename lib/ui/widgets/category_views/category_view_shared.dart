import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/product_page.dart';
import 'package:waioz/ui/sub_category_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/store_image.dart';

/// The store-wide layout of the Categories tab, chosen in the admin app
/// Global Settings ("Category Page", saved as the `categoryView` setting and
/// served in /public/details as `theme.categoryView`).
///
///   categoryView1  Grid: two columns of cover cards (the original page)
///   categoryView2  Side rail: categories down the left, sub-categories as a
///                  grid on the right (quick-commerce)
///   categoryView3  Sections: every category as a heading over a grid of its
///                  sub-categories, one long scroll
///   categoryView4  List: full-width rows that open to show sub-categories
///   categoryView5  Tabs: category tabs across the top, swipe between their
///                  sub-category grids
///
/// Anything unknown or empty falls back to the grid, so a store that never
/// picks a layout keeps the page it had.
enum CategoryView {
  categoryView1,
  categoryView2,
  categoryView3,
  categoryView4,
  categoryView5,
}

CategoryView categoryViewFrom(String? value) {
  final v = (value ?? '').trim();
  for (final view in CategoryView.values) {
    if (view.name == v) return view;
  }
  return CategoryView.categoryView1;
}

/// The picture for a category tile: its own image, else the first image found
/// among its sub-categories (depth-first). Grouping categories (SAREES › Silk,
/// Tussar…) usually have no photo of their own, while their children do.
String categoryCoverImage(ProductCategory category) {
  final own = (category.image ?? '').trim();
  if (own.isNotEmpty) return own;
  for (final child in category.categoryChildren ?? const <ProductCategory>[]) {
    final found = categoryCoverImage(child);
    if (found.isNotEmpty) return found;
  }
  return '';
}

List<ProductCategory> categoryChildrenOf(ProductCategory c) =>
    (c.categoryChildren ?? const <ProductCategory>[])
        .where((x) => (x.id ?? '').isNotEmpty)
        .toList();

/// The category and every category under it, so "All" lists the products
/// filed under any of its sub-categories too.
List<String> categoryTreeIds(ProductCategory c) => [
      if ((c.id ?? '').isNotEmpty) c.id!,
      for (final child in categoryChildrenOf(c)) ...categoryTreeIds(child),
    ];

/// Opens a category: its sub-categories when it has any, else its products.
void openCategory(BuildContext context, ProductCategory c) {
  final children = categoryChildrenOf(c);
  if (children.isNotEmpty) {
    PageRouteUtils.pushWithFade(
      context,
      SubCategoryPage(categoryTitle: c.name ?? '', productCategory: children),
    );
  } else {
    PageRouteUtils.pushWithFade(context, ProductPage(categoryId: c.id ?? ''));
  }
}

/// Opens the products of a category and everything under it.
void openCategoryProducts(BuildContext context, ProductCategory c) {
  PageRouteUtils.pushWithFade(
    context,
    ProductPage(categoryId: categoryTreeIds(c).join(',')),
  );
}

/// Shared colours. Neutral surfaces so any store's category photography
/// carries the colour; the store's primary marks the selection only.
class CategoryViewColors {
  static const Color ink = AppColors.textColor;
  static const Color muted = Color(0xFF6B6F76);
  static const Color tile = Color(0xFFF3F4F6);
  static const Color rail = Color(0xFFF5F6F8);
  static const Color hairline = Color(0xFFE7E8EC);
  static Color get accent => AppColors.primary;

  /// The accent when it is dark enough to read as text on white, else ink:
  /// a pale primary (yellow, mint) still marks the bar, not the label.
  static Color get accentText =>
      accent.computeLuminance() < 0.3 ? accent : ink;
}

/// A category picture filling its box, with the store's no-image mark when
/// the category has no photo.
class CategoryPicture extends StatelessWidget {
  final String url;
  final double radius;
  final Color background;
  const CategoryPicture({
    super.key,
    required this.url,
    this.radius = 12,
    this.background = CategoryViewColors.tile,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: background,
        child: SizedBox.expand(
          child: LayoutBuilder(builder: (context, box) {
            final missing = ImageFallbackWidget(
                w: box.maxWidth, h: box.maxHeight, fill: true);
            if (url.isEmpty) return missing;
            return StoreImage(
              imageUrl: url,
              width: box.maxWidth,
              height: box.maxHeight,
              fit: BoxFit.cover,
              placeholder: (_, __) => ColoredBox(color: background),
              errorWidget: (_, __, ___) => missing,
            );
          }),
        ),
      ),
    );
  }
}

/// Square picture with a two-line name under it: the sub-category tile every
/// layout shares.
class CategoryTile extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;
  final double fontSize;
  const CategoryTile({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
    this.fontSize = 12,
  });

  /// Height of the label block under the square, at the reader's text size.
  static double labelHeight(BuildContext context, double fontSize) =>
      8 + MediaQuery.textScalerOf(context).scale(fontSize) * 1.3 * 2 + 2;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(aspectRatio: 1, child: CategoryPicture(url: imageUrl)),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: CategoryViewColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A grid of [CategoryTile]s sized from the available width and text size,
/// so labels never clip. Not scrollable itself: it sits inside a scroll.
class CategoryTileGrid extends StatelessWidget {
  final List<ProductCategory> categories;
  final int columns;
  final double spacing;
  final double fontSize;

  /// An "All" tile first, opening every product under [allOf].
  final ProductCategory? allOf;
  const CategoryTileGrid({
    super.key,
    required this.categories,
    this.columns = 3,
    this.spacing = 12,
    this.fontSize = 12,
    this.allOf,
  });

  @override
  Widget build(BuildContext context) {
    final all = allOf;
    final tiles = <Widget>[
      if (all != null)
        CategoryTile(
          imageUrl: categoryCoverImage(all),
          label: 'All',
          fontSize: fontSize,
          onTap: () => openCategoryProducts(context, all),
        ),
      for (final c in categories)
        CategoryTile(
          imageUrl: categoryCoverImage(c),
          label: c.name ?? '',
          fontSize: fontSize,
          onTap: () => openCategory(context, c),
        ),
    ];
    return LayoutBuilder(builder: (context, box) {
      // fewer columns when a tile would be too narrow for its label (small
      // phones, large text), so words wrap whole instead of splitting
      final minTile = MediaQuery.textScalerOf(context).scale(fontSize) * 6.2;
      final fit = ((box.maxWidth + spacing) / (minTile + spacing)).floor();
      final cols = fit.clamp(2, columns);
      final w = (box.maxWidth - spacing * (cols - 1)) / cols;
      return GridView.custom(
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: spacing,
          mainAxisSpacing: 16,
          mainAxisExtent: w + CategoryTile.labelHeight(context, fontSize),
        ),
        childrenDelegate: SliverChildListDelegate(tiles),
      );
    });
  }
}

/// Category name over a "See all" link: the heading the section and tab
/// layouts share.
class CategoryHeading extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const CategoryHeading({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: CategoryViewColors.ink,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: CategoryViewColors.accentText,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(48, 40),
            ),
            // style on the Text, not the button: a button textStyle replaces
            // the theme's, dropping the store font
            child: const Text('See all',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}
