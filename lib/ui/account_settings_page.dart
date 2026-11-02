import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/edit_profile_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_error_reporter.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';
import 'package:waioz/utility/ui_typography.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: CommonHeaderAppBar(
          title: AppStrings.accountSettings,
          onBackTap: () {
            if (!_isDeleting) Navigator.of(context).pop();
          },
        ),
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  _sectionLabel(AppStrings.profileSection),
                  const SizedBox(height: 10),
                  _settingsRow(
                    icon: Icons.person_outline,
                    title: AppStrings.edit_profile,
                    subtitle: AppStrings.editProfileDescription,
                    onTap: () async {
                      final updated = await PageRouteUtils.pushWithSlide(
                          context, const EditProfilePage());
                      if (updated == true && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  _sectionLabel(AppStrings.accountManagement),
                  const SizedBox(height: 10),
                  _settingsRow(
                    icon: Icons.delete_outline,
                    title: AppStrings.deleteAccount,
                    subtitle: AppStrings.deleteAccountDescription,
                    onTap: _confirmDeleteAccount,
                  ),
                ],
              ),
              if (_isDeleting)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.65),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: UiTypography.cardMeta(color: AppColors.textColor).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isDeleting ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: UiTypography.cardTitle()),
                      const SizedBox(height: 4),
                      Text(subtitle, style: UiTypography.cardSubtitle()),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 15, color: AppColors.profileItemArrowColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(AppStrings.deleteAccount,
            style: UiTypography.cardTitle().copyWith(fontSize: 18)),
        content: Text(AppStrings.delete_account_confirmation,
            style: UiTypography.cardSubtitle(color: AppColors.textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.deleteAccount,
                style: TextStyle(color: Color(0xFFE5484D))),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isDeleting = true);

    try {
      await ApiService().deleteAccount(context);
      final skipLogin =
          await SharedPreferencesUtil().getBool('skip_login') ?? false;
      await SharedPreferencesUtil().clear();
      await AppErrorReporter.instance.clearUser();
      if (!mounted) return;
      PageRouteUtils.pushAndRemoveUntil(
          context, skipLogin ? const BottomNavPage() : WelcomePage());
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.deleteAccountFailed)),
      );
    }
  }
}
