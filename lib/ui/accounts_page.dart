import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/model/store_content_response.dart';
import 'package:waioz/ui/address_list_page.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
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
  List<ContentData> storeContentList = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomerInfo();
    fetchStoreContentAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Container(
                    child: Center(
                      child: Text(
                          (customer?.firstName ?? "C")
                              .substring(0, 1), // The letter to display
                          style: FontUtils.primaryFontStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer != null
                                  ? '${customer?.firstName} ${customer?.lastName}'
                                  : '',
                              overflow: TextOverflow.ellipsis,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              customer?.email ?? "",
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Button
                      TextButton(
                        onPressed: () async {
                          final result = await PageRouteUtils.pushWithSlide(
                              context, EditProfilePage());
                          if (result == true) {
                            setState(() {
                              getCustomerInfo();
                            });
                          }
                        },
                        child: Text(
                          AppStrings.edit,
                          style: FontUtils.primaryFontStyle(
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
            child: isLoading? Center(child: CircularProgressIndicator(color: AppColors.primary,)):ListView(
              children: [
                _buildProfileItem(AppStrings.address, () {
                  PageRouteUtils.pushWithSlide(context,
                      AddressListPage(onSelectedAddress: (address) {}));
                }),
                _buildProfileItem(AppStrings.favourites, () {
                  PageRouteUtils.pushWithSlide(context, MyFavoritesPage());
                }),
                _buildProfileItem(AppStrings.orders, () {
                  PageRouteUtils.pushWithSlide(context, OrdersHistoryPage());
                }),
                ...storeContentList.map((contentItem) =>
                    _buildProfileItem(contentItem.name ?? "Unknown", () {
                      if (contentItem.content?.data != null) {
                        PageRouteUtils.pushWithSlide(
                          context,
                          StaticPage(
                              pageTitle: contentItem.name ?? "",
                              htmlData: contentItem.content!.data!),
                        );
                      }
                    })),
                _buildProfileItem(
                  AppStrings.deleteAccount,
                  () => _showDeleteAccount(context), // use separate method
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
                style: FontUtils.primaryFontStyle(
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

  Widget _buildProfileItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ProfileItemWidget(
        title: title,
        onTap: onTap,
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

  Future<void> fetchStoreContentAPI() async {
    try {
      setState(() {
        isLoading = true;
      });
      final storeContent = await ApiService().getStoreContent(context);
      setState(() {
            storeContentList = storeContent.data ?? [];
          });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
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
          onTapOk: () async {
            bool skipLogin =
                await SharedPreferencesUtil().getBool('skip_login') ?? false;
            // Handle sign out action
            await SharedPreferencesUtil().clear();
            if (mounted) {
              PageRouteUtils.pushAndRemoveUntil(
                  context, skipLogin ? const BottomNavPage() : WelcomePage());
            }
          },
        );
      },
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: AppStrings.deleteAccount,
          content: "Are you sure you want to permanently delete your account?",
          contentOk: AppStrings.yes,
          contentCancel: AppStrings.no,
          onTapOk: () async {
            await ApiService().deleteAccount(context);

            bool skipLogin =
                await SharedPreferencesUtil().getBool('skip_login') ?? false;
            // Handle sign out action
            await SharedPreferencesUtil().clear();
            if (mounted) {
              PageRouteUtils.pushAndRemoveUntil(
                  context, skipLogin ? const BottomNavPage() : WelcomePage());
            }
          },
        );
      },
    );
  }
}
