import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/ui/UserDetailsPage.dart';
import 'package:waioz/ui/dashboard.dart';
import 'package:waioz/ui/register_page.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';
import '../utility/app_utils.dart';
import 'ApprovalPage.dart';
import 'customer_register_page.dart';

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
      return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(AppAssets.ic_arrow_svg, height: 16, width: 16),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [

            Positioned(top: 0, right: 0, child: SvgPicture.asset(AppAssets.bg_top)),
            Positioned(bottom: 0, left: 0, child: SvgPicture.asset(AppAssets.bg_bottom)),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.white.withOpacity(0.7)),
              ),
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
                              Text(
                                AppStrings.enter_otp_digit,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              RichText(
                                text: TextSpan(
                                  style: FontUtils.primaryFontStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700]!,
                                  ),
                                  children: [
                                    const TextSpan(text: '${AppStrings.code_sent}\n'),
                                    TextSpan(
                                      text: '${widget.countryCode} ',
                                      style: TextStyle(
                                        color: AppColors.primary, // Or any color you prefer for country code
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.phoneNo,
                                      style: TextStyle(
                                        color: AppColors.primary, // Or any color you prefer for phone number
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              PinCodeTextField(
                                  appContext: context,
                                  length: 6,
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
                                  onCompleted: (value) => print("OTP Entered: $value"),
                                  onChanged: (value) => print(value),
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

            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 60,
              right: 24,
              child: FloatingActionButton(
                elevation: 0,
                shape: const CircleBorder(),
                backgroundColor: AppColors.primary,
                onPressed: () {
                    if (_otpController.text.length == 6) {
                      print("Submitted OTP: ${_otpController.text}");
                      verifyOtp();
                    } else {
                      AppUtils.showToast("Enter full OTP");
                    }

                },
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
            ),
          ],
        ),
      );
      }

  void verifyOtp() async {
    try {
      final ApiService apiService = ApiService();
      verifyOtpResponse = await apiService.verifyOtp(
          context, widget.countryCode, widget.phoneNo, _otpController.text);
      setState(() => apiCalling = false);


      if (verifyOtpResponse?.newUser == true) {
        final result = await PageRouteUtils.push(context, CustomerRegisterPage(countryCode: widget.countryCode, phoneNo: widget.phoneNo, token: verifyOtpResponse?.token??''));
        Navigator.pop(context, result); // bubble result back
      }
      else{
        AppUtils.showToast('Customer already exists');
        Navigator.pop(context, false); // bubble result back
      }

    } catch (e) {
      setState(() => apiCalling = false);
      print(e);
    }
  }

  void getHomePageApi() async {
    try {
      final ApiService apiService = ApiService();
      final response= await apiService.getHomePage(context);
      await SharedPreferencesUtil().saveString('region_id', response.global!.regionId!);
      await SharedPreferencesUtil().saveString('cart_id', response.global!.cartId!);
      await SharedPreferencesUtil().saveString('currency_symbol', response.global!.currencySymbol!);
      await SharedPreferencesUtil().saveMap('global', response.global!.toJson());
    } catch (e) {
      print(e);
    }
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

}
