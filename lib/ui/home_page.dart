import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_page.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/ui/widgets/home/item_1.dart';
import 'package:waioz/ui/widgets/home/item_2.dart';
import 'package:waioz/ui/widgets/home/item_3.dart';
import 'package:waioz/ui/widgets/home/item_4.dart';
import 'package:waioz/ui/widgets/home/item_5.dart';
import 'package:waioz/ui/widgets/home/item_6.dart';
import 'package:waioz/ui/widgets/home/item_7.dart';
import 'package:waioz/ui/widgets/home/item_8.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';
import 'widgets/common_header_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  HomePageResponse? homePageResponse;
  CartResponse? cartResponse;
  bool apiLoading = true;

  int? cartItems;
  List<String>? cartItemImages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializePages();
    listenToEvents();
  }

  void listenToEvents() {
    eventBus.on<ViewCartModel>().listen((event) {
      setState(() {
        cartItems = event.totalItems;
        cartItemImages = event.itemImages;
      });
    });
  }

  Future<void> initializePages() async {
    getHomePageApi();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CommonHeaderAppBar(
        title: "Home",
        leading: false,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children:[ apiLoading? const Center(child: CircularProgressIndicator(color: AppColors.primary,),)
            :Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                scrollDirection: Axis.vertical,
                itemCount: homePageResponse!.content!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final homePageContent = homePageResponse!.content![index];
                  return getLayoutWidget(homePageContent);
                },
              ),
            ),
          Visibility(
            visible: cartItems!= null && cartItems != 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: cartItems!=null ?Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: GestureDetector(
                  onTap: (){
                    PageRouteUtils.pushWithSlide(context, const CartPage());
                  },
                  child: ViewCartWidget(
                    totalItems: cartItems!,
                    itemImages:  cartItemImages!
                  ),
                ),
              ): const SizedBox(),
            ),
          ),
        ],
      )
    );
  }

  Widget getLayoutWidget(Content homePageContent) {
    switch (homePageContent.layoutName) {
      case "item1":
        return Item1(content: homePageContent);
      case "item2":
        return Item2(content: homePageContent);
      case "item3":
        return Item3(content: homePageContent);
      case "item4":
        return Item4(content: homePageContent);
      case "item5":
        return Item5(content: homePageContent);
      case "item6":
        return Item6(content: homePageContent);
      case "item7":
        return Item7(content: homePageContent);
      case "item8":
        return Item8(content: homePageContent);
      default:
        return SizedBox();
    }
  }

  void getHomePageApi() async {
    try {
      final ApiService apiService = ApiService();
      homePageResponse = await apiService.getHomePage(context);
      SharedPreferencesUtil().saveString('region_id', homePageResponse!.global!.regionId!);
      SharedPreferencesUtil().saveString('cart_id', homePageResponse!.global!.cartId!);
      SharedPreferencesUtil().saveString('currency_symbol', homePageResponse!.global!.currencySymbol!);
      SharedPreferencesUtil().saveMap('global', homePageResponse!.global!.toJson());
      setState(() {
        apiLoading = false;
        homePageResponse;
      });
      getCartApi();
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void getCartApi() async {
    try {
      final ApiService apiService = ApiService();
      cartResponse = await apiService.getCart(context);
      setState(() {
        cartItems = cartResponse!.cart!.items!.length;
        cartItemImages = cartResponse!.cart!.items!.map((item) => item.thumbnail!).toList();
      });
    } catch (e) {
      print(e);
    }
  }

}
