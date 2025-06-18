import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:waioz/model/send_otp_response.dart';
import 'package:waioz/ui/UserDetailsPage.dart';
import 'package:waioz/ui/otp_verification_page.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/app_utils.dart';
import '../utility/rich_text_helper.dart';
import 'ApprovalPage.dart';

class LoginPage extends StatefulWidget {
  final Widget? redirectPage;
  const LoginPage({super.key,this.redirectPage});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _phoneNumber;
  String? _countryCode;

  SendOtpResponse? sendOtpResponse;
  bool apiCalling = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevents Stack from resizing on keyboard open
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppAssets.ic_arrow_svg,
            height: 16,
            width: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [

          Positioned(top: 0, right: 0, child: SvgPicture.asset(AppAssets.bg_top)),
          Positioned(bottom: 0, left: 0, child: SvgPicture.asset(AppAssets.bg_bottom)),

          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.7)),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Log into your Account',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  buildLabeledTextField(
                                    label: "Email",
                                    controller: _emailController,
                                    validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                                  ),

                                  buildLabeledTextField(
                                    label: "Password",
                                    controller: _passwordController,
                                    isPassword: true,
                                    validator: (val) => val == null ||
                                            val.isEmpty
                                        ? 'Please enter your password'
                                        : val.length < 6
                                            ? 'Password must be at least 6 characters'
                                            : null,
                                  ),
                                  const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                    onPressed: (){
                                      if (_formKey.currentState!.validate()) {
                                        PageRouteUtils.pushAndRemoveUntil(context, const ApprovalPage(errorCode: '00000'));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Login",
                                      style: const TextStyle(fontSize: 18, color: Colors.white),
                                    )
                                ),
                              ),
                                  SizedBox(height: 24,),
                                  Center(
                                    child: GestureDetector(
                                      onTap: (){
                                        PageRouteUtils.push(context, UserDetailsPage());
                                      },
                                      child: RichTextHelper(
                                        segments: [
                                          RichTextSegment(text: 'Don\'t have an account?',textStyle: const TextStyle(color: Colors.grey,fontSize: 14, fontWeight: FontWeight.normal)),
                                          RichTextSegment(text: ' Register',textStyle: TextStyle(color: AppColors.primary,fontSize: 14, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );


  }

  Widget buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPassword = false,
  }) {
    final ValueNotifier<bool> _obscureText = ValueNotifier(true);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          ValueListenableBuilder<bool>(
            valueListenable: _obscureText,
            builder: (context, obscure, _) {
              return TextFormField(
                controller: controller,
                keyboardType: inputType,
                obscureText: isPassword ? obscure : false,
                validator: validator,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  suffixIcon: isPassword
                      ? IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => _obscureText.value = !obscure,
                  )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  void sendOtp() async {
    try {
      final ApiService apiService = ApiService();
      sendOtpResponse =
          await apiService.sendOtp(context, _countryCode!, _phoneNumber!);
      setState(() {
        apiCalling = false;
      });

      PageRouteUtils.pushWithSlide(
          context,
          OtpVerificationPage(
            countryCode: _countryCode!,
            phoneNo: _phoneNumber!,
            otp: sendOtpResponse!.otp!,
            redirectPage:widget.redirectPage,
          ));

    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }

}
