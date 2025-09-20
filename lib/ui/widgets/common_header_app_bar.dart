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
      backgroundColor: Color(0xFFF5FEF2),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading ? GestureDetector(
        onTap: onBackTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 16),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.ic_arrow_svg,
              height: 16,
              width: 16,
              color: AppColors.primary,
            ),
          ),
        ),
      ) : null,
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
          icon: Icon(Icons.share,color: AppColors.primary,),
          onPressed: onShareTap,
        ),
        if (onCartTap != null)
          GestureDetector(
            onTap: onCartTap,
            child: Container(
              width: 24,
              height: 24,
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
                  color: Colors.transparent, // Background color
                ),
                child: Center(
                    child: Icon(
                  isFavorite ?? false
                      ? Icons.favorite // Filled icon if favorite
                      : Icons.favorite_border, // Outline icon if not favorite
                  color: AppColors.primary,
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
