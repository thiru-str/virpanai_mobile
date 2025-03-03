import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class CustomScrollableTabBar extends StatelessWidget {
  final TabController tabController;
  final List<Widget> tabs;

  const CustomScrollableTabBar({
    Key? key,
    required this.tabController,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 40,
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          isScrollable: true, // Enable scrolling
          dividerColor: Colors.transparent, // Removes the bottom line in the TabBar
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.primary, // Highlight color for the selected tab
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
          ),
          splashFactory: NoSplash.splashFactory,
          labelStyle: FontUtils.primaryFontStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          unselectedLabelStyle: FontUtils.primaryFontStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          tabs: tabs,
          padding: const EdgeInsets.only(right: 40.0, left: 0), // Add padding for alignment
        ),
      ),
    );
  }
}
