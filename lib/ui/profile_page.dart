import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/ui/login_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/ui/widgets/distributor_detail_page.dart';

import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/app_strings.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                      icon:Icon(Icons.arrow_back_ios)
                    ),
                  ),
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                icon: Icons.shield_outlined,
                label: "Privacy Policy",
                onTap: () {},
              ),
              ProfileOptionTile(
                icon: Icons.lock_outline,
                label: "Terms of Service",
                onTap: () {},
              ),
              ProfileOptionTile(
                icon: Icons.help_outline,
                label: "Help Center",
                onTap: () {},
              ),
              ProfileOptionTile(
                icon: Icons.logout,
                label: "Log Out",
                onTap: () {
                  _showLogout(context);
                },
              ),
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
        child: Icon(icon, color: Colors.teal.shade800, size: 20),
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
