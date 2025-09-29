import 'package:flutter/material.dart';
import 'package:waioz/ui/reset_password_page.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/label_text_field.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import '../api/api_service.dart';
import '../model/dealer_response.dart';
import '../utility/app_colors.dart';
import '../utility/shared_preferences_util.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool apiCalling = false;

  DealerResponse? dealerResponse;
  Dealer? dealer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Wait for the customer data to be fetched
    dealerResponse = await getDistributorResponse();
    setState(() {
      dealer = dealerResponse?.dealer;
    });
  }

  Future<DealerResponse?> getDistributorResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('dealer_info');
    if (userData != null) {
      return DealerResponse.fromJson(userData);
    }
    return null;
  }

  Future<void> _handleVerify() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_emailController.text != (dealer?.email ?? '')) {
        AppUtils.showToast('Kindly enter your registered email');
        return;
      }
      setState(() => apiCalling = true);
      try {
        final response = await ApiService().sendEmailOtp(context);
        if (response.status ?? false) {
          PageRouteUtils.push(
              context,
              ResetPasswordPage(emailMasked: maskEmail(_emailController.text))
          );
        }
      } catch (error) {
        debugPrint('Error sending OTP: $error');
      } finally {
        if (mounted) {
          setState(() => apiCalling = false);
        }
      }
    }
  }

  String maskEmail(String email) {
    if (!email.contains('@')) return email; // not a valid email, return as is

    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];

    if (local.length <= 2) {
      // if very short local part → mask after first char
      return local[0] + "***@" + domain;
    }

    // keep first 2 chars, mask the rest
    final visible = local.substring(0, 2);
    return "$visible***@$domain";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: const CommonAppBar(title: 'Reset Password', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Heading
                const Text(
                  "Verify Your Email",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Enter your registered email to verify your identity",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // 🔹 LabeledTextField with validation
                LabeledTextField(
                  label: "Email Id",
                  controller: _emailController,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40), // spacing before button

                // 🔹 Button with AnimatedPadding & Loader
                AnimatedPadding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom > 0
                        ? MediaQuery.of(context).viewInsets.bottom + 10
                        : 20,
                  ),
                  duration: const Duration(milliseconds: 100),
                  child: apiCalling
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                      : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Verify",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
