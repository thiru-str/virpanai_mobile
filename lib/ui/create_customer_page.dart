import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/model/customer_list_response.dart';
import 'package:waioz/ui/UserDetailsPage.dart';
import 'package:waioz/ui/customer_register_page.dart';
import 'package:waioz/ui/phone_number_page.dart';
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
  List<Customer>? _filteredCustomers; // for local search
  bool apiLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initApis();

    // Listen to search text changes
    _searchController.addListener(() {
      _filterCustomers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> initApis() async {
    getApis();
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = _customerListResponse?.customers;
      });
    } else {
      final allCustomers = _customerListResponse?.customers ?? [];
      final filtered = allCustomers.where((c) {
        final name = c.metadata?.shopName?.toLowerCase() ?? '';
        final phone = c.phone?.toLowerCase() ?? '';
        final email = c.email?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            phone.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();

      setState(() {
        _filteredCustomers = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return apiLoading
        ? Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    )
        : GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
          child: Scaffold(
                backgroundColor: Colors.white,
                appBar: const CommonAppBar(
          title: 'Customer List',
          showFilter: false,
                ),
                body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔎 Search Bar

              Visibility(
                visible: (_customerListResponse?.customers??[]).isNotEmpty,
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search customers...",
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                                _filterCustomers(""); // reset
                              },
                            )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: (_filteredCustomers?.isEmpty ?? true)
                    ? const Center(
                  child: EmptyView(
                    imageAsset: AppAssets.ic_no_list,
                    title: 'No Customers found',
                    description: 'Try a different search term',
                    imageHeight: 150,
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredCustomers?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = _filteredCustomers?[index];
                    return GestureDetector(
                      onTap: () {
                        PageRouteUtils.push(
                          context,
                          CustomerDetailPage(customer: item),
                        );
                      },
                      child: StoreContactCard(
                        imageUrl:
                        item?.metadata?.shopNameBoardImage ?? '',
                        storeName: item?.metadata?.shopName ?? '',
                        address: item?.metadata?.postalCode ?? '',
                        phoneNumber: '+91 ${item?.phone ?? ''}',
                        email: item?.email ?? '',
                      ),
                    );
                  },
                ),
              )
            ],
          ),
                ),
                floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await PageRouteUtils.push(
              context,
              const PhoneNumberPage(),
            );
            if (result == true) {
              getApis();
            }
          },
          backgroundColor: const Color(0xFF005B65),
          child: const Icon(Icons.add, color: Colors.white),
                ),
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
        _filteredCustomers = customerListResponse.customers; // init filter list
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

