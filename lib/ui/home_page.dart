import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/ui/widgets/category_card.dart';
import 'package:waioz/ui/widgets/home/item_1.dart';
import 'package:waioz/ui/widgets/home/item_2.dart';
import 'package:waioz/ui/widgets/home/item_3.dart';
import 'package:waioz/ui/widgets/home/item_4.dart';
import 'package:waioz/ui/widgets/home/item_5.dart';
import 'package:waioz/ui/widgets/home/item_6.dart';
import 'package:waioz/ui/widgets/home/item_7.dart';
import 'package:waioz/ui/widgets/home/item_8.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  HomePageResponse? homePageResponse;
  bool apiLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHomePageApi();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
      title: Text('Home',style: FontUtils.gabaritoStyle(fontWeight: FontWeight.bold,fontSize: 18),),centerTitle: true,),
      backgroundColor: Colors.white,
      body: apiLoading? const Center(child: CircularProgressIndicator(color: AppColors.primary,),)
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
      SharedPreferencesUtil().saveMap('global', homePageResponse!.global!.toJson());
      setState(() {
        apiLoading = false;
        homePageResponse;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
