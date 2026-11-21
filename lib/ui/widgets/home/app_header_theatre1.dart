import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_config.dart';

import 'theatre/theatre_shared.dart';

/// AppHeaderTheatre1 ("header-20") — the app twin of the web's dark
/// HeaderSplit1 bar used by the THEATRE family: the night ground, the store's
/// light logo on the left, then search, account and the cart with its count,
/// over a hairline. Search, account and cart are live (the same callbacks
/// header-19 takes).
///
/// The logo is the bundled `images/app_logo_light.webp` (a logo drawn for a
/// dark ground); a store without one shows its name in the screen colour.
class AppHeaderTheatre1 extends StatelessWidget implements PreferredSizeWidget {
  final int cartCount;
  final VoidCallback? onCartClick;
  final VoidCallback? onSearchClick;
  final VoidCallback? onProfileTap;
  const AppHeaderTheatre1({
    super.key,
    this.cartCount = 0,
    this.onCartClick,
    this.onSearchClick,
    this.onProfileTap,
  });

  static const double height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    const on = kTheatreScreen;
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: kTheatreNight,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      toolbarHeight: height,
      titleSpacing: 0,
      shape: Border(bottom: BorderSide(color: on.withValues(alpha: 0.14))),
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
          child: SizedBox(
            height: height,
            child: Row(children: [
              // A fixed box so the bar never jumps while the logo decodes.
              SizedBox(
                width: 168,
                height: 34,
                child: Image.asset(
                  AppAssets.app_logo_light,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (_, __, ___) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppConfig.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theatreWide(on,
                            size: 15, weight: FontWeight.w700, tracking: 0.06)),
                  ),
                ),
              ),
              const Spacer(),
              _BarIcon(
                  icon: Icons.search_rounded,
                  color: on,
                  onTap: onSearchClick,
                  label: 'Search'),
              _BarIcon(
                  icon: Icons.person_outline_rounded,
                  color: on,
                  onTap: onProfileTap,
                  label: 'Account'),
              _BarIcon(
                  icon: Icons.shopping_bag_outlined,
                  color: on,
                  onTap: onCartClick,
                  label: 'Cart',
                  badge: cartCount),
            ]),
          ),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String label;
  final int badge;
  const _BarIcon(
      {required this.icon,
      required this.color,
      required this.onTap,
      required this.label,
      this.badge = 0});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          highlightColor: Colors.transparent,
          splashColor: color.withValues(alpha: 0.12),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 25, color: color),
                  if (badge > 0)
                    Positioned(
                      right: 3,
                      top: 4,
                      child: Container(
                        constraints:
                            const BoxConstraints(minWidth: 17, minHeight: 17),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: kTheatreRed,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: kTheatreNight, width: 1.4),
                        ),
                        alignment: Alignment.center,
                        child: Text(badge > 99 ? '99+' : '$badge',
                            style: theatreBody(Colors.white,
                                size: 9.5, weight: FontWeight.w700)),
                      ),
                    ),
                ]),
          ),
        ),
      );
}
