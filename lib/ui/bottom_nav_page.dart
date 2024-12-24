import 'package:flutter/material.dart';
import 'package:waioz/ui/accounts_page.dart';
import 'package:waioz/ui/widgets/address_card.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _currentIndex = 0;

  // Define static titles for each page
  final List<String> _titles = [
    'Shop',
    'Categories',
    'Cart',
    'Favourite',
    'Account',
  ];

  // Pages for each tab
  final List<Widget> _pages = [
    const Center(child: Text('Shop Page')),
    const Center(child: Text('Categories Page')),
    const Center(child: Text('Cart Page')),
    const Center(child: Text('Favourite Page')),
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex], // Render the current page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update selected tab
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(AppAssets.ic_menu_shop)),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(AppAssets.ic_menu_categories)),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(AppAssets.ic_menu_cart)),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(AppAssets.ic_menu_favourite)),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage(AppAssets.ic_menu_account)),
            label: 'Account',
          ),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.tabInActivecolor,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: FontUtils.circularStdStyle(),
        unselectedLabelStyle: FontUtils.circularStdStyle(),
      ),
    );
  }
}
