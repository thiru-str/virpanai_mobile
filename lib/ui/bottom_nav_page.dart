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
import '../model/home_page_response.dart';
import '../model/register_response.dart';
import '../utility/shared_preferences_util.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  HomePageResponse? homePageResponse;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation for the bottom navigation bar
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from offscreen (bottom)
      end: Offset.zero, // Slide to its original position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Delay animation start by 300ms
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });

    initializePages();
  }

  Future<void> initializePages() async {
    try {
      await Future.wait([
        getCustomerApi(), // Wait for customer API
        getHomePageApi() // Wait for home page API
      ]);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error initializing pages: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
        return const HomePage(); // Create a new instance
      case 1:
        return const CategoryPage(isFromBottomNav: true);
      case 2:
        return const CartPage(isFromBottomNav: true);
      case 3:
        return const MyFavoritesPage(isFromBottomNav: true);
      case 4:
        return SettingsPage();
      default:
        return const HomePage();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : _getPage(), // Dynamically build the current page
      bottomNavigationBar: SlideTransition(
        position: _slideAnimation,
        child: BottomNavigationBar(
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
      ),
    );
  }


  Future<void> getCustomerApi() async {
    try {
      Customer? customer = await getCustomerResponse();
      if (customer == null) {
        final ApiService apiService = ApiService();
        CustomerResponse customerResponse = await apiService.getCustomer(context);
        await SharedPreferencesUtil().saveMap('customer', customerResponse.customer!.toJson());
      }
    } catch (e) {
      print("Error fetching customer: $e");
    }
  }

  Future<Customer?> getCustomerResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('customer');
    if (userData != null) {
      return Customer.fromJson(userData);
    }
    return null;
  }

  Future<void> getHomePageApi() async {
    try {
      final ApiService apiService = ApiService();
      homePageResponse = await apiService.getHomePage(context);
      await SharedPreferencesUtil().saveString('region_id', homePageResponse!.global!.regionId!);
      await SharedPreferencesUtil().saveString('cart_id', homePageResponse!.global!.cartId!);
      await SharedPreferencesUtil().saveString('currency_symbol', homePageResponse!.global!.currencySymbol!);
      await SharedPreferencesUtil().saveMap('global', homePageResponse!.global!.toJson());
    } catch (e) {
      print("Error fetching home page: $e");
    }
  }
}



