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

  final int _limit = 20;
  int _offset = 0;

  bool _isFetchingMore = false;
  bool _hasMore = true;

  final List<Customer> _allCustomers = [];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);
    initApis();

    _searchController.addListener(() {
      _filterCustomers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCustomers({bool isInitial = false}) async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;

    final response = await ApiService().getCustomerList(
      context,
      limit: _limit,
      offset: _offset,
    );

    final newCustomers = response.customers ?? [];

    setState(() {
      if (isInitial) {
        _allCustomers.clear();
        _offset = 0;
      }

      _allCustomers.addAll(newCustomers);
      _offset += newCustomers.length;

      _hasMore = _allCustomers.length < (response.count ?? 0);

      _customerListResponse = response;
      _filteredCustomers = _applySearch(
        _searchController.text,
        _allCustomers,
      );

      _isFetchingMore = false;
      apiLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore &&
        _searchController.text.isEmpty) {
      fetchCustomers();
    }
  }

  Future<void> initApis() async {
    setState(() {
      apiLoading = true;
    });

    await fetchCustomers(isInitial: true);
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _applySearch(query, _allCustomers);
    });
  }

  List<Customer> _applySearch(String query, List<Customer> source) {
    if (query.isEmpty) return List.from(source);

    final q = query.toLowerCase();

    return source.where((c) {
      final name = c.metadata?.shopName?.toLowerCase() ?? '';
      final phone = c.phone?.toLowerCase() ?? '';
      final email = c.email?.toLowerCase() ?? '';

      return name.contains(q) ||
          phone.contains(q) ||
          email.contains(q);
    }).toList();
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
                  controller: _scrollController,
                  itemCount: _filteredCustomers!.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _filteredCustomers!.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final item = _filteredCustomers![index];

                    return GestureDetector(
                      onTap: () {
                        PageRouteUtils.push(
                          context,
                          CustomerDetailPage(customer: item),
                        );
                      },
                      child: StoreContactCard(
                        imageUrl: item.metadata?.shopNameBoardImage ?? '',
                        storeName: item.metadata?.shopName ?? '',
                        address: item.metadata?.postalCode ?? '',
                        phoneNumber: '+91 ${item.phone ?? ''}',
                        email: item.email ?? '',
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
              _resetAndReload();
            }
          },
          backgroundColor: const Color(0xFF005B65),
          child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
        );
  }

  void _resetAndReload() {
    setState(() {
      _offset = 0;
      _hasMore = true;
      _isFetchingMore = false;

      _allCustomers.clear();
      _filteredCustomers?.clear();
    });

    fetchCustomers(isInitial: true);
  }

}

