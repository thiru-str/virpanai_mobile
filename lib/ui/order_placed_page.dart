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

// ignore_for_file: deprecated_member_use

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
      // Fetch order items, lists, and config in parallel
      final results = await Future.wait([
        ApiService().getOrderDetails(context, widget.orderId!),
        ApiService().getFavouriteLists(context),
        ApiService().getFavouriteListConfig(context),
      ]);
      if (!mounted) return;

      final orderDetail = results[0] as dynamic;
      final items = ((orderDetail.data?.items ?? []) as List)
          .where((i) => i.productId != null)
          .toList();
      if (items.isEmpty) return;

      final lists = (results[1] as WishlistResponse).customerWishlistGroup ?? [];
      final config = results[2] as FavouriteListConfig;

      // Show list picker — same UI as _AddToListSheet
      final listId = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ListPickerSheet(lists: lists, config: config),
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
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor: const Color(0xFF272727),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            '${items.length} item${items.length == 1 ? '' : 's'} saved to list',
            style: FontUtils.primaryFontStyle(fontSize: 13, color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor: const Color(0xFF272727),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('Failed to save. Please try again.',
              style: FontUtils.primaryFontStyle(fontSize: 13, color: Colors.white)),
          duration: const Duration(seconds: 2),
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
  final FavouriteListConfig config;
  const _ListPickerSheet({required this.lists, required this.config});

  @override
  State<_ListPickerSheet> createState() => _ListPickerSheetState();
}

class _ListPickerSheetState extends State<_ListPickerSheet> {
  String? _selectedListId;
  final _newListCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.lists.isNotEmpty ? widget.lists.first.id : null;
  }

  @override
  void dispose() {
    _newListCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newName = _newListCtrl.text.trim();
    if (newName.isEmpty && _selectedListId == null) return;
    setState(() => _saving = true);
    try {
      String? listId = _selectedListId;
      if (newName.isNotEmpty) {
        final resp = await ApiService().createFavouriteList(context, newName);
        listId = resp.createdWishlistGroup?.id ??
            resp.customerWishlistGroup?.firstOrNull?.id;
      }
      if (mounted) Navigator.pop(context, listId);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardH = media.viewInsets.bottom;
    final sheetH = (media.size.height * 0.75)
        .clamp(0.0, media.size.height - keyboardH - 40);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardH),
        child: Container(
          height: sheetH,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title + close
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Save to ${widget.config.displayName}',
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF272727),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          size: 20, color: Colors.grey.shade500),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Choose list
                      if (widget.lists.isNotEmpty) ...[
                        _sectionLabel('Choose list'),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: widget.lists.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            itemBuilder: (_, i) {
                              final list = widget.lists[i];
                              final sel = _selectedListId == list.id &&
                                  _newListCtrl.text.isEmpty;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedListId = list.id;
                                  _newListCtrl.clear();
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AppColors.primary.withOpacity(0.06)
                                        : const Color(0xFFF8F7FC),
                                    border: Border.all(
                                      color: sel
                                          ? AppColors.primary.withOpacity(0.5)
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: sel
                                                ? AppColors.primary
                                                : Colors.grey.shade400,
                                            width: 1.5,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: sel
                                            ? const Icon(Icons.check,
                                                size: 12, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          list.wishlistGroupName ?? '',
                                          style: FontUtils.primaryFontStyle(
                                            fontSize: 14,
                                            fontWeight: sel
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: const Color(0xFF272727),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Create new list
                      _sectionLabel(widget.lists.isNotEmpty
                          ? 'Or create new list'
                          : 'Create a list'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newListCtrl,
                        onChanged: (_) => setState(() {
                          if (_newListCtrl.text.isNotEmpty) {
                            _selectedListId = null;
                          }
                        }),
                        onSubmitted: (_) => _save(),
                        style: FontUtils.primaryFontStyle(
                            fontSize: 14, color: const Color(0xFF272727)),
                        decoration: InputDecoration(
                          hintText:
                              'New ${widget.config.displayName.toLowerCase()} name',
                          hintStyle: FontUtils.primaryFontStyle(
                              fontSize: 14, color: Colors.grey.shade400),
                          filled: true,
                          fillColor: const Color(0xFFF8F7FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky footer
              Container(height: 1, color: Colors.grey.shade100),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Cancel',
                            style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280))),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Save',
                                style: FontUtils.primaryFontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: FontUtils.primaryFontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.6,
        ),
      );
}
