import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/address_list_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/add_address_page.dart';
import 'package:waioz/ui/widgets/address_card.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_strings.dart';

import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';

class AddressListPage extends StatefulWidget {

  final Function(Address address) onSelectedAddress;
  final bool isFromCheckout;
  const AddressListPage({super.key,required this.onSelectedAddress,this.isFromCheckout = false});

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

  @override
  void dispose() {
    super.dispose();
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
          : addressListResponse?.addresses?.isNotEmpty ?? false
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
                            return GestureDetector(
                              child: AddressCard(
                                title: address?.addressName ??
                                    'Others', // If address name is null, show 'Untitled'
                                address:
                                    '${address?.address1}, ${address?.city}, ${address?.province}, ${address?.postalCode}',
                                icon: address?.addressName == "Home" ? Icons.home : address?.addressName == "Work" ? Icons.work : Icons.location_pin, // Or choose another icon based on address data
                                onDelete: () {
                                  _showDeleteDialog(context, address?.id);
                                },
                                onEdit: () async {
                                  final result = await PageRouteUtils.push(
                                      context,
                                      AddAddressPage(
                                        selectedAddress: address,
                                      ));
                                  if (result == true) {
                                    getAddressListApi();
                                  }
                                },
                              ),
                              onTap: (){
                                if(widget.isFromCheckout) {
                                  widget.onSelectedAddress(address!);
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await PageRouteUtils.push(
                                  context,
                                  AddAddressPage());
                              if (result == true) {
                                getAddressListApi();
                              }
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
                  message: AppStrings.no_address_yet,
                  buttonText: AppStrings.add_address,
                  iconPath: AppAssets.ic_cart_empty,
                  onButtonTap: () async {
                    final result = await PageRouteUtils.push(
                        context,
                        AddAddressPage());
                    if (result == true) {
                      getAddressListApi();
                    }
                  },
                ),
    );
  }

  void getAddressListApi() async {
    try {
      final ApiService apiService = ApiService();
      var response = await apiService.getAddressList(context);
      if (mounted) {
        setState(() {
          addressListResponse = response;
          apiLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiLoading = false;
        });
      }
      print(e);
    }
  }

  void _showDeleteDialog(BuildContext context, String? addressID) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: "Confirm Deletion",
          content: "Are you sure you want to delete this address?",
          contentOk: "Yes",
          contentCancel: "No",
          onTapOk: () {
            print("OK");
            Navigator.pop(context);
            deleteAddress(addressID); // Call deleteAddress when confirmed
          },
        );
      },
    );
  }

  void deleteAddress(String? addressID) async {
    try {
      final ApiService apiService = ApiService();
      await apiService.deleteAddress(context, addressID);
      setState(() {
        apiLoading = false;
        getAddressListApi(); // Refresh the address list after deletion
      });
    } catch (e) {
      setState(() {
        apiLoading = false;
      });
      print(e);
    }
  }
}
