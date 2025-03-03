import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_assets.dart';

class CommonHeader extends StatelessWidget {
  final String headerType;
  final VoidCallback? onCartClick;
  final Function(String)? onSearchTextChanged;
  final VoidCallback? onSearchClick;
  final String title;
  final String addressType;

  const CommonHeader({
    Key? key,
    required this.headerType,
    this.onCartClick,
    this.onSearchTextChanged,
    this.onSearchClick,
    this.title = "",
    this.addressType = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Render Different Headers Using Switch
        switch (headerType) {
          "header-1" => _buildHeader1(),
          "header-2" => _buildHeader2(),
          "header-3" => _buildHeader3(),
          "header-4" => _buildHeader4(),
          "header-5" => _buildHeader5(),
          "header-6" => _buildHeader6(),
          "header-7" => _buildHeader7(),
          _ => _buildHeader1(), // Default case
        },
      ],
    );
  }

  /// Header 1: Just a Search Bar
  Widget _buildHeader1() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIcon(null,assetPath: AppAssets.app_icon,size: 50),
          Flexible(child: Text('Kanchipuram Lakshaya Silks',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.w700,fontSize: 18,color: Colors.red),overflow: TextOverflow.ellipsis,maxLines: 1,)),
          _buildIcon(Icons.shopping_cart, color:AppColors.primary,onPressed: onCartClick),
        ],
      ),
    ]);
  }

  /// Header 2: Home Text + Search Bar
  Widget _buildHeader2() {
    return Column(children: [_buildSearchBar()]);
  }


  /// Header 3: Left Icon + Search Bar
  Widget _buildHeader3() {
    return Column(
      children: [
        _buildIcon(null,assetPath: AppAssets.app_icon,size: 100),
        const SizedBox(width: 8),
        _buildSearchBar(),
      ],
    );
  }

  /// Header 4: Home + Cart Icon + Search Bar
  Widget _buildHeader4() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Home", style: FontUtils.gabaritoStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textColor,
            )),
            _buildIcon(Icons.shopping_cart, color:AppColors.primary,onPressed: onCartClick),
          ],
        ),
        _buildSearchBar(),
      ],
    );
  }

  /// Header 5: Left Icon + Cart Icon + Search Bar
  Widget _buildHeader5() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIcon(null,assetPath: AppAssets.app_icon,size: 50),
            _buildIcon(Icons.shopping_cart, color:AppColors.primary,onPressed: onCartClick),
          ],
        ),
        _buildSearchBar(),
      ],
    );
  }

  /// Header 6: Address + Cart Icon + Search Bar
  Widget _buildHeader6() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensures vertical alignment
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Profile image stays on the right
          children: [
            // Left Section: Location Icon + Work + Address
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Location Icon (Height Matching with Text)
                  Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.location_pin, color: Colors.grey, size: 40),
                  ),
                  const SizedBox(width: 4),
                  // Work + Address Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Work + Dropdown Icon
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              addressType,
                              style: FontUtils.gabaritoStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, color: AppColors.textColor, size: 20),
                          ],
                        ),

                        // Address (Full Width)
                        Text(
                          title,
                          style: FontUtils.gabaritoStyle(
                            fontSize: 14,
                            color: AppColors.textColor,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevents text overflow
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Profile Image (Matching Text Height)
            _buildIcon(Icons.account_circle,color: Colors.grey, size: 40),
          ],
        ),
        const SizedBox(height: 4,),
        _buildSearchBar(),
      ],
    );
  }



  /// Header 7: Profile + Address + Search Bar
  Widget _buildHeader7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildIcon(Icons.account_circle,color: Colors.grey, size: 40),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text("Lightning-Fast Delivery",
                    style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold, color: AppColors.textColor)),
                Row(
                    mainAxisSize: MainAxisSize.min,
                  children: [Text(title.isEmpty ? "14/1, 3rd Cross Street, P And..." : title,
                      style: FontUtils.gabaritoStyle(color: AppColors.textColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.textColor, size: 20),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4,),
        _buildSearchBar(),
      ],
    );
  }

  /// Common Search Bar Widget (Optional Search Callbacks)
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: onSearchClick,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.searchBarColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textColor),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                enabled: false,
                onChanged: onSearchTextChanged, // Call only if provided
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: FontUtils.gabaritoStyle(color: AppColors.textColor),
                  border: InputBorder.none,
                ),
                style: FontUtils.gabaritoStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Common Icon Widget (Optional Clickable)
  Widget _buildIcon(
      IconData? icon, {
        String? assetPath, // Optional asset icon path
        VoidCallback? onPressed,
        double? size, // Icon size
        double? width, // Width of container
        double? height, // Height of container
        Color? color, // Icon color
      }) {
    return Container(
      width: width ?? 48, // Default width
      height: height ?? 48, // Default height
      alignment: Alignment.center,
      child: IconButton(
        icon: assetPath != null
            ? Image.asset(
          assetPath,
          width: size ?? 24,
          height: size ?? 24,
          color: color, // Applies tint if needed
        )
            : Icon(icon, color: color ?? Colors.black, size: size), // Uses default icon if no asset
        onPressed: onPressed,
      ),
    );
  }



}
