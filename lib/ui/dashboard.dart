import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/widgets/live_order_page.dart';
import 'package:waioz/utility/app_colors.dart';

import '../utility/app_assets.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;


  final List<Widget> _pages = [
    const LiveOrderPage(),
    const LiveOrderPage(),
    const LiveOrderPage(),
    const LiveOrderPage(),

  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // TODO: handle redirection based on index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2), // Slight shadow at top
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary, // primary green
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items:  [
            BottomNavigationBarItem(
              icon: svgIcon(AppAssets.menu_1, Colors.black54),
              activeIcon: svgIcon(AppAssets.menu_1, AppColors.primary),
              label: 'Live Order',
            ),
            BottomNavigationBarItem(
              icon: svgIcon(AppAssets.menu_2, Colors.black54),
              activeIcon: svgIcon(AppAssets.menu_2, AppColors.primary),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: svgIcon(AppAssets.menu_3, Colors.black54),
              activeIcon: svgIcon(AppAssets.menu_3, AppColors.primary),
              label: 'Customer',
            ),
            BottomNavigationBarItem(
              icon: svgIcon(AppAssets.menu_4, Colors.black54),
              activeIcon: svgIcon(AppAssets.menu_4, AppColors.primary),
              label: 'Past Order',
            ),
          ],
        ),
      ),

    );

  }

  SvgPicture svgIcon(String asset, Color color) {
    return SvgPicture.asset(
      asset,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }








}
