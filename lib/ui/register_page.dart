import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/email_register_response.dart';
import 'package:waioz/model/refresh_token_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'package:waioz/utility/app_strings.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/font_utils.dart';
import '../utility/page_route_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'bottom_nav_page.dart';

class RegisterPage extends StatefulWidget {
  final String countryCode;
  final String phoneNo;
  final String token;
  final Widget? redirectPage;
  const RegisterPage(
      {super.key,
      required this.countryCode,
      required this.phoneNo,
      required this.token,
      required this.redirectPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  bool apiCalling = false;
  RegisterResponse? registerResponse;
  EmailRegisterResponse? emailRegisterResponse;
  bool isEmailLogin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginType();
  }

  Future<void> getLoginType() async {
    final loginType = await SharedPreferencesUtil().getBool('email_login')?? false;
    setState(() {
      isEmailLogin = loginType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(AppAssets.ic_arrow_svg, height: 16, width: 16),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.register_msg,
                    style: FontUtils.secondaryFontStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    hintText: AppStrings.firstname,
                    controller: firstNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.firstname_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: AppStrings.lastname,
                    controller: lastNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.lastname_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: AppStrings.email,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.email_required;
                      }
                      if (!RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return AppStrings.enter_valid_email;
                      }
                      return null;
                    },
                  ),
                  if (isEmailLogin) ...[
                    const SizedBox(height: 16),

                    CustomTextField(
                      hintText: AppStrings.password,
                      controller: passwordController,
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),)],
                      isPassword: true,
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

                    const SizedBox(height: 16),

                    CustomTextField(
                      hintText: AppStrings.confirm_password,
                      controller: confirmPasswordController,
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:'\,.<>\/\?\\|]"),)],
                      isPassword: true,
                      validator: (value) {
                        if (!isEmailLogin) return null;

                        if (value == null || value.isEmpty) {
                          return AppStrings.confirm_password_required;
                        }
                        if (value != passwordController.text) {
                          return AppStrings.password_mismatch;
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 16),


                  apiCalling?Center(child: CircularProgressIndicator(color: AppColors.primary,),):ElevatedButton(
                    onPressed:() {
                      if (_formKey.currentState!.validate()) {
                        register();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: Text(
                      AppStrings.register,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void register() async {
    try {
      setState(() {
        apiCalling = true;
      });
      final ApiService apiService = ApiService();
      if(!isEmailLogin) {
        registerResponse = await apiService.register(
            context,
            emailController.text,
            companyController.text,
            firstNameController.text,
            lastNameController.text,
            widget.countryCode,
            widget.phoneNo,
            widget.token);

        RefreshTokenResponse refreshTokenResponse =
        await apiService.refreshToken(context, widget.token);
        SharedPreferencesUtil().saveString('token', refreshTokenResponse.token!);
        SharedPreferencesUtil()
            .saveMap('customer', registerResponse?.customer?.toJson() ?? {});
      }
      else{
        emailRegisterResponse = await apiService.registerEmail(
            context,
            emailController.text,
            companyController.text,
            firstNameController.text,
            lastNameController.text,
            widget.countryCode,
            widget.phoneNo,
            passwordController.text);
        SharedPreferencesUtil().saveString('token', emailRegisterResponse?.token??'');
        SharedPreferencesUtil()
            .saveMap('customer', emailRegisterResponse?.customer?.toJson() ?? {});
      }


      if (mounted) {
        if (widget.redirectPage != null) {
          getHomePageApi();
          PageRouteUtils.pushAndRemoveUntil(context, widget.redirectPage!);
        } else {
          PageRouteUtils.pushAndRemoveUntil(context, const BottomNavPage());
        }
      }
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
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
}
