import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showFilter;
  final VoidCallback? onBackTap;
  final VoidCallback? onFilterTap;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.showBack = false,
    this.showFilter = false,
    this.onBackTap,
    this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: showBack
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: onBackTap ?? () => Navigator.pop(context),
        )
            : null,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (showFilter)
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.black),
              onPressed: onFilterTap,
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
