import 'package:flutter/material.dart';
import 'package:waioz/model/customer_response.dart';
import 'package:waioz/ui/accounts_page.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/category_page.dart';
import 'package:waioz/ui/home_page.dart';
import 'package:waioz/ui/my_favorites_page.dart';
import 'package:waioz/ui/widgets/address_card.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../api/api_service.dart';
import '../model/register_response.dart';
import '../utility/shared_preferences_util.dart';

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
    HomePage(),
    CategoryPage(),
    CartPage(),
    MyFavoritesPage(isFromBottomNav: true,),
    SettingsPage()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomerApi();
  }

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

  void getCustomerApi() async {
    try {
      Customer? customer = await getCustomerResponse();
      if(customer==null) {
        final ApiService apiService = ApiService();
        CustomerResponse customerResponse = await apiService.getCustomer(
            context);
        SharedPreferencesUtil()
            .saveMap('customer', customerResponse.customer!.toJson());
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Customer?> getCustomerResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('customer');
    if (userData != null) {
      return Customer.fromJson(userData);
    }
    return null;
  }
}


