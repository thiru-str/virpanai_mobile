import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class FavouriteHeartButton extends StatefulWidget {
  final String productId;
  final String productHandle;
  final String? selectedVariantId;
  final List<dynamic> variants;
  final bool isLoggedIn;
  final FavouriteListConfig? config;
  final bool initialSaved;
  final double size;

  const FavouriteHeartButton({
    super.key,
    required this.productId,
    required this.productHandle,
    required this.isLoggedIn,
    this.selectedVariantId,
    this.variants = const [],
    this.config,
    this.initialSaved = false,
    this.size = 22,
  });

  @override
  State<FavouriteHeartButton> createState() => _FavouriteHeartButtonState();
}

class _FavouriteHeartButtonState extends State<FavouriteHeartButton>
    with SingleTickerProviderStateMixin {
  late bool _saved;
  bool _loading = false;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _saved = widget.initialSaved;
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.75,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavouriteHeartButton old) {
    super.didUpdateWidget(old);
    if (old.selectedVariantId != widget.selectedVariantId ||
        old.initialSaved != widget.initialSaved) {
      _saved = widget.initialSaved;
    }
  }

  FavouriteListConfig get _config => widget.config ?? FavouriteListConfig();

  Color _accentColor() {
    switch (_config.icon) {
      case 'bookmark':   return Colors.blue.shade500;
      case 'star':       return Colors.amber.shade600;
      case 'sparkles':   return Colors.amber.shade500;
      case 'trophy':     return Colors.amber.shade700;
      case 'bag':        return Colors.indigo.shade500;
      case 'gift':       return Colors.pink.shade400;
      case 'list':       return Colors.green.shade600;
      case 'bullets':    return Colors.green.shade600;
      case 'collection': return Colors.teal.shade500;
      case 'package':    return Colors.orange.shade500;
      case 'tag':        return Colors.purple.shade500;
      default:           return Colors.red.shade500;
    }
  }

  Widget _buildIcon(bool filled) {
    final color = filled ? _accentColor() : Colors.grey.shade500;
    final size = widget.size;
    switch (_config.icon) {
      case 'bookmark':
        return Icon(filled ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: color, size: size);
      case 'star':
        return Icon(filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: color, size: size);
      case 'sparkles':
        return Icon(filled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
            color: color, size: size);
      case 'trophy':
        return Icon(filled ? Icons.emoji_events : Icons.emoji_events_outlined,
            color: color, size: size);
      case 'bag':
        return Icon(filled ? Icons.shopping_bag : Icons.shopping_bag_outlined,
            color: color, size: size);
      case 'gift':
        return Icon(filled ? Icons.card_giftcard : Icons.card_giftcard_outlined,
            color: color, size: size);
      case 'list':
        return Icon(filled ? Icons.checklist_rounded : Icons.playlist_add_rounded,
            color: color, size: size);
      case 'bullets':
        return Icon(filled ? Icons.format_list_bulleted : Icons.format_list_bulleted,
            color: color, size: size);
      case 'collection':
        return Icon(filled ? Icons.collections_bookmark : Icons.collections_bookmark_outlined,
            color: color, size: size);
      case 'package':
        return Icon(filled ? Icons.inventory_2 : Icons.inventory_2_outlined,
            color: color, size: size);
      case 'tag':
        return Icon(filled ? Icons.sell : Icons.sell_outlined,
            color: color, size: size);
      default:
        return Icon(filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: color, size: size);
    }
  }

  Future<void> _handleTap() async {
    if (!widget.isLoggedIn || _loading) return;
    await _scaleCtrl.reverse();
    await _scaleCtrl.forward();
    final api = ApiService();
    if (!_config.enabled) {
      await _handleSimpleModeToggle(api);
    } else {
      await _showAddSheet(api);
    }
  }

  Future<void> _handleSimpleModeToggle(ApiService api) async {
    setState(() => _loading = true);
    try {
      if (_saved) {
        final listsRes = await api.getFavouriteLists(context);
        final lists = listsRes.customerWishlistGroup ?? [];
        if (lists.isNotEmpty) {
          await api.deleteProductFromFavouriteList(
            context,
            productId: widget.productId,
            listId: lists.first.id!,
          );
          if (mounted) setState(() => _saved = false);
        }
      } else {
        final variantId = widget.selectedVariantId ??
            (widget.variants.isNotEmpty
                ? widget.variants.first['id'] as String? ?? ''
                : '');
        if (variantId.isEmpty) return;
        await api.addProductToFavouriteList(
          context,
          productId: widget.productId,
          variantId: variantId,
          listName: _config.displayName,
        );
        if (mounted) setState(() => _saved = true);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showAddSheet(ApiService api) async {
    setState(() => _loading = true);
    List<CustomerWishlistGroup> lists = [];
    try {
      final res = await api.getFavouriteLists(context);
      lists = res.customerWishlistGroup ?? [];
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (!mounted) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddToListSheet(
        productId: widget.productId,
        variants: widget.variants,
        preSelectedVariantId: widget.selectedVariantId,
        lists: lists,
        config: _config,
        api: api,
      ),
    );
    if (result == true && mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _loading
              ? SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: _accentColor(),
                  ),
                )
              : _buildIcon(_saved),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom sheet helper widgets
// ─────────────────────────────────────────────

class _SheetQtyBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _SheetQtyBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 4,
                        offset: const Offset(0, 1))
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: enabled ? const Color(0xFF272727) : Colors.grey.shade400,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// Add-to-list bottom sheet
// ─────────────────────────────────────────────

class _AddToListSheet extends StatefulWidget {
  final String productId;
  final List<dynamic> variants;
  final String? preSelectedVariantId;
  final List<CustomerWishlistGroup> lists;
  final FavouriteListConfig config;
  final ApiService api;

  const _AddToListSheet({
    required this.productId,
    required this.variants,
    required this.preSelectedVariantId,
    required this.lists,
    required this.config,
    required this.api,
  });

  @override
  State<_AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends State<_AddToListSheet> {
  late String? _selectedVariantId;
  String? _selectedListId;
  final _newListCtrl = TextEditingController();
  bool _saving = false;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _selectedVariantId = widget.preSelectedVariantId ??
        (widget.variants.isNotEmpty
            ? widget.variants.first['id'] as String?
            : null);
    _selectedListId = widget.lists.isNotEmpty ? widget.lists.first.id : null;
  }

  @override
  void dispose() {
    _newListCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final variantId = _selectedVariantId ?? '';
    if (variantId.isEmpty) {
      _toast('Please select a variant');
      return;
    }
    final newName = _newListCtrl.text.trim();
    if (newName.isEmpty && _selectedListId == null) {
      _toast('Select or create a list');
      return;
    }
    setState(() => _saving = true);
    try {
      final res = await widget.api.addProductToFavouriteList(
        context,
        productId: widget.productId,
        variantId: variantId,
        listId: newName.isEmpty ? _selectedListId : null,
        listName: newName.isNotEmpty ? newName : null,
        quantity: _qty,
      );
      if (!mounted) return;
      if (res.success == true) {
        Navigator.pop(context, true);
        _toast('Saved to ${widget.config.displayName}!');
      } else {
        setState(() => _saving = false);
        _toast('Failed to save. Please try again.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _toast('Failed to save. Please try again.');
      }
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: const Color(0xFF272727),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(msg,
            style: FontUtils.primaryFontStyle(
                fontSize: 13, color: Colors.white)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          // Title
          Text(
            'Save to ${widget.config.displayName}',
            style: FontUtils.secondaryFontStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 20),

          // Variant picker
          if (widget.variants.length > 1) ...[
            _sectionLabel('Variant'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.variants.map((v) {
                final id = v['id'] as String? ?? '';
                final title = v['title'] as String? ?? id;
                final sel = _selectedVariantId == id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVariantId = id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: sel
                            ? AppColors.primary
                            : Colors.grey.shade200,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      title,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.normal,
                        color: sel ? Colors.white : const Color(0xFF272727),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],

          // List picker
          if (widget.lists.isNotEmpty) ...[
            _sectionLabel('Choose list'),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 176),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.lists.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
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
                            duration: const Duration(milliseconds: 150),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: sel ? AppColors.primary : Colors.transparent,
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

          // Qty picker
          if (widget.config.qtyEnabled) ...[
            _sectionLabel('Quantity'),
            const SizedBox(height: 8),
            Container(
              height: 44,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _SheetQtyBtn(
                    icon: Icons.remove,
                    enabled: _qty > 1,
                    onTap: () =>
                        setState(() => _qty = (_qty - 1).clamp(1, 999)),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_qty',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF272727),
                        ),
                      ),
                    ),
                  ),
                  _SheetQtyBtn(
                    icon: Icons.add,
                    enabled: _qty < 999,
                    onTap: () =>
                        setState(() => _qty = (_qty + 1).clamp(1, 999)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // New list input
          _sectionLabel(
              widget.lists.isNotEmpty ? 'Or create new list' : 'Create a list'),
          const SizedBox(height: 8),
          TextField(
            controller: _newListCtrl,
            onChanged: (_) => setState(() {
              if (_newListCtrl.text.isNotEmpty) _selectedListId = null;
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
                borderSide:
                    BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text('Cancel',
                      style: FontUtils.primaryFontStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: FontUtils.primaryFontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.6,
        ),
      );
}
