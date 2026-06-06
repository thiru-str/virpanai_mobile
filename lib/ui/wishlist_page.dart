import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/ui/product_detail_page.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

/// Simple Wishlist page (1.6.0).
/// Lists customer's saved variants. Tap product → detail page.
/// Long-press / red heart icon → remove from list (live, no confirmation).
class WishlistPage extends StatefulWidget {
  final bool isFromBottomNav;
  const WishlistPage({super.key, this.isFromBottomNav = false});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final api = ApiService();
    final items = await api.listWishlist(context);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _remove(String id) async {
    final api = ApiService();
    final ok = await api.removeFromWishlist(context, id);
    if (ok && mounted) {
      setState(() {
        _items.removeWhere((it) => it['id'] == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: 'Wishlist',
        onBackTap: widget.isFromBottomNav
            ? () {}
            : () => Navigator.of(context).pop(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _empty()
              : _grid(),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, color: Colors.grey.shade300, size: 64),
            const SizedBox(height: 14),
            Text(
              'Nothing saved yet',
              style: FontUtils.primaryFontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the heart on a product to save it here.',
              textAlign: TextAlign.center,
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, i) {
        final item = _items[i] as Map<String, dynamic>;
        final variant = item['variant'] as Map<String, dynamic>?;
        final product = variant?['product'] as Map<String, dynamic>?;
        final title = (product?['title'] as String?) ?? 'Product';
        final variantTitle = variant?['title'] as String?;
        final thumb = product?['thumbnail'] as String?;
        final id = item['id'] as String;
        final productId = item['product_id'] as String?;

        return InkWell(
          onTap: () {
            if (productId != null && productId.isNotEmpty) {
              PageRouteUtils.pushWithSlide(
                context,
                ProductDetailPage(productId: productId),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: thumb != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(thumb, fit: BoxFit.cover),
                            )
                          : Container(color: Colors.grey.shade100),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (variantTitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              variantTitle,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _remove(id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
