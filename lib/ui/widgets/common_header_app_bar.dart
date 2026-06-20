import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/ui_typography.dart';

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
    this.favWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.05),
      centerTitle: true,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: leading
          ? GestureDetector(
              onTap: onBackTap,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.ic_arrow_svg,
                    height: 19,
                    width: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: UiTypography.cardTitle(color: Colors.black87).copyWith(
          fontSize: 18,
        ),
      ),
      actions: [
        if (onShareTap != null)
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: IconButton(
              icon: Icon(Icons.share, color: AppColors.primary, size: 20),
              onPressed: onShareTap,
            ),
          ),
        if (onCartTap != null)
          GestureDetector(
            onTap: onCartTap,
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(top: 8, bottom: 8, right: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: IconButton(
                  onPressed: onCartTap,
                  icon: Icon(Icons.shopping_cart,
                      color: AppColors.primary, size: 22)),
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
              padding: const EdgeInsets.all(8.0), // Ensure consistent padding
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Center(
                    child: Icon(
                  isFavorite ?? false
                      ? Icons.favorite // Filled icon if favorite
                      : Icons.favorite_border, // Outline icon if not favorite
                  color: isFavorite ?? false ? Colors.red : Colors.grey[600],
                )

                    // SvgPicture.asset(
                    //   AppAssets.ic_fav,
                    //   height: 16,
                    //   width: 16,
                    //   color: Colors.black87,
                    // ),
                    ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
