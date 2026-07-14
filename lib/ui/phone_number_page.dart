import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:waioz/model/send_otp_response.dart';
import 'package:waioz/ui/otp_verification_page.dart';
import 'package:waioz/ui/register_page.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/login_redirect_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

import '../api/api_service.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';

class PhoneNumberPage extends StatefulWidget {
  final Widget? redirectPage;
  const PhoneNumberPage({super.key,this.redirectPage});

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  String? _phoneNumber;
  String? _countryCode;

  SendOtpResponse? sendOtpResponse;
  bool apiCalling = false;

  bool isEmailLogin = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLoginType();
  }

  Future<void> getLoginType() async {
    final loginType =
        await SharedPreferencesUtil().getBool('email_login') ?? false;
    setState(() {
      isEmailLogin = loginType;
    });
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: UiTypography.searchHint(),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: FontUtils.primaryFontStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9FB),
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              AppAssets.ic_arrow_svg,
              height: 16,
              width: 16,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Title
                Text(
                  isEmailLogin ? AppStrings.login : AppStrings.enter_mob_no,
                  style: UiTypography.cardTitle().copyWith(
                    fontSize: 24,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEmailLogin
                      ? AppStrings.email
                      : AppStrings.mobile_number,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 14,
                    color: AppColors.textColor50,
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 28),
                // Form for phone input
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isEmailLogin) ...[
                        _fieldLabel(AppStrings.email),

                        CustomTextField(
                          hintText: AppStrings.email,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (!isEmailLogin) return null;
                            if (value == null || value.isEmpty) {
                              return AppStrings.email_required;
                            }
                            if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                            ).hasMatch(value)) {
                              return AppStrings.enter_valid_email;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel(AppStrings.password),

                        CustomTextField(
                          hintText: AppStrings.password,
                          controller: passwordController,
                          textCapitalization: TextCapitalization.none,
                          isPassword: true,
                          keyboardType: TextInputType.visiblePassword,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                  r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]",
                              ),
                            ),
                          ],
                          validator: (value) {
                            if (!isEmailLogin) return null;
                            if (value == null || value.isEmpty) {
                              return AppStrings.password_required;
                            }
                            if (value.length < 5) {
                              return AppStrings.password_min_length;
                            }
                            return null;
                          },
                        ),
                        newToAppRegisterText(onRegisterTap: () {
                          PageRouteUtils.pushWithSlide(
                              context,
                              RegisterPage(
                                phoneNo: '',
                                countryCode: '',
                                token: '',
                                redirectPage: widget.redirectPage,
                              ));
                        })

                      ] else ...[
                        _fieldLabel(AppStrings.mobile_number),

                        IntlPhoneField(
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          dropdownTextStyle: FontUtils.primaryFontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                          style: FontUtils.primaryFontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                          decoration: _fieldDecoration(AppStrings.mobile_number),
                          initialCountryCode: AppStrings.country_code,
                          onChanged: (phone) {
                            _phoneNumber = phone.number;
                            _countryCode = phone.countryCode;
                          },
                          validator: (value) {
                            if (value == null || value.number.isEmpty) {
                              return AppStrings.enter_valid_mob_no;
                            }
                            if (value.number.length < 10 ||
                                value.number.length > 15) {
                              return AppStrings.digit_range;
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),
                // Submit button — full-width primary CTA at bottom
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if(apiCalling)
                        {
                          return;
                        }
                      if (_formKey.currentState!.validate()) {
                        if (isEmailLogin) {
                          loginWithEmail();
                        } else {
                          if (_phoneNumber != null) {
                            sendOtp();
                          } else {
                            AppUtils.showToast(AppStrings.enter_mob_no);
                          }
                        }
                      }
                    },
                    child: apiCalling
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isEmailLogin
                                    ? AppStrings.login
                                    : 'Continue',
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendOtp() async {
    try {
      setState(() {
        apiCalling = false;
      });
      final ApiService apiService = ApiService();
      sendOtpResponse =
          await apiService.sendOtp(context, _countryCode!, _phoneNumber!);
      /*if (kDebugMode) {
        AppUtils.showToast(sendOtpResponse!.otp!);
      }*/

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
      debugPrint(e.toString());
    }
  }

  void loginWithEmail() async {
    try {
      setState(() {
        apiCalling = true;
      });
      final apiService = ApiService();

      final response = await apiService.loginWithEmail(
        context,
        emailController.text.trim(),
        passwordController.text,
      );

      if (!response.newUser!) {
        SharedPreferencesUtil().saveString('token', response.token!);
      }
      // SharedPreferencesUtil()
      //     .saveMap('customer', response.customer!.toJson());

      if (mounted) {
        if (widget.redirectPage != null) {
          getHomePageApi();
          setState(() {
            apiCalling = false;
          });
          LoginRedirectUtils.redirectAfterLogin(
            context,
            redirectPage: widget.redirectPage,
          );
        } else {
          LoginRedirectUtils.redirectAfterLogin(context);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        apiCalling = false;
      });
    }
  }

  void getHomePageApi() async {
    try {
      final ApiService apiService = ApiService();
      final response = await apiService.getHomePage(context);
      await SharedPreferencesUtil()
          .saveString('region_id', response.global?.regionId ?? "");
      await SharedPreferencesUtil()
          .saveString('cart_id', response.global?.cartId ?? "");
      await SharedPreferencesUtil()
          .saveString('currency_symbol', response.global?.currencySymbol ?? "");
      await SharedPreferencesUtil()
          .saveMap('global', response.global?.toJson() ?? {});
    } catch (e) {
      print(e);
    }
  }

  Widget newToAppRegisterText({
    required VoidCallback onRegisterTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: TextSpan(
            style: FontUtils.primaryFontStyle(
              fontSize: 14,
              color: Colors.grey[700]!,
            ),
            children: [
              const TextSpan(
                text: 'Don’t have an account? ',
              ),
              TextSpan(
                text: 'Register',
                style: FontUtils.primaryFontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = onRegisterTap,
              ),
            ],
          ),
        ),
      ),
    );
  }




}
