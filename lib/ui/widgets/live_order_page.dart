import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/dealer_response.dart';
import 'package:waioz/model/live_order_response.dart';
import 'package:waioz/ui/pending_order_details.dart';
import 'package:waioz/ui/profile_page.dart';
import 'package:waioz/ui/widgets/clear_pending_orders.dart';
import 'package:waioz/ui/widgets/empty_view.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../../api/api_service.dart';
import '../../model/view_cart_model.dart';
import '../../utility/page_route_utils.dart';
import 'order_details.dart';

class LiveOrderPage extends StatefulWidget {
  const LiveOrderPage({Key? key}) : super(key: key);

  @override
  State<LiveOrderPage> createState() => _LiveOrderPageState();
}

class _LiveOrderPageState extends State<LiveOrderPage> {

  final ApiService apiService = ApiService();
  LiveOrdersResponse? _liveOrdersResponse;
  DealerResponse? _dealerResponse;
  bool apiLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initApis();
  }

  Future<void> initApis() async {
    getApis();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: apiLoading? Center(child: CircularProgressIndicator(color: AppColors.primary,),):ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Hello!',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _dealerResponse?.dealer?.name ?? '',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    IconButton(onPressed: (){
                      PageRouteUtils.pushWithFade(
                          context,
                        ProfilePage()
                          );
                    }, icon: Icon(Icons.account_circle_outlined,color: AppColors.primary,size: 32,))
                  ]),
                  const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Live Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Ledger Balance Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    (_liveOrdersResponse?.rawLedgerBalance??0)>=0?AppAssets.order_bg:AppAssets.order_bg_red,
                    height: 120,
                    fit: BoxFit.fill,
                  ),
              Column(
                    children: [
                      GestureDetector(
                        onTap: (){
                          showPendingOrdersDialog(context);
                        },
                        child: const Text(
                          'Ledger Balance',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Text(
                        _liveOrdersResponse?.ledgerBalance??'',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Total Value Of All Orders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            (_liveOrdersResponse?.liveOrders?.length??0) == 0?const EmptyView(imageAsset: AppAssets.ic_no_list, title: 'No Live Orders', description: 'You currently don\'t have any live orders',imageHeight: 150,):ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _liveOrdersResponse?.liveOrders?.length??0,
              itemBuilder: (context, index) {
                final item = _liveOrdersResponse?.liveOrders?[index];
                return GestureDetector(
                  onTap: (){
                    PageRouteUtils.pushWithFade(
                        context,OrderDetailsPage(orderId: item?.id??'',isFromLiveOrder: true,));
                  },
                  child: OrderItemCard(
                    imageUrl: item?.shopImage??'',
                    storeName: item?.shopName??'',
                    storeAddress: item?.shopAddress??'',
                    productCount: item?.noOfProducts??'',
                    totalPrice: item?.totalPrice??'',
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void getApis() async {
    try {
      final ApiService apiService = ApiService();
      final dealerResponse = await apiService.getDealerDetails(context);
      if (dealerResponse != null) {
       await SharedPreferencesUtil().saveMap('dealer_info', dealerResponse.toJson());
      }
      final liveOrderResponse = await apiService.liveOrders(context);
      setState(() {
        _dealerResponse = dealerResponse;
        _liveOrdersResponse = liveOrderResponse;
        apiLoading = false;
        if(_liveOrdersResponse?.hasPending??false)
          {
            showPendingOrdersDialog(context);
          }
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void showPendingOrdersDialog(BuildContext context,) {
    showDialog(
      barrierDismissible: false,
      context: context,
        builder: (BuildContext context) {

          eventBus.on<ClosePendingOrdersDialogEvent>().listen((event) {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
          });

          return ClearPendingOrdersDialog(
            onJoin: () async {
              PageRouteUtils.push(context, const PendingOrderDetailsPage());
            },
          );
        },
    );
  }
}
