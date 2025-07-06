import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';

import '../../utility/page_route_utils.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(
        title: 'Dashboard',
        showFilter: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderToggleSelector(
                  onSelected: (index) {
                    if (index == 0) {
                      print("Today Order selected");
                    } else {
                      print("Overall Order selected");
                    }
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
                    SvgPicture.asset(
                      AppAssets.order_bg,
                      height: 120,
                      fit: BoxFit.fitWidth,
                    ),
                    const Column(
                      children: [
                        Text(
                          'Ledger Balance',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹ 60,000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  child: SvgPicture.asset(
                    AppAssets.ic_chart,
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
                  children: const [
                    DashboardStatCard(
                      count: '48',
                      countLabel: 'Order',
                      title: 'Today’s Orders',
                      subtitle: 'Total number of orders placed today',
                    ),
                    DashboardStatCard(
                      count: '56',
                      countLabel: 'Order',
                      title: 'Delivered order',
                      subtitle: 'Total number of orders placed today',
                    ),
                    DashboardStatCard(
                      count: '20',
                      countLabel: 'Order',
                      title: 'Pending order',
                      subtitle: 'Orders yet to be delivered',
                    ),
                    DashboardStatCard(
                      count: '45',
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
}
