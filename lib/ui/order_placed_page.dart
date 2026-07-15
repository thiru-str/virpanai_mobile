import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/order_detail_item_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../utility/page_route_utils.dart';

class OrderPlacedPage extends StatefulWidget {
  final String? orderId;
  const OrderPlacedPage({super.key, required this.orderId});

  @override
  State<OrderPlacedPage> createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage> {
  bool _saving = false;

  Future<void> _saveAllToList() async {
    setState(() => _saving = true);
    try {
      // Fetch order items
      final orderDetail = await ApiService().getOrderDetails(context, widget.orderId!);
      final items = (orderDetail.data?.items ?? [])
          .where((i) => i.productId != null)
          .toList();
      if (items.isEmpty || !mounted) return;

      // Fetch existing lists
      final listsResp = await ApiService().getFavouriteLists(context);
      if (!mounted) return;
      final lists = listsResp.customerWishlistGroup ?? [];

      // Show list picker
      final listId = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ListPickerSheet(lists: lists),
      );
      if (listId == null || !mounted) return;

      // Bulk add all items
      final api = ApiService();
      for (final item in items) {
        await api.addProductToFavouriteList(
          context,
          productId: item.productId!,
          listId: listId,
          variantId: item.variantId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${items.length} item${items.length == 1 ? '' : 's'} saved to list'),
          backgroundColor: AppColors.primary,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        } else {
          PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Celebratory success check
                      Center(
                        child: Container(
                          height: 104,
                          width: 104,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F7F0),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              height: 72,
                              width: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1FA971),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        AppStrings.order_placed_success.replaceAll('\n', ' '),
                        textAlign: TextAlign.center,
                        style: UiTypography.cardTitle().copyWith(
                          fontSize: 22,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtext
                      Text(
                        AppStrings.email_confirmation,
                        textAlign: TextAlign.center,
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 14,
                          color: AppColors.textColor50,
                          fontWeight: FontWeight.w400,
                        ).copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Order summary card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your order is confirmed',
                              textAlign: TextAlign.center,
                              style: UiTypography.cardTitle().copyWith(
                                fontSize: 16,
                                height: 1.25,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'We\'ll keep you updated on the delivery status. You can track it anytime from your orders.',
                              textAlign: TextAlign.center,
                              style: UiTypography.cardSubtitle().copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky bottom actions
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary CTA — View details
                    ElevatedButton.icon(
                      onPressed: () {
                        PageRouteUtils.pushAndRemoveUntil(
                          context,
                          OrderDetailItemPage(orderId: widget.orderId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        'View details',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Secondary CTA — Continue shopping
                    OutlinedButton(
                      onPressed: () {
                        PageRouteUtils.pushAndRemoveUntil(
                            context, const BottomNavPage());
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppStrings.see_more_product,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tertiary CTA — Save to Maligai List
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _saveAllToList,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        side: BorderSide(
                            color: _saving ? Colors.grey.shade300 : AppColors.primary,
                            width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _saving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(Icons.favorite_border_rounded,
                              color: AppColors.primary, size: 20),
                      label: Text(
                        'Save to Maligai List',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _saving ? Colors.grey : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListPickerSheet extends StatefulWidget {
  final List<CustomerWishlistGroup> lists;
  const _ListPickerSheet({required this.lists});

  @override
  State<_ListPickerSheet> createState() => _ListPickerSheetState();
}

class _ListPickerSheetState extends State<_ListPickerSheet> {
  bool _creatingNew = false;
  bool _creating = false;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAndPick() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _creating = true);
    try {
      final resp = await ApiService().createFavouriteList(context, name);
      final newId = resp.createdWishlistGroup?.id ??
          resp.customerWishlistGroup?.firstOrNull?.id;
      if (mounted) Navigator.pop(context, newId);
    } catch (_) {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Save to Maligai List',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          const Divider(height: 1),
          if (widget.lists.isNotEmpty)
            ...widget.lists.map((list) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.list_alt_rounded,
                        size: 20, color: AppColors.primary),
                  ),
                  title: Text(list.wishlistGroupName ?? '',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: list.productCount != null
                      ? Text('${list.productCount} items',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500))
                      : null,
                  trailing: Icon(Icons.chevron_right,
                      color: Colors.grey.shade400),
                  onTap: () => Navigator.pop(context, list.id),
                )),
          if (!_creatingNew) ...[
            const Divider(height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded,
                    size: 20, color: Colors.grey.shade700),
              ),
              title: const Text('Create new list',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () => setState(() => _creatingNew = true),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'List name',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _creating ? null : _createAndPick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    child: _creating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
