import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/font_utils.dart';

class CommonHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackTap;
  final VoidCallback? onFavTap;
  final bool leading;

  const CommonHeaderAppBar({
    Key? key,
    this.title = '',
    required this.onBackTap,
    this.onFavTap,
    this.leading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: onBackTap,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200], // Background color
          ),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.ic_arrow_svg,
              height: 16,
              width: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: FontUtils.circularStdStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onFavTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Ensure consistent padding
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200], // Background color
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.ic_fav,
                  height: 16,
                  width: 16,
                  color: Colors.black87,
                ),
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
