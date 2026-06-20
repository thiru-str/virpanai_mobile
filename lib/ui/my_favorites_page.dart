import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/cart_response.dart' hide Product, Customer;
import 'package:waioz/ui/favourite_list_detail_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../utility/app_strings.dart';

Future<Customer?> getCustomerResponse() async {
  final dynamic userData = await SharedPreferencesUtil().getMap('customer');
  if (userData != null) return Customer.fromJson(userData);
  return null;
}

class MyFavoritesPage extends StatefulWidget {
  final bool? isFromBottomNav;
  const MyFavoritesPage({super.key, this.isFromBottomNav});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage>
    with SingleTickerProviderStateMixin {
  FavouriteListConfig config = FavouriteListConfig();
  List<CustomerWishlistGroup> groups = [];
  bool loading = true;
  bool loggedIn = false;
  String? _simpleListId; // set in simple mode — renders detail page inline
  final _api = ApiService();
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final customer = await getCustomerResponse();
    if (!mounted) return;
    setState(() => loggedIn = customer != null);
    if (customer == null) {
      setState(() => loading = false);
      return;
    }
    try {
      final cfg = await _api.getFavouriteListConfig(context);
      final listsRes = await _api.getFavouriteLists(context);
      if (!mounted) return;
      setState(() {
        config = cfg;
        groups = listsRes.customerWishlistGroup ?? [];
        loading = false;
      });
      _fadeCtrl.forward();

      // Simple mode: render the list detail inline so the bottom tab bar stays visible.
      if (!config.enabled && groups.isNotEmpty && mounted) {
        setState(() => _simpleListId = groups.first.id!);
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _createList() async {
    final controller = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateListSheet(
        controller: controller,
        displayName: config.displayName,
      ),
    );
    if (name == null || name.isEmpty) return;
    final isDuplicate = groups.any(
      (g) => (g.wishlistGroupName ?? '').trim().toLowerCase() == name.toLowerCase(),
    );
    if (isDuplicate) {
      if (mounted) AppUtils.showToast('A list named "$name" already exists');
      return;
    }
    try {
      final res = await _api.createFavouriteList(context, name);
      if (res.success == true && res.createdWishlistGroup != null && mounted) {
        setState(() => groups.add(res.createdWishlistGroup!));
      }
    } catch (_) {}
  }

  Future<void> _deleteList(CustomerWishlistGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete list?',
                style: FontUtils.secondaryFontStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF272727),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${group.wishlistGroupName}" and all its saved products will be removed.',
                style: FontUtils.primaryFontStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text('Cancel',
                          style: FontUtils.primaryFontStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text('Delete',
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
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteFavouriteList(context, group.id!);
      if (mounted) setState(() => groups.removeWhere((g) => g.id == group.id));
    } catch (_) {}
  }

  Future<void> _addGroupToCart(CustomerWishlistGroup group) async {
    bool cartHasItems = false;
    try {
      final cartRes = await _api.getCart(context);
      cartHasItems = cartRes.cart?.items?.isNotEmpty ?? false;
    } catch (_) {}

    String choice = 'keep';
    if (cartHasItems) {
      if (!mounted) return;
      final picked = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _GroupAddToCartSheet(
          groupName: group.wishlistGroupName ?? 'list',
          itemCount: group.productCount ?? 0,
        ),
      );
      if (picked == null) return;
      choice = picked;
    }

    try {
      final res = await _api.moveFavouriteListToCart(
        context,
        group.id!,
        clearExistingCart: choice == 'clear',
      );
      if (mounted) {
        final added = res.addedCount ?? 0;
        final skipped = res.skippedCount ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            backgroundColor: const Color(0xFF272727),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              added > 0
                  ? 'Added $added item${added != 1 ? 's' : ''} to cart${skipped > 0 ? ', $skipped skipped' : ''}.'
                  : 'No items could be added.',
              style: FontUtils.primaryFontStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        );
      }
    } catch (_) {}
  }

  IconData _configIcon() {
    switch (config.icon) {
      case 'bookmark':   return Icons.bookmark_border_rounded;
      case 'star':       return Icons.star_border_rounded;
      case 'sparkles':   return Icons.auto_awesome_outlined;
      case 'trophy':     return Icons.emoji_events_outlined;
      case 'bag':        return Icons.shopping_bag_outlined;
      case 'gift':       return Icons.card_giftcard_outlined;
      case 'list':       return Icons.playlist_add_check_rounded;
      case 'bullets':    return Icons.format_list_bulleted;
      case 'collection': return Icons.collections_bookmark_outlined;
      case 'package':    return Icons.inventory_2_outlined;
      case 'tag':        return Icons.sell_outlined;
      default:           return Icons.favorite_border_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple mode with a list — embed FavouriteListDetailPage directly so the
    // bottom tab bar (owned by the outer Scaffold) remains visible.
    if (_simpleListId != null) {
      return FavouriteListDetailPage(
        listId: _simpleListId!,
        listName: config.displayName,
        config: config,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: widget.isFromBottomNav != true,
        title: Text(
          config.displayName,
          style: FontUtils.secondaryFontStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF272727),
          ),
        ),
        actions: [
          if (!loading && loggedIn && config.enabled)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _createList,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('New',
                          style: FontUtils.primaryFontStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: loading
          ? _buildSkeleton()
          : !loggedIn
              ? _buildLoginPrompt()
              : !config.enabled
                  ? _buildSimpleModeEmpty()
                  : _buildGroupList(),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(_configIcon(), size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Sign in to save favourites',
              style: FontUtils.secondaryFontStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create wishlists and never lose track of the products you love.',
              style: FontUtils.primaryFontStyle(
                  fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleModeEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.18),
                    AppColors.primary.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(_configIcon(), size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing saved yet',
              style: FontUtils.secondaryFontStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the ${config.icon} on any product to save it to your ${config.displayName.toLowerCase()}.',
              style: FontUtils.primaryFontStyle(
                  fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      AppColors.primary.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(_configIcon(), size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('No lists yet',
                  style: FontUtils.secondaryFontStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                'Tap New to create your first ${config.displayName.toLowerCase()}.',
                style: FontUtils.primaryFontStyle(
                    fontSize: 13, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeCtrl,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final group = groups[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GroupCard(
              group: group,
              icon: _configIcon(),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavouriteListDetailPage(
                      listId: group.id!,
                      listName: group.wishlistGroupName ?? config.displayName,
                      config: config,
                    ),
                  ),
                );
                if (mounted) _load();
              },
              onDelete: () => _deleteList(group),
              onAddToCart: () => _addGroupToCart(group),
            ),
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  final CustomerWishlistGroup group;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Future<void> Function() onAddToCart;

  const _GroupCard({
    required this.group,
    required this.icon,
    required this.onTap,
    required this.onDelete,
    required this.onAddToCart,
  });

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _pressed = false;
  bool _addingToCart = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      AppColors.primary.withOpacity(0.07),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.wishlistGroupName ?? '',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF272727),
                      ),
                    ),
                    if (widget.group.productCount != null)
                      Text(
                        '${widget.group.productCount} item${widget.group.productCount != 1 ? 's' : ''}',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _addingToCart
                    ? null
                    : () async {
                        setState(() => _addingToCart = true);
                        try {
                          await widget.onAddToCart();
                        } finally {
                          if (mounted) setState(() => _addingToCart = false);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _addingToCart
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(Icons.shopping_cart_outlined,
                          size: 20, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: widget.onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline,
                      size: 20, color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupAddToCartSheet extends StatelessWidget {
  final String groupName;
  final int itemCount;

  const _GroupAddToCartSheet({required this.groupName, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add "$groupName" to cart',
            style: FontUtils.secondaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$itemCount item${itemCount != 1 ? 's' : ''} will be added.',
            style: FontUtils.primaryFontStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          _SheetOption(
            icon: Icons.playlist_add_rounded,
            title: 'Keep cart & add',
            subtitle: 'Existing cart items stay.',
            onTap: () => Navigator.pop(context, 'keep'),
          ),
          const SizedBox(height: 10),
          _SheetOption(
            icon: Icons.delete_sweep_outlined,
            title: 'Clear cart & add',
            subtitle: 'Start fresh with this list.',
            destructive: true,
            onTap: () => Navigator.pop(context, 'clear'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
            child: Text('Cancel',
                style: FontUtils.primaryFontStyle(fontSize: 14, color: Colors.grey.shade500)),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.red.shade400 : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                  Text(subtitle,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateListSheet extends StatefulWidget {
  final TextEditingController controller;
  final String displayName;

  const _CreateListSheet({
    required this.controller,
    required this.displayName,
  });

  @override
  State<_CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<_CreateListSheet> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'New ${widget.displayName}',
            style: FontUtils.secondaryFontStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Give your list a name to find it easily.',
            style: FontUtils.primaryFontStyle(
                fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: widget.controller,
            autofocus: true,
            onSubmitted: (v) =>
                Navigator.pop(context, widget.controller.text.trim()),
            style: FontUtils.primaryFontStyle(
                fontSize: 15, color: const Color(0xFF272727)),
            decoration: InputDecoration(
              hintText: 'e.g. Weekend Groceries',
              hintStyle: FontUtils.primaryFontStyle(
                  fontSize: 14, color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF8F7FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel',
                      style: FontUtils.primaryFontStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, widget.controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Create',
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
    ));
  }
}
