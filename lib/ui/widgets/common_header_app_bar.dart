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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: leading ? GestureDetector(
        onTap: onBackTap,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary, // Background color
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
      ) : null,
      title: Text(
        title,
        style: FontUtils.primaryFontStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      actions: [
        if (onShareTap != null)
          IconButton(
            icon: Icon(Icons.share,color: AppColors.primary,),
            onPressed: onShareTap,
          ),
        if (onCartTap != null)
          GestureDetector(
            onTap: onCartTap,
            child: Container(
              width: 48,
              height: 48,
              child: IconButton(onPressed: onCartTap, icon:  Icon(Icons.shopping_cart, color: AppColors.primary, size: 24)),
            ),
        ),
        if (onFavTap != null)
          GestureDetector(
            onTap: onFavTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Ensure consistent padding
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary, // Background color
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
