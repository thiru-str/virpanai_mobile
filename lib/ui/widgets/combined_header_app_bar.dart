import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/widgets/search_bar_rolling_widget.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_strings.dart';
import '../../utility/font_utils.dart';

class CombinedHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String headerType;
  final String title;
  final VoidCallback? onBackTap;
  final VoidCallback? onCartClick;
  final VoidCallback? onSearchTap;
  final int cartCount;
  final bool showBack;
  final String addressType;

  const CombinedHeaderAppBar({
    Key? key,
    this.headerType = "header-1",
    this.title = "",
    this.onBackTap,
    this.onCartClick,
    this.onSearchTap,
    this.cartCount = 0,
    this.showBack = true,
    this.addressType = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (headerType) {
      case "header-1":
        return _buildCommonAppBar();
      case "header-2":
        return _buildCommonHeader(context);
      case "header-8":
        return _buildCustomSearchAppBar(context);
      default:
        return _buildCommonAppBar();
    }
  }

  /// ✅ CommonHeaderAppBar style
  AppBar _buildCommonAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? GestureDetector(
        onTap: onBackTap,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black12,
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
        style: FontUtils.primaryFontStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      actions: [
        if (onCartClick != null)
          _buildIcon(Icons.shopping_cart,
              color: AppColors.primary,
              onPressed: onCartClick,
              cartCount: cartCount),
      ],
    );
  }

  /// ✅ CommonHeader style (below app bar logic moved into same bar)
  PreferredSize _buildCommonHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title + cart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.isEmpty ? AppStrings.home : title,
                    style: FontUtils.secondaryFontStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                  _buildIcon(Icons.shopping_cart,
                      color: AppColors.primary,
                      onPressed: onCartClick,
                      cartCount: cartCount),
                ],
              ),
              const SizedBox(height: 8),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ CustomSearchAppBar style (new header type)
  PreferredSize _buildCustomSearchAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        color: AppColors.primary,
        padding:
        const EdgeInsets.only(top: 40, left: 12, right: 12, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIcon(null,
                    assetPath: AppAssets.app_icon, size: 50, color: Colors.white),
                _buildIcon(Icons.shopping_cart,
                    color: Colors.white,
                    onPressed: onCartClick,
                    cartCount: cartCount),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onSearchTap,
              child: SearchBarWithRollingHint(
                onTap: onSearchTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Shared icon builder with badge
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
      fit: BoxFit.contain,
    )
        : Icon(icon, color: color ?? Colors.black, size: size);

    if (icon == Icons.shopping_cart && cartCount > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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

  /// ✅ Shared search bar (like CommonHeader)
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: onSearchTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.searchBarColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.search,
                style: FontUtils.secondaryFontStyle(
                    color: AppColors.textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}
