import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/customer_list_response.dart';
import 'package:waioz/ui/UserDetailsPage.dart';
import 'package:waioz/ui/customer_register_page.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/customer_detail_page.dart';
import 'package:waioz/ui/widgets/empty_view.dart';
import 'package:waioz/ui/widgets/order_item_card.dart';
import 'package:waioz/ui/widgets/past_order_card.dart';
import 'package:waioz/ui/widgets/past_order_details.dart';
import 'package:waioz/ui/widgets/product_card.dart';
import 'package:waioz/ui/widgets/products_card.dart';
import 'package:waioz/ui/widgets/store_contact_card.dart';
import 'package:waioz/ui/widgets/store_summary_card.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../utility/page_route_utils.dart';
import '../api/api_service.dart';

class CreateCustomerPage extends StatefulWidget {
  const CreateCustomerPage({Key? key}) : super(key: key);

  @override
  State<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends State<CreateCustomerPage> {
  CustomerListResponse? _customerListResponse;
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
    return apiLoading
        ? Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: const CommonAppBar(
              title: 'Customer List',
              showFilter: false,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (_customerListResponse?.customers?.length ?? 0) == 0
                        ? const EmptyView(
                            imageAsset: AppAssets.ic_no_list,
                            title: 'No Customers yet',
                            description:
                                'You currently don\'t have any customers',
                            imageHeight: 150,
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                _customerListResponse?.customers?.length ?? 0,
                            itemBuilder: (context, index) {
                              final item =
                                  _customerListResponse?.customers?[index];
                              return GestureDetector(
                                onTap: () {
                                  PageRouteUtils.push(
                                      context,
                                      CustomerDetailPage(
                                        customer: item,
                                      ));
                                },
                                child: StoreContactCard(
                                  imageUrl:
                                      item?.metadata?.shopNameBoardImage ?? '',
                                  storeName: item?.metadata?.shopName ?? '',
                                  address: item?.metadata?.address ?? '',
                                  phoneNumber: '+91 ${item?.phone ?? ''}',
                                  email: ' ${item?.email ?? ''}',
                                ),
                              );
                            },
                          )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // Add your action here (e.g., navigate to a new customer form)
                final result = await PageRouteUtils.push(
                    context,
                    const CustomerRegisterPage(
                        countryCode: '', phoneNo: '', token: ''));
                if (result == true) {
                  getApis();
                }
              },
              backgroundColor: const Color(0xFF005B65), // Dark teal color
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
  }

  void getApis() async {
    try {
      setState(() {
        apiLoading = true;
      });
      final ApiService apiService = ApiService();
      final customerListResponse = await apiService.getCustomerList(context);
      setState(() {
        _customerListResponse = customerListResponse;
        apiLoading = false;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
