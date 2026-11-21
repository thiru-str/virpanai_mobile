import 'package:flutter/material.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_views/category_view_shared.dart';
import 'package:waioz/ui/widgets/floating_cart.dart';

/// categoryView4: full-width rows (name, a few sub-category names, picture on
/// the right). A row with sub-categories opens in place to list them, one row
/// open at a time; a row without them goes straight to its products. Suits
/// fashion and lifestyle stores with photographed categories.
class CategoryListView extends StatefulWidget {
  final List<ProductCategory> categories;
  const CategoryListView({super.key, required this.categories});

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  String? _open;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return ColoredBox(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, FloatingCart.clearance),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = widget.categories[i];
          final children = categoryChildrenOf(c);
          final open = _open != null && _open == c.id;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CategoryViewColors.hairline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Row(
                  category: c,
                  children: children,
                  open: open,
                  onTap: () {
                    if (children.isEmpty) {
                      openCategory(context, c);
                    } else {
                      setState(() => _open = open ? null : c.id);
                    }
                  },
                ),
                // AnimatedSize asserts with a zero duration, so reduced
                // motion simply swaps the content
                if (still)
                  open
                      ? _Children(parent: c, children: children)
                      : const SizedBox(width: double.infinity)
                else
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: open
                        ? _Children(parent: c, children: children)
                        : const SizedBox(width: double.infinity),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final ProductCategory category;
  final List<ProductCategory> children;
  final bool open;
  final VoidCallback onTap;
  const _Row({
    required this.category,
    required this.children,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final names = children.map((c) => c.name ?? '').where((n) => n.isNotEmpty);
    final hint = names.take(3).join(', ');
    return Semantics(
      button: true,
      expanded: children.isEmpty ? null : open,
      label: category.name,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 96),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: CategoryViewColors.ink,
                        ),
                      ),
                      if (hint.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: CategoryViewColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (children.isNotEmpty)
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: MediaQuery.of(context).disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more_rounded,
                      size: 22, color: CategoryViewColors.muted),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 96,
                  height: 80,
                  child: CategoryPicture(
                      url: categoryCoverImage(category), radius: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Children extends StatelessWidget {
  final ProductCategory parent;
  final List<ProductCategory> children;
  const _Children({required this.parent, required this.children});

  @override
  Widget build(BuildContext context) {
    Widget line(String label, String image, VoidCallback onTap) => InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CategoryPicture(url: image, radius: 10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: CategoryViewColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CategoryViewColors.hairline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          line('All ${parent.name ?? ''}'.trim(), categoryCoverImage(parent),
              () => openCategoryProducts(context, parent)),
          for (final c in children)
            line(c.name ?? '', categoryCoverImage(c),
                () => openCategory(context, c)),
        ],
      ),
    );
  }
}
