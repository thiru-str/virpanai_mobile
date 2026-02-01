import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/create_customer_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/live_order_page.dart';
import 'package:waioz/ui/widgets/order_details.dart';
import 'package:waioz/ui/widgets/past_order_page.dart';
import 'package:waioz/utility/app_colors.dart';

import '../utility/app_assets.dart';
import '../utility/app_strings.dart';
import 'analytics_page.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;


  final List<Widget> _pages = [
    const LiveOrderPage(),
    const AnalyticsPage(),
    const CreateCustomerPage(),
    const PastOrderPage(),

  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // TODO: handle redirection based on index
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable default back behavior
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        // If not on the first tab, go back to the previous tab
        if (_selectedIndex > 0) {
          setState(() {
            _selectedIndex--; // Move to the previous tab
          });
          return; // Don't proceed to exit dialog
        }

        final shouldExit = await showDialog(
          context: context,
          builder: (context) => CommonAlertDialog(
              title: AppStrings.exitApp,
              content: AppStrings.exitDescription,
              contentOk: AppStrings.yes,
              contentCancel: AppStrings.no,
              onTapOk: () => Navigator.of(context).pop(true)),
        );
        if (shouldExit == true) {
          if (mounted) {
            SystemNavigator.pop(); // Close the app
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          child: Container(
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
