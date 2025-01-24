import 'package:flutter/material.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/address_list_page.dart';
import 'package:waioz/ui/edit_profile_page.dart';
import 'package:waioz/ui/my_favorites_page.dart';
import 'package:waioz/ui/orders_history_page.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/static_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/profile_item_widget.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Customer? customer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        children: [
          // Profile Section

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Container(
                    child: Center(
                      child: Text(
                          (customer?.firstName ?? "C").substring(0, 1), // The letter to display
                        style: FontUtils.circularStdStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Name and Email
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer != null
                                ? '${customer!.firstName!} ${customer!.lastName}'
                                : '',
                            style: FontUtils.circularStdStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            customer != null ? customer!.email! : '',
                            style: FontUtils.circularStdStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      // Edit Button
                      TextButton(
                        onPressed: () async {
                          final result = await PageRouteUtils.pushWithSlide(context, EditProfilePage());
                          if (result == true) {
                            setState(() {
                              getCustomerInfo();
                            });
                          }
                        },
                        child: Text(
                          AppStrings.edit,
                          style: FontUtils.circularStdStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Profile Items Section
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: AppStrings.address,
                    onTap: () {
                      PageRouteUtils.pushWithSlide(context, AddressListPage(onSelectedAddress: (address){
                      },));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: AppStrings.favourites,
                    onTap: () {
                      PageRouteUtils.pushWithSlide(context, MyFavoritesPage());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: AppStrings.orders,
                    onTap: () {
                      PageRouteUtils.pushWithSlide(context, OrdersHistoryPage());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: AppStrings.help,
                    onTap: () {
                      // Handle Address action
                      PageRouteUtils.pushWithSlide(context, const StaticPage(pageTitle: AppStrings.help));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: AppStrings.support,
                    onTap: () {
                      // Handle Address action
                      PageRouteUtils.pushWithSlide(context, const StaticPage(pageTitle: AppStrings.support));
                    },
                  ),
                ),
              ],
            ),
          ),
          // Sign Out Button
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: GestureDetector(
              onTap: () {
                _showLogout(this.context);
              },
              child: Text(
                AppStrings.signout,
                style: FontUtils.circularStdStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  Future<void> getCustomerInfo() async {
    customer = await getCustomerResponse();
    if (customer != null) {
      setState(() {
        customer;
      });
    }
  }

  Future<Customer?> getCustomerResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('customer');
    if (userData != null) {
      return Customer.fromJson(userData);
    }
    return null;
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: AppStrings.signout,
          content: AppStrings.signout_confirm_msg,
          contentOk: AppStrings.yes,
          contentCancel: AppStrings.no,
          onTapOk: () {
            // Handle sign out action
            SharedPreferencesUtil().clear();
            PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
          },
        );
      },
    );
  }
}
