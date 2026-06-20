import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/app_loader.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/address_list_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/add_address_page.dart';
import 'package:waioz/ui/map_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_strings.dart';

import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';
import '../utility/ui_typography.dart';

class AddressListPage extends StatefulWidget {
  final Function(Address address) onSelectedAddress;
  final bool isFromCheckout;
  const AddressListPage(
      {super.key,
      required this.onSelectedAddress,
      this.isFromCheckout = false});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: CommonHeaderAppBar(
        title: AppStrings.my_address,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiLoading
          ? const AppLoader()
          : addressListResponse?.addresses?.isNotEmpty ?? false
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: addressListResponse?.addresses?.length ?? 0,
                        itemBuilder: (context, index) {
                          Address? address =
                              addressListResponse?.addresses?[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildAddressCard(context, address),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top: BorderSide(
                                  color: Color(0xFFE5E7EC), width: 1)),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            bool? isGoogleMapUsage =
                                await SharedPreferencesUtil()
                                        .getBool('google_map_usage') ??
                                    false;
                            final result = await PageRouteUtils.pushWithSlide(
                                context,
                                isGoogleMapUsage
                                    ? MapPage(
                                        doublePop: true,
                                        intent: MapPageIntent.saveAddress,
                                      )
                                    : AddAddressPage());
                            if (result == true) {
                              getAddressListApi();
                            }
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            AppStrings.add_address,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : NoOrdersWidget(
                  message: AppStrings.no_address_yet,
                  buttonText: AppStrings.add_address,
                  iconPath: AppAssets.ic_cart_empty,
                  onButtonTap: () async {
                    bool? isGoogleMapUsage = await SharedPreferencesUtil()
                            .getBool('google_map_usage') ??
                        false;
                    final result = await PageRouteUtils.pushWithSlide(
                        context,
                        isGoogleMapUsage
                            ? MapPage(
                                doublePop: true,
                                intent: MapPageIntent.saveAddress)
                            : AddAddressPage());
                    if (result == true) {
                      getAddressListApi();
                    }
                  },
                ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address? address) {
    final IconData icon = address?.addressName == "Home"
        ? Icons.home
        : address?.addressName == "Work"
            ? Icons.work
            : Icons.location_pin;
    final bool showActions = !widget.isFromCheckout;
    final bool isDefault = address?.isDefaultShipping == true;
    final String addressText =
        '${address?.address1}, ${address?.city}, ${address?.province}, ${address?.postalCode}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (widget.isFromCheckout) {
            widget.onSelectedAddress(address!);
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      address?.addressName ?? 'Others',
                      style: UiTypography.cardTitle().copyWith(
                        fontSize: 16,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Default',
                        style: UiTypography.cardMeta(color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                  addressText,
                  style: UiTypography.cardSubtitle().copyWith(height: 1.4),
                ),
              ),
              if (showActions) ...[
                const SizedBox(height: 12),
                const Divider(
                    height: 1, thickness: 1, color: Color(0xFFE5E7EC)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        bool? isGoogleMapUsage = await SharedPreferencesUtil()
                                .getBool('google_map_usage') ??
                            false;
                        final result = await PageRouteUtils.pushWithSlide(
                            context,
                            isGoogleMapUsage
                                ? MapPage(
                                    doublePop: true,
                                    isEditAddress: true,
                                    selectedAddress: address,
                                    latitude: double.tryParse(
                                            address?.metadata?.latitude ??
                                                '') ??
                                        0.0,
                                    longitude: double.tryParse(
                                            address?.metadata?.longitude ??
                                                '') ??
                                        0.0,
                                    intent: MapPageIntent.saveAddress)
                                : AddAddressPage(
                                    selectedAddress: address,
                                  ));
                        if (result == true) {
                          getAddressListApi();
                        }
                      },
                      icon: Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.primary),
                      label: Text(
                        AppStrings.edit,
                        style:
                            UiTypography.cardAction(color: AppColors.primary),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _showDeleteDialog(context, address?.id);
                      },
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Color(0xFFE5484D)),
                      label: Text(
                        AppStrings.delete,
                        style: UiTypography.cardAction(
                            color: const Color(0xFFE5484D)),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
          title: AppStrings.confirm_deletion,
          content: AppStrings.sure_delete_address,
          contentOk: AppStrings.yes,
          contentCancel: AppStrings.no,
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
