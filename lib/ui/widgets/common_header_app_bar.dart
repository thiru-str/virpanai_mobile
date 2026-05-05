import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class CommonHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackTap;
  final VoidCallback? onFavTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onShareTap;
  final bool leading;
  final bool? isFavorite;
  final bool? showCart;
  final List<Widget>? trailingActions;
  /// When provided, replaces the default onFavTap icon with this widget.
  final Widget? favWidget;

  const CommonHeaderAppBar({
    Key? key,
    this.title = '',
    required this.onBackTap,
    this.onFavTap,
    this.onCartTap,
    this.onShareTap,
    this.leading = true,
    this.isFavorite = false,
    this.showCart = false,
    this.trailingActions,
    this.favWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF5FEF2),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onBackTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.ic_arrow_svg,
                    height: 16,
                    width: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: FontUtils.primaryFontStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      actions: [
        if (onShareTap != null)
          IconButton(
            icon: Icon(Icons.share, color: AppColors.primary),
            onPressed: onShareTap,
          ),
        if (onCartTap != null)
          GestureDetector(
            onTap: onCartTap,
            child: Container(
              width: 48,
              height: 48,
              child: IconButton(
                  onPressed: onCartTap,
                  icon: Icon(Icons.shopping_cart,
                      color: AppColors.primary, size: 24)),
            ),
          ),
        if (favWidget != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: favWidget!,
          )
        else if (onFavTap != null)
          GestureDetector(
            onTap: onFavTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Center(
                    child: Icon(
                  isFavorite ?? false
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: AppColors.primary,
                )
                    ),
              ),
            ),
          ),
        if (trailingActions != null) ...trailingActions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
