import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/ui/widgets/app_loader.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/model/store_content_response.dart';
import 'package:waioz/ui/address_list_page.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/edit_profile_page.dart';
import 'package:waioz/ui/my_favorites_page.dart';
import 'package:waioz/ui/loyalty_page.dart';
import 'package:waioz/ui/orders_history_page.dart';
import 'package:waioz/ui/wallet_page.dart';
import 'package:waioz/ui/phone_number_page.dart';
import 'package:waioz/ui/static_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/view_cart.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_error_reporter.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';
import 'package:waioz/utility/ui_typography.dart';
import 'package:waioz/utility/version_utils.dart';

import '../model/view_cart_model.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Customer? customer;
  List<ContentData> storeContentList = [];
  bool isLoading = false;
  String? _appVersion;
  List<String> enabledExtensions = [];
  bool favouriteListEnabled = false;
  String favouriteListName = AppStrings.favourites;

  @override
  void initState() {
    super.initState();
    getCustomerInfo();
    fetchStoreContentAPI();
    listenToEvents();
    _loadVersion();
    _loadExtensions();
  }

  Future<void> _loadExtensions() async {
    try {
      final details = await ApiService().getPublicDetails();
      final favouriteConfig =
          await ApiService().getFavouriteListConfig(context);
      if (mounted) {
        setState(() {
          enabledExtensions = details.enabledExtensions;
          // Show the wishlist entry in both simple mode (enabled=false) and
          // full mode (enabled=true). The enabled flag controls UI mode, not
          // whether the feature exists.
          favouriteListEnabled = true;
          favouriteListName = favouriteConfig.displayName;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadVersion() async {
    final version = await VersionUtils.getCurrentAppVersion();
    setState(() {
      _appVersion = version;
    });
  }

  late StreamSubscription<ProfileEvent> _eventSubscription;
  void listenToEvents() {
    _eventSubscription = eventBus.on<ProfileEvent>().listen((event) {
      if (mounted) {
        setState(() {
          if (event.customer != null) {
            customer = event.customer;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }

  static const Color _danger = Color(0xFFE5484D);
  static const Color _hairline = Color(0xFFE5E7EC);

  @override
  Widget build(BuildContext context) {
    final String fullName = customer != null
        ? '${customer?.firstName ?? ''} ${customer?.lastName ?? ''}'.trim()
        : '';
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: isLoading
            ? const AppLoader()
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        // Profile header card
                        _buildHeaderCard(fullName),
                        const SizedBox(height: 20),
                        // Account navigation card
                        _buildSectionCard(
                          children: [
                            _buildProfileItem(
                              icon: Icons.location_on_outlined,
                              title: AppStrings.address,
                              onTap: () {
                                PageRouteUtils.pushWithSlide(
                                    context,
                                    AddressListPage(
                                        onSelectedAddress: (address) {}));
                              },
                            ),
                            _buildProfileItem(
                              icon: Icons.favorite_border,
                              title: AppStrings.favourites,
                              onTap: () {
                                PageRouteUtils.pushWithSlide(
                                    context, MyFavoritesPage());
                              },
                            ),
                            _buildProfileItem(
                              icon: Icons.receipt_long_outlined,
                              title: AppStrings.orders,
                              onTap: () {
                                PageRouteUtils.pushWithSlide(
                                    context, OrdersHistoryPage());
                              },
                            ),
                            if (enabledExtensions.contains('wallet'))
                              _buildProfileItem(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'My Wallet',
                                onTap: () {
                                  PageRouteUtils.pushWithSlide(
                                      context, const WalletPage());
                                },
                              ),
                            if (enabledExtensions.contains('loyalty'))
                              _buildProfileItem(
                                icon: Icons.card_giftcard_outlined,
                                title: 'Loyalty Points',
                                onTap: () {
                                  PageRouteUtils.pushWithSlide(
                                      context, const LoyaltyPage());
                                },
                              ),
                          ],
                        ),
                        if (storeContentList.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            children: storeContentList
                                .map(
                                  (contentItem) => _buildProfileItem(
                                    icon: Icons.description_outlined,
                                    title: contentItem.name ?? "Unknown",
                                    onTap: () {
                                      if (contentItem.content?.data != null) {
                                        PageRouteUtils.pushWithSlide(
                                          context,
                                          StaticPage(
                                              pageTitle: contentItem.name ?? "",
                                              htmlData:
                                                  contentItem.content!.data!),
                                        );
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          children: [
                            _buildProfileItem(
                              icon: Icons.camera_alt_outlined,
                              title: 'Follow us on Instagram',
                              onTap: () => _launchUrl('https://www.instagram.com/annachi_maligai/'),
                            ),
                            _buildProfileItem(
                              icon: Icons.facebook_outlined,
                              title: 'Follow us on Facebook',
                              onTap: () => _launchUrl('https://www.facebook.com/annachimaligaimadurai/'),
                            ),
                            _buildProfileItem(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Chat on WhatsApp',
                              onTap: () => _launchUrl('https://wa.me/919655247365'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Danger zone
                        _buildDangerZone(context),
                      ],
                    ),
                  ),
                  // Sign Out button + version
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showLogout(this.context);
                            },
                            icon: const Icon(Icons.logout, color: _danger),
                            label: Text(
                              AppStrings.signout,
                              style: FontUtils.primaryFontStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _danger,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: _danger, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${AppStrings.app_version}: $_appVersion',
                          style: FontUtils.secondaryFontStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderCard(String fullName) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Text(
              (customer?.firstName?.isNotEmpty == true
                  ? customer!.firstName!.substring(0, 1).toUpperCase()
                  : "V"),
              style: FontUtils.primaryFontStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  overflow: TextOverflow.ellipsis,
                  style: UiTypography.cardTitle().copyWith(
                    fontSize: 18,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer?.email ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: UiTypography.cardSubtitle(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Edit pill
          Material(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () async {
                final result = await PageRouteUtils.pushWithSlide(
                    context, const EditProfilePage());
                if (result == true) {
                  setState(() {
                    getCustomerInfo();
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                child: Text(
                  AppStrings.edit,
                  style: UiTypography.cardAction(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    final List<Widget> rows = [];
    for (int i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(const Divider(height: 1, thickness: 1, color: _hairline));
      }
    }
    return Container(
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
      child: Column(children: rows),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
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
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: UiTypography.cardTitle().copyWith(
                    fontSize: 15,
                    height: 1.25,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: AppColors.profileItemArrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Danger Zone',
            style: UiTypography.cardMeta(color: _danger).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _danger.withOpacity(0.25), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showDeleteAccount(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _danger.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: _danger),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppStrings.deleteAccount,
                        style: UiTypography.cardTitle(color: _danger).copyWith(
                          fontSize: 15,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 15, color: _danger),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
            await AppErrorReporter.instance.clearUser();

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
          content: AppStrings.delete_account_confirmation,
          contentOk: AppStrings.yes,
          contentCancel: AppStrings.no,
          onTapOk: () async {
            await ApiService().deleteAccount(context);

            bool skipLogin =
                await SharedPreferencesUtil().getBool('skip_login') ?? false;
            // Handle sign out action
            await SharedPreferencesUtil().clear();
            await AppErrorReporter.instance.clearUser();
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
