import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/search_bar_rolling_widget.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../../utility/app_assets.dart';

class CustomSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String hintText;
  final VoidCallback onSearchTap;
  final int cartCount;
  final VoidCallback? onCartClick;

  const CustomSearchAppBar({
    Key? key,
    required this.hintText,
    required this.onSearchTap,
    this.cartCount = 0,
    this.onCartClick,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 40, left: 12, right: 12, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIcon(null,assetPath: AppAssets.app_icon,size: 50),
              _buildIcon(Icons.shopping_cart, color:Colors.white,onPressed: onCartClick,cartCount: cartCount),
            ],
          ),
          SearchBarWithRollingHint(
            onTap: onSearchTap,
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}

Widget _buildIcon(
    IconData? icon, {
      String? assetPath,
      VoidCallback? onPressed,
      double? size,
      double? width,
      double? height,
      Color? color,
      int cartCount = 0,
    }) {
  Widget iconWidget = assetPath != null
      ? Image.asset(
    assetPath,
    width: size ?? 24,
    height: size ?? 24,
    color: color,
    fit: BoxFit.contain, // prevent overflow
  )
      : Icon(icon, color: color ?? Colors.black, size: size);

  // Wrap with Stack only if it's the cart icon and cartCount > 0
  if (icon == Icons.shopping_cart && cartCount > 0) {
    iconWidget = Stack(
      clipBehavior: Clip.none, // allow badge inside bounds
      children: [
        iconWidget,
        Positioned(
          right: -2, // adjust so badge doesn’t overflow outside
          top: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              cartCount > 99 ? '99+' : '$cartCount', // clamp big numbers
              style: UiTypography.cardMeta(color: Colors.white).copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  return SizedBox(
    width: width ?? 48,
    height: height ?? 48,
    child: IconButton(
      icon: iconWidget,
      onPressed: onPressed,
      splashRadius: 24,
    ),
  );
}


