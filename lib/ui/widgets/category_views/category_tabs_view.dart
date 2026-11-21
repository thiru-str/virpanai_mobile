import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_views/category_view_shared.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';

/// categoryView5: category tabs (picture over name) across the top, and the
/// selected one's sub-categories as a grid below. Swipe sideways to move
/// between categories. A category without sub-categories shows its "All"
/// tile.
class CategoryTabsView extends StatefulWidget {
  final List<ProductCategory> categories;
  const CategoryTabsView({super.key, required this.categories});

  @override
  State<CategoryTabsView> createState() => _CategoryTabsViewState();
}

class _CategoryTabsViewState extends State<CategoryTabsView> {
  final _pages = PageController();
  final _tabs = ScrollController();
  int _selected = 0;

  static const double _tabWidth = 80;

  @override
  void dispose() {
    _pages.dispose();
    _tabs.dispose();
    super.dispose();
  }

  bool get _still => MediaQuery.of(context).disableAnimations;

  void _go(int i) {
    setState(() => _selected = i);
    if (_still) {
      _pages.jumpToPage(i);
    } else {
      _pages.animateToPage(i,
          duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  void _reveal(int i) {
    if (!_tabs.hasClients) return;
    final view = _tabs.position.viewportDimension;
    final target = (16 + i * _tabWidth + _tabWidth / 2 - view / 2)
        .clamp(0.0, _tabs.position.maxScrollExtent);
    if (_still) {
      _tabs.jumpTo(target);
    } else {
      _tabs.animateTo(target,
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    final text = MediaQuery.textScalerOf(context);
    final tabHeight = 12 + 56 + 6 + text.scale(12) * 1.25 * 2 + 12;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: tabHeight,
            child: ListView.builder(
              controller: _tabs,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cats.length,
              itemBuilder: (context, i) => _Tab(
                width: _tabWidth,
                category: cats[i],
                selected: i == _selected,
                onTap: () => _go(i),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: CategoryViewColors.hairline),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: cats.length,
              onPageChanged: (i) {
                setState(() => _selected = i);
                _reveal(i);
              },
              itemBuilder: (context, i) {
                final c = cats[i];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                      16, 12, 16, FloatingCart.clearance),
                  children: [
                    CategoryHeading(
                      title: c.name ?? '',
                      onSeeAll: categoryChildrenOf(c).isEmpty
                          ? null
                          : () => openCategoryProducts(context, c),
                    ),
                    const SizedBox(height: 12),
                    CategoryTileGrid(
                      categories: categoryChildrenOf(c),
                      allOf: categoryChildrenOf(c).isEmpty ? c : null,
                      columns: 3,
                      spacing: 12,
                      fontSize: 12.5,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final double width;
  final ProductCategory category;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({
    required this.width,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = CategoryViewColors.accent;
    return Semantics(
      button: true,
      selected: selected,
      label: category.name,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? accent : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: CategoryPicture(
                          url: categoryCoverImage(category),
                          radius: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? CategoryViewColors.accentText
                            : CategoryViewColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2)),
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
