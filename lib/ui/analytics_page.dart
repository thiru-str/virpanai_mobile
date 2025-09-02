import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/dashboard_response.dart';
import 'package:waioz/ui/UserDetailsPage.dart';
import 'package:waioz/ui/customer_register_page.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/dashboard_state_card.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/order_toggle_selector.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/past_order_details.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/revenue_chart.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../utility/page_route_utils.dart';
import '../api/api_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool apiLoading = true;
  int _selectedIndex = 0;
  DashboardResponse? _dashboardResponse;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initApis();
  }

  Future<void> initApis() async {
    getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(
        title: 'Dashboard',
        showFilter: false,
      ),
      body: SafeArea(
        child: apiLoading?Center(child: CircularProgressIndicator(color: AppColors.primary,),):SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderToggleSelector(
                  onSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    getDashboardData();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Live Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Ledger Balance Card
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: SvgPicture.asset(
                        AppAssets.order_bg,
                        height: 120,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Ledger Balance',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          _dashboardResponse?.totalRevenue??'',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
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
                const SizedBox(height: 16),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TodayRevenueChart(heading:_selectedIndex == 0? 'Today Revenue':'Overall Revenue',data: _dashboardResponse?.graphData??[]), // just pass!
              ),
            ),
                const SizedBox(height: 16),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    DashboardStatCard(
                      count: _dashboardResponse?.totalOrders??0,
                      countLabel: 'Order',
                      title: 'Today’s Orders',
                      subtitle: 'Total number of orders placed today',
                    ),
                    DashboardStatCard(
                      count: _dashboardResponse?.deliveredOrders??0,
                      countLabel: 'Order',
                      title: 'Delivered order',
                      subtitle: 'Total number of orders placed today',
                    ),
                    DashboardStatCard(
                      count: _dashboardResponse?.pendingOrders??0,
                      countLabel: 'Order',
                      title: 'Pending order',
                      subtitle: 'Orders yet to be delivered',
                    ),
                    DashboardStatCard(
                      count: _dashboardResponse?.totalProducts??0,
                      countLabel: 'Order',
                      title: 'Total product',
                      subtitle: 'Total number of product placed today',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),

    );
  }

  void getDashboardData() async {
    try {
      String type = _selectedIndex == 0?'today':'over_all';
      final ApiService apiService = ApiService();
      final dashBoardResponse = await apiService.dashboard(context,type);
      setState(() {
        setState(() {
          _dashboardResponse = dashBoardResponse;
          apiLoading = false;
        });
      });

    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

}
