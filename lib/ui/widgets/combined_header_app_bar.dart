import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/widgets/search_address.dart';
import 'package:waioz/ui/widgets/search_bar_rolling_widget.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_strings.dart';
import '../../utility/font_utils.dart';
import '../../utility/page_route_utils.dart';

class CombinedHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String headerType;
  final VoidCallback? onCartClick;
  final Function(String)? onSearchTextChanged;
  final VoidCallback? onSearchClick;
  final VoidCallback? onBackTap;
  final String title;
  final String addressType;
  final int cartCount;
  final bool showBack;

  const CombinedHeaderAppBar({
    Key? key,
    required this.headerType,
    this.onCartClick,
    this.onSearchTextChanged,
    this.onSearchClick,
    this.onBackTap,
    this.title = "",
    this.addressType = "",
    this.cartCount = 0,
    this.showBack = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('App bar $headerType');
    switch (headerType) {
      case "header-1":
        return _buildHeader1();
      case "header-2":
        return _buildHeader2();
      case "header-3":
        return _buildHeader3();
      case "header-4":
        return _buildHeader4();
      case "header-5":
        return _buildHeader5();
      case "header-6":
        return _buildHeader6();
      case "header-7":
        return _buildHeader7(context);
      case "header-8":
        return _buildCustomSearchHeader(context);
      default:
        return _buildHeader1();
    }
  }

  static double resolveHeaderHeight(String headerType) {
    switch (headerType) {
      case "header-1":
        return 70;
      case "header-2":
        return 80;
      case "header-3":
        return 120;
      case "header-4":
        return 120;
      case "header-5":
        return 120;
      case "header-6":
        return 140;
      case "header-7":
        return 140;
      case "header-8":
        return 130;
      default:
        return 120;
    }
  }

  /// --- Header 1: Logo + Cart ---
  AppBar _buildHeader1() {
    return _baseAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIcon(null, assetPath: AppAssets.app_icon, size: 50),
          _buildIcon(Icons.shopping_cart,
              color: AppColors.primary,
              onPressed: onCartClick,
              cartCount: cartCount),
        ],
      ),
    );
  }

  /// --- Header 2: Search Bar only ---
  AppBar _buildHeader2() {
    return _baseAppBar(
      child: _buildSearchBar(),
    );
  }

  /// --- Header 3: Big Icon + Search Bar ---
  AppBar _buildHeader3() {
    return _baseAppBar(
      child: Column(
        children: [
          _buildIcon(null, assetPath: AppAssets.app_icon, size: 100),
          const SizedBox(height: 8),
          _buildSearchBar(),
        ],
      ),
    );
  }

  /// --- Header 4: Home Text + Cart + Search ---
  AppBar _buildHeader4() {
    return _baseAppBar(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.home,
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
    );
  }

  /// --- Header 5: Icon + Cart + Search ---
  AppBar _buildHeader5() {
    return _baseAppBar(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIcon(null, assetPath: AppAssets.app_icon, size: 50),
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
    );
  }

  /// --- Header 6: Address + Cart + Search ---
  AppBar _buildHeader6() {
    return _baseAppBar(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_pin, color: Colors.grey, size: 36),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                addressType,
                                style: FontUtils.secondaryFontStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.textColor, size: 20),
                            ],
                          ),
                          Text(
                            title,
                            style: FontUtils.secondaryFontStyle(
                              fontSize: 14,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildIcon(Icons.account_circle, color: Colors.grey, size: 40),
            ],
          ),
          const SizedBox(height: 4),
          _buildSearchBar(),
        ],
      ),
    );
  }

  /// --- Header 7: Profile + Address + Search ---
  AppBar _buildHeader7(BuildContext context) {
    return _baseAppBar(
      child: GestureDetector(
        onTap: () {
          PageRouteUtils.pushWithSlide(context, SearchAddressPage());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildIcon(Icons.account_circle, color: Colors.grey, size: 40),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.fast_delivery,
                        style: FontUtils.secondaryFontStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor)),
                    Row(
                      children: [
                        Text(
                          title.isEmpty
                              ? "14/1, 3rd Cross Street, P And..."
                              : title,
                          style: FontUtils.secondaryFontStyle(
                              color: AppColors.textColor),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            color: AppColors.textColor, size: 20),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  /// --- Header 8: Custom Search Header (like rolling search bar) ---
  AppBar _buildCustomSearchHeader(BuildContext context) {
    return _baseAppBar(
      bgColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIcon(null,
                  assetPath: AppAssets.app_icon, size: 50,),
              _buildIcon(Icons.shopping_cart,
                  color: Colors.white,
                  onPressed: onCartClick,
                  cartCount: cartCount),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onSearchClick,
            child: SearchBarWithRollingHint(onTap: onSearchClick),
          ),
        ],
      ),
    );
  }

  /// --- Shared Base AppBar ---
  AppBar _baseAppBar({required Widget child, Color? bgColor}) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: bgColor ?? Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: _getHeaderHeight(), // 🔹 dynamic height here
      titleSpacing: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: child,
        ),
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: onBackTap,
            )
          : null,
    );
  }

  double _getHeaderHeight() {
    return resolveHeaderHeight(headerType);
  }

  /// --- Shared Search Bar Widget ---
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: onSearchClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 44,
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
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- Shared Icon with Cart Badge ---
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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

  @override
  Size get preferredSize => Size.fromHeight(_getHeaderHeight());
}
