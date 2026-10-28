import 'package:flutter/material.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/font_utils.dart';

/// AppHeaderBasket1 (theme header "header-19") — the app side of the web's
/// HeaderBasket1: a bar in the store's primary colour with the wide logo on a
/// white plate (so any logo reads on any brand colour), account + cart on the
/// right, and a full-width white search pill underneath. No location picker.
///
/// The wide logo is the bundled `images/app_logo_wide.png`; a branch without
/// one shows the app name instead.
class AppHeaderBasket1 extends StatelessWidget implements PreferredSizeWidget {
  final int cartCount;
  final VoidCallback? onCartClick;
  final VoidCallback? onSearchClick;
  final VoidCallback? onProfileTap;
  const AppHeaderBasket1({
    super.key,
    this.cartCount = 0,
    this.onCartClick,
    this.onSearchClick,
    this.onProfileTap,
  });

  static const double height = 116;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final bar = AppColors.primary;
    final on = bar.computeLuminance() > 0.5 ? const Color(0xFF1B1F1D) : Colors.white;
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: bar,
      automaticallyImplyLeading: false,
      toolbarHeight: height,
      titleSpacing: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
          child: Column(children: [
            SizedBox(
              height: 46,
              child: Row(children: [
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Image.asset(
                    AppAssets.app_logo_wide,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(AppConfig.appName,
                          style: FontUtils.primaryFontStyle(
                              fontSize: 15, fontWeight: FontWeight.w800, color: bar)),
                    ),
                  ),
                ),
                const Spacer(),
                _HeaderIcon(icon: Icons.person_outline_rounded, color: on, onTap: onProfileTap, label: 'Account'),
                _HeaderIcon(
                    icon: Icons.shopping_cart_outlined, color: on, onTap: onCartClick, label: 'Cart', badge: cartCount),
              ]),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: onSearchClick,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(children: [
                    const Icon(Icons.search_rounded, size: 21, color: Color(0xFF6B7280)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Search products, brands and more',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.secondaryFontStyle(fontSize: 14, color: const Color(0xFF6B7280))),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String label;
  final int badge;
  const _HeaderIcon({required this.icon, required this.color, required this.onTap, required this.label, this.badge = 0});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
              Icon(icon, size: 26, color: color),
              if (badge > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.4),
                    ),
                    alignment: Alignment.center,
                    child: Text(badge > 99 ? '99+' : '$badge',
                        style: FontUtils.primaryFontStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
            ]),
          ),
        ),
      );
}
