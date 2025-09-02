import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:waioz/model/send_otp_response.dart';
import 'package:waioz/ui/UserDetailsPage.dart';
import 'package:waioz/ui/dashboard.dart';
import 'package:waioz/ui/otp_verification_page.dart';
import 'package:waioz/ui/widgets/label_text_field.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/api_service.dart';
import '../utility/app_utils.dart';
import '../utility/rich_text_helper.dart';
import '../utility/shared_preferences_util.dart';
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

  bool apiCalling = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                                    LabeledTextField(
                                      label: "Email",
                                      inputType: TextInputType.emailAddress,
                                      controller: _emailController,
                                      validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                                    ),

                                    LabeledTextField(
                                      label: "Password",
                                      controller: _passwordController,
                                      isPassword: true,
                                      validator: (val) => val == null ||
                                              val.isEmpty
                                          ? 'Please enter your password'
                                          : val.length < 5
                                              ? 'Password must be at least 5 characters'
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                apiCalling? Center(child: CircularProgressIndicator(color: AppColors.primary,),):SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                      onPressed: (){
                                        if (_formKey.currentState!.validate()) {
                                          login();
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
      ),
    );

  }

  void login() async {
    try {
      setState(() {
        apiCalling = true;
      });
      final ApiService apiService = ApiService();
      var response = await apiService.login(
          context,_emailController.text, _passwordController.text);
      setState(() => apiCalling = false);


      if (response.error != null) {
        if (((response.error?.code ?? '') == '00002') || ((response.error?.code ?? '') == '00001')) {
          AppUtils.showToast(response.error?.message ?? '');
          return;
        } else if ((response.error?.code == '00004' ||
                response.error?.code == '00003') &&
            mounted) {
          PageRouteUtils.pushWithSlide(
              context, ApprovalPage(errorCode: response.error!.code!));
          return;
        } else{
          SharedPreferencesUtil().saveString('token', response.token!);

          if (mounted) {
            PageRouteUtils.pushAndRemoveUntil(context, const Dashboard());
          }
        }
      }


    } catch (e) {
      setState(() => apiCalling = false);
      print(e);
    }
  }

}
