import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/register_page.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';

class OtpVerificationPage extends StatefulWidget {
  final String countryCode;
  final String phoneNo;
  final String otp;
  final Widget? redirectPage;

  const OtpVerificationPage(
      {super.key,
      required this.countryCode,
      required this.phoneNo,
      this.otp = '',
      this.redirectPage});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool apiCalling = true;
  VerifyOtpResponse? verifyOtpResponse;

  int _remainingSeconds = 30;
  Timer? _timer;
  bool _isResendVisible = false;

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    if(widget.otp.isNotEmpty) {
      _otpController.text = widget.otp;
    }

    startTimer();
  }

  void startTimer() {
    setState(() {
      _remainingSeconds = 30;
      _isResendVisible = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() {
          _isResendVisible = true;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void resendOtp() async {

    sendOtp();

    // Restart timer
    startTimer();
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Title
                Text(
                  AppStrings.enter_otp_digit,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                // Form for phone input
                Text(
                  '${AppStrings.code_sent}\n ${widget.countryCode} ${widget.phoneNo}',
                  style: FontUtils.primaryFontStyle(
                    fontSize: 16,
                    color: Colors.grey[700]!,
                  ),
                ),
                const SizedBox(height: 32),
                // OTP Fields
                PinCodeTextField(
                  appContext: context,
                  length: 6, // Number of OTP digits
                  controller: _otpController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  autoFocus: true,
                  animationType: AnimationType.none,
                  textStyle: FontUtils.primaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    inactiveFillColor: Colors.white,
                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    inactiveColor: AppColors.secondary,
                    activeColor: AppColors.primary,
                    selectedColor: AppColors.primary,
                  ),
                  enableActiveFill: true,
                  onCompleted: (value) {
                    print("OTP Entered: $value");
                  },
                  onChanged: (value) {
                    print(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!_isResendVisible)
                      Text(
                        "Resend OTP in : 00:${_remainingSeconds.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (_isResendVisible)
                      GestureDetector(
                        onTap:resendOtp,
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              // Validate OTP and proceed
              print('Submitted OTP: ${_otpController.text}');
              verifyOtp();
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
        ),
        resizeToAvoidBottomInset:
            true, // Ensures keyboard does not cause overflow
      ),
    );
  }

  void sendOtp() async {
    try {
      setState(() {
        apiCalling = true;
      });
      final ApiService apiService = ApiService();
      final sendOtpResponse = await apiService.sendOtp(context, widget.countryCode, widget.phoneNo);

      if ((sendOtpResponse.otp ?? '').isNotEmpty) {
        setState(() {
          _otpController.text = sendOtpResponse.otp ?? '';
        });
      }

      setState(() {
        apiCalling = false;
      });



    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }

  void verifyOtp() async {
    try {
      final ApiService apiService = ApiService();
      verifyOtpResponse = await apiService.verifyOtp(
          context, widget.countryCode, widget.phoneNo, _otpController.text);
      setState(() {
        apiCalling = false;
      });

      if (!verifyOtpResponse!.newUser!) {
        SharedPreferencesUtil().saveString('token', verifyOtpResponse!.token!);
      } else {
        //redirect to create account page
        if (mounted) {
          PageRouteUtils.pushWithSlide(
              context,
              RegisterPage(
                phoneNo: widget.phoneNo,
                countryCode: widget.countryCode,
                token: verifyOtpResponse!.token!,
                redirectPage: widget.redirectPage,
              ));
        }
        return;
      }

      if (mounted) {
        if (widget.redirectPage != null) {
          setState(() {
            apiCalling = true;
          });
          getHomePageApi();
          setState(() {
            apiCalling = false;
          });
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
