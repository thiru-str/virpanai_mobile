import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/login_page.dart';
import 'package:waioz/ui/static_page.dart';
import 'package:waioz/ui/verify_email_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/distributor_detail_page.dart';
import 'package:waioz/utility/app_utils.dart';

import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/app_strings.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}



class _ProfilePageState extends State<ProfilePage> {
  String? _appVersion;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await AppUtils.getCurrentAppVersion();
    setState(() {
      _appVersion = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Center(
                    child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon:Icon(Icons.arrow_back_ios,size: 18,)
                    ),
                  ),
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "View settings and manage them.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Reusable Options
              // ProfileOptionTile(
              //   icon: Icons.person_outline,
              //   label: "Profile Settings",
              //   onTap: () {},
              // ),
              ProfileOptionTile(
                icon: Icons.notifications_outlined,
                label: "Distributor Details",
                onTap: () {
                  PageRouteUtils.pushWithSlide(context, const DistributorDetailPage());
                },
              ),
              ProfileOptionTile(
                icon: Icons.password,
                label: "Reset Password",
                onTap: () {
                  PageRouteUtils.pushWithSlide(context, const VerifyEmailPage());
                },
              ),
              ProfileOptionTile(
                icon: Icons.shield_outlined,
                label: "Privacy Policy",
                onTap: () {
                  PageRouteUtils.pushWithSlide(context,const StaticPage(pageTitle: 'Privacy Policy', slug: 'privacy-policy'));
                },
              ),
              ProfileOptionTile(
                icon: Icons.lock_outline,
                label: "Terms and Conditions",
                onTap: () {
                  PageRouteUtils.pushWithSlide(context,const StaticPage(pageTitle: 'Terms and Conditions', slug: 'terms-and-conditions'));
                },
              ),
              ProfileOptionTile(
                icon: Icons.help_outline,
                label: "Help",
                onTap: () {
                  PageRouteUtils.pushWithSlide(context,const StaticPage(pageTitle: 'Help', slug: 'help'));
                },
              ),
              ProfileOptionTile(
                icon: Icons.logout,
                label: "Log Out",
                onTap: () {
                  _showLogout(context);
                },
              ),
              Spacer(),
              Center(child: Text('App Version: $_appVersion',style: FontUtils.secondaryFontStyle(color:Colors.grey),))
            ],
          ),
        ),
      ),
    );
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

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2FAEC),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary.withAlpha(80), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
