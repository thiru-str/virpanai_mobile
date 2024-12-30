import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/address_list_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/add_address_page.dart';
import 'package:waioz/ui/widgets/address_card.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_strings.dart';

import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  GetAddressListResponse? addressListResponse;
  bool apiLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddressListApi();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.my_address,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : addressListResponse?.addresses?.length != 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 16.0),
                          itemCount: addressListResponse?.addresses?.length ??
                              0, // Dynamic count of AddressCard widgets
                          itemBuilder: (context, index) {
                            Address? address =
                                addressListResponse?.addresses?[index];
                            return AddressCard(
                              title: address?.addressName ??
                                  'Others', // If address name is null, show 'Untitled'
                              address:
                                  '${address?.address1}, ${address?.city}, ${address?.province}, ${address?.postalCode}',
                              icon: Icons
                                  .home, // Or choose another icon based on address data
                              onDelete: () {
                                deleteAddress(address?.id);
                              },
                              onEdit: () {
                                PageRouteUtils.push(
                                    context,
                                    AddAddressPage(
                                      selectedAddress: address,
                                    ));
                              },
                            );
                          },
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              PageRouteUtils.push(context, AddAddressPage());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              minimumSize: const Size(
                                  double.infinity, 52), // Full-width button
                            ),
                            child: Text(
                              AppStrings.add_address,
                              style: FontUtils.circularStdStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : NoOrdersWidget(
                  message: "message",
                  buttonText: AppStrings.add_address,
                  iconPath: "iconPath",
                  onButtonTap: () {},
                ),
    );
  }

  void getAddressListApi() async {
    try {
      final ApiService apiService = ApiService();
      addressListResponse = await apiService.getAddressList(context);
      setState(() {
        apiLoading = false;
        addressListResponse;
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }

  void deleteAddress(String? addressID) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.deleteAddress(context, addressID);
      setState(() {
        apiLoading = false;
        getAddressListApi();
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
