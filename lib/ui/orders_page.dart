import 'package:flutter/material.dart';
import 'package:waioz/ui/ongoing_order_page.dart';
import 'package:waioz/ui/past_orders_page.dart';
import 'package:waioz/ui/products_page.dart';
import 'package:waioz/ui/products_page_review.dart';
import 'package:waioz/utility/AppColors.dart';



class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              // TabBar in Row with search bar
              const Expanded(
                child: TabBar(
                  isScrollable: true,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  indicatorColor: AppColors.primary,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Order'),
                    Tab(text: 'Ongoing Orders'),
                    Tab(text: 'Past Order'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 200,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.greyBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Separate TabBarView in the body
        body: TabBarView(
          children: [
            // Each Tab's page goes here
            CreateOrderPage(),
            const OngoingOrderPage(),
            PastOrdersPage(),
          ],
        ),
      ),
    );
  }
}


