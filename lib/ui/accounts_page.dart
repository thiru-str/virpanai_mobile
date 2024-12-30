import 'package:flutter/material.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/address_list_page.dart';
import 'package:waioz/ui/my_favorites_page.dart';
import 'package:waioz/ui/orders_history_page.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/profile_item_widget.dart';
import 'package:waioz/utility/app_colors.dart';
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
      body: Column(
        children: [
          // Profile Section
          const SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  /*backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150', // Replace with actual image URL
                  ),*/
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Name and Email
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer!= null?'${customer!.firstName!} ${customer!.lastName}':'',
                            style: FontUtils.circularStdStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            customer!= null?customer!.email!:'',
                            style: FontUtils.circularStdStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      // Edit Button
                      TextButton(
                        onPressed: () {
                          // Edit action
                        },
                        child: Text(
                          'Edit',
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
                    title: 'Address',
                    onTap: () {
                      PageRouteUtils.push(context, AddressListPage());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: 'Favourites',
                    onTap: () {
                      PageRouteUtils.push(context, MyFavoritesPage());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: 'Order',
                    onTap: () {
                      PageRouteUtils.push(context, OrdersHistoryPage());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: 'Help',
                    onTap: () {
                      // Handle Address action
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileItemWidget(
                    title: 'Support',
                    onTap: () {
                      // Handle Address action
                    },
                  ),
                ),
              ],
            ),
          ),
          // Sign Out Button
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: GestureDetector(
              onTap: () {
                SharedPreferencesUtil().clear();
                PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
                //_showLogout(context);
              },
              child: Text(
                'Sign Out',
                style: FontUtils.circularStdStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
          title: 'Sign Out',
          content: 'Are you sure you want to log out?',
          contentOk: 'Yes',
          contentCancel: 'No',
          onTapOk: () {
            // Handle sign out action
            SharedPreferencesUtil().clear();
            PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
          },
          onTapCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }
}


