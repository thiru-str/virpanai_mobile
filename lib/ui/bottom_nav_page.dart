import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/model/customer_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/accounts_page.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/category_page.dart';
import 'package:waioz/ui/home_page.dart';
import 'package:waioz/ui/my_favorites_page.dart';
import 'package:waioz/ui/widgets/screen_skeletons.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../api/api_service.dart';
import '../model/home_page_response.dart';
import '../model/register_response.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  HomePageResponse? homePageResponse;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  int? cartItems;
  late StreamSubscription<ViewCartModel> _eventSubscription;
  late StreamSubscription<TabSwitchEvent> _tabSwitchSub;
  bool isLoggedIn = false;

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

    AppUtils.isLoggedIn().then((value) {
      setState(() {
        isLoggedIn = value;
      });
      initializePages();
      listenToEvents();
    });
  }

  void listenToEvents() {
    _eventSubscription = eventBus.on<ViewCartModel>().listen((event) {
      if (mounted) {
        setState(() {
          cartItems = event.totalItems;
        });
      }
    });
    _tabSwitchSub = eventBus.on<TabSwitchEvent>().listen((event) {
      if (mounted) {
        setState(() {
          _currentIndex = event.tabIndex;
        });
      }
    });
  }

  Future<void> initializePages() async {
    try {
      await Future.wait([
        getCustomerApi(), // Wait for customer API
        getReturnsApi()
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
        return isLoggedIn ? SettingsPage() : const HomePage();
      default:
        return const HomePage();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _eventSubscription
        .cancel(); // Cancel the subscription to prevent memory leaks
    _tabSwitchSub.cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Disable default back behavior
        onPopInvoked: (bool didPop) async {
          if (didPop) return;

          // If not on the first tab, go back to the previous tab
          if (_currentIndex > 0) {
            setState(() {
              _currentIndex--; // Move to the previous tab
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
          backgroundColor: const Color(0xFFF9F9FB),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _isLoading
                ? const ShellSkeleton()
                : KeyedSubtree(
                    key: ValueKey(_currentIndex),
                    child: _getPage(),
                  ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(0.06)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index; // Update selected tab
                  });
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage(AppAssets.ic_menu_shop)),
                    label: AppStrings.shop,
                  ),
                  const BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage(AppAssets.ic_menu_categories)),
                    label: AppStrings.categories,
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        const ImageIcon(AssetImage(AppAssets.ic_menu_cart)),
                        if ((cartItems ?? 0) > 0)
                          Positioned(
                            right: -4,
                            top: -3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5484D),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                cartItems! > 99 ? '99+' : cartItems!.toString(),
                                style: FontUtils.primaryFontStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: AppStrings.cart,
                  ),
                  if (isLoggedIn)
                    const BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(AppAssets.ic_menu_favourite)),
                      label: AppStrings.favourite,
                    ),
                  if (isLoggedIn)
                    const BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(AppAssets.ic_menu_account)),
                      label: AppStrings.account,
                    ),
                ],
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.tabInActivecolor,
                showUnselectedLabels: true,
                backgroundColor: Colors.white,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                selectedLabelStyle: FontUtils.primaryFontStyle(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: FontUtils.primaryFontStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )),
        ));
  }

  Future<void> getCustomerApi() async {
    try {
      if (!isLoggedIn) {
        debugPrint('calling here');
        return;
      }

      Customer? customer = await getCustomerResponse();
      if (customer == null) {
        final ApiService apiService = ApiService();
        CustomerResponse customerResponse =
            await apiService.getCustomer(context);
        await SharedPreferencesUtil()
            .saveMap('customer', customerResponse.customer!.toJson());
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
      await SharedPreferencesUtil()
          .saveString('region_id', homePageResponse!.global!.regionId!);
      await SharedPreferencesUtil()
          .saveString('cart_id', homePageResponse!.global!.cartId!);
      await SharedPreferencesUtil().saveString(
          'currency_symbol', homePageResponse!.global!.currencySymbol!);
      await SharedPreferencesUtil()
          .saveMap('global', homePageResponse!.global!.toJson());
    } catch (e) {
      print("Error fetching home page: $e");
    }
  }

  Future<void> getReturnsApi() async {
    try {
      final ApiService apiService = ApiService();
      final response = await apiService.getReturnReasons(context);
      await SharedPreferencesUtil()
          .saveJson('return_reasons', response.returnReasons ?? []);
    } catch (e) {
      print("Error fetching home page: $e");
    }
  }
}
