import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/widgets/search_bar_rolling_widget.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

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
              _buildIcon(null, svgPath: AppAssets.app_icon_svg, size: 50),
              Text(
                'GoWelMart',
                style: FontUtils.primaryFontStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildIcon(
                Icons.shopping_cart,
                color: Colors.white,
                onPressed: onCartClick,
                cartCount: cartCount,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
              height: 48, child: SearchBarWithRollingHint(onTap: onSearchTap)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}

Widget _buildIcon(
  IconData? icon, {
  String? assetPath,
  String? svgPath,
  VoidCallback? onPressed,
  double? size,
  double? width,
  double? height,
  Color? color,
  int cartCount = 0,
}) {
  // Decide which icon type to render
  Widget iconWidget;
  if (svgPath != null) {
    iconWidget = SvgPicture.asset(
      svgPath,
      width: size ?? 24,
      height: size ?? 24,
      color: color,
      fit: BoxFit.contain,
    );
  } else if (assetPath != null) {
    iconWidget = Image.asset(
      assetPath,
      width: size ?? 24,
      height: size ?? 24,
      color: color,
      fit: BoxFit.contain,
    );
  } else {
    iconWidget = Icon(
      icon,
      color: color ?? Colors.black,
      size: size,
    );
  }

  // Add badge only if it's the cart icon and has count
  if ((icon == Icons.shopping_cart || svgPath?.contains("cart") == true) &&
      cartCount > 0) {
    iconWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -2,
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
              cartCount > 99 ? '99+' : '$cartCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
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
