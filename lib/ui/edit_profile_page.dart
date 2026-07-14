import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/common_alert_dialog.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_error_reporter.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/login_redirect_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';
import 'package:waioz/utility/ui_typography.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  RegisterResponse? registerResponse;
  bool apiCalling = true;
  Customer? customer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomerInfo();
  }

  static const Color _hairline = Color(0xFFE5E7EC);
  static const Color _danger = Color(0xFFE5484D);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: CommonHeaderAppBar(
        title: AppStrings.edit_profile,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiCalling
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  _buildFieldCard(
                    children: [
                      _buildField(
                        label: AppStrings.firstname,
                        controller: firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.firstname_required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: AppStrings.lastname,
                        controller: lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.lastname_required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: AppStrings.phone_number,
                        controller: phoneNoController,
                        enabled: false,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.phone_number_required;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDeleteAccountButton(context),
                ],
              ),
            ),
      bottomNavigationBar: apiCalling
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: _hairline, width: 1)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle registration logic
                      print("Form is valid. Proceed to register.");
                      updateUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.Upadte,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showDeleteAccount(context),
      icon: const Icon(Icons.delete_outline, color: _danger),
      label: Text(
        AppStrings.deleteAccount,
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
    );
  }

  Widget _buildFieldCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        children: children,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: UiTypography.cardMeta(color: AppColors.textColor).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: UiTypography.cardSubtitle(color: AppColors.textColor)
              .copyWith(fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF4F4F4),
            hintText: label,
            hintStyle: UiTypography.cardSubtitle(color: Colors.grey.shade600),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5484D)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFE5484D), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getCustomerInfo() async {
    try {
      customer = await getCustomerResponse();
      if (customer != null) {
        setState(() {
          firstNameController.text = customer?.firstName ?? "";
          lastNameController.text = customer?.lastName ?? "";
          phoneNoController.text = customer?.phone ?? "";
          companyController.text = customer?.companyName ?? "";
        });
      }
    } catch (e) {
      print("Error fetching customer info: $e");
    } finally {
      setState(() {
        apiCalling = false; // Hide the loading spinner when done
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

  void updateUser() async {
    try {
      final ApiService apiService = ApiService();
      registerResponse = await apiService.updateProfile(
          context,
          phoneNoController.text,
          companyController.text,
          firstNameController.text,
          lastNameController.text);
      setState(() {
        apiCalling = false;
      });
      SharedPreferencesUtil()
          .saveMap('customer', registerResponse!.customer!.toJson());
      AppUtils.showToast('Profile updated successfully');
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
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
              if (skipLogin) {
                LoginRedirectUtils.redirectAfterLogin(
                  context,
                  redirectPage: const BottomNavPage(),
                );
              } else {
                PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
              }
            }
          },
        );
      },
    );
  }
}
