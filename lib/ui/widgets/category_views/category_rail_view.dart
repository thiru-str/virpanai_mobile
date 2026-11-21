import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_views/category_view_shared.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';

/// categoryView2: the quick-commerce layout. Categories run down a narrow rail
/// on the left; the right side shows the selected one's sub-categories as a
/// grid, led by an "All" tile. A category with no sub-categories shows just
/// its "All" tile.
class CategoryRailView extends StatefulWidget {
  final List<ProductCategory> categories;
  const CategoryRailView({super.key, required this.categories});

  @override
  State<CategoryRailView> createState() => _CategoryRailViewState();
}

class _CategoryRailViewState extends State<CategoryRailView> {
  static const double _railWidth = 88;
  int _selected = 0;
  final _content = ScrollController();

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == _selected) return;
    setState(() => _selected = i);
    if (_content.hasClients) _content.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    final index = _selected.clamp(0, cats.length - 1);
    final current = cats[index];
    final children = categoryChildrenOf(current);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: _railWidth,
          color: CategoryViewColors.rail,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: FloatingCart.clearance),
            itemCount: cats.length,
            itemBuilder: (context, i) => _RailItem(
              category: cats[i],
              selected: i == index,
              onTap: () => _select(i),
            ),
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: Colors.white,
            child: AnimatedSwitcher(
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              child: ListView(
                key: ValueKey(current.id ?? index),
                controller: _content,
                padding: const EdgeInsets.fromLTRB(
                    12, 16, 12, FloatingCart.clearance),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      current.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: CategoryViewColors.ink,
                      ),
                    ),
                  ),
                  CategoryTileGrid(
                    categories: children,
                    allOf: current,
                    columns: 3,
                    spacing: 10,
                    fontSize: 11.5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  final ProductCategory category;
  final bool selected;
  final VoidCallback onTap;
  const _RailItem({
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
        child: Container(
          color: selected ? Colors.white : Colors.transparent,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                child: Column(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CategoryPicture(
                        url: categoryCoverImage(category),
                        radius: 14,
                        background: selected
                            ? accent.withValues(alpha: 0.10)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
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
                  right: 0,
                  top: 12,
                  bottom: 12,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(3)),
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
