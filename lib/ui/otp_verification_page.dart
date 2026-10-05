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
import 'package:waioz/utility/ui_typography.dart';

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

  bool apiCalling = false;
  VerifyOtpResponse? verifyOtpResponse;
  String? _loginErrorMessage;

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
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9FB),
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(AppAssets.ic_arrow_svg, height: 16, width: 16),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Title
                Text(
                  AppStrings.enter_otp_digit,
                  style: UiTypography.cardTitle().copyWith(
                    fontSize: 24,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle with destination number
                Text(
                  '${AppStrings.code_sent}\n${widget.countryCode} ${widget.phoneNo}',
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 14,
                    color: AppColors.textColor50,
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 32),
                // OTP Fields — equal rounded-14 cells, active cell primary border
                PinCodeTextField(
                  appContext: context,
                  length: 6, // Number of OTP digits
                  controller: _otpController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  autoFocus: true,
                  animationType: AnimationType.none,
                  cursorColor: AppColors.primary,
                  textStyle: FontUtils.primaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14),
                    fieldHeight: 52,
                    fieldWidth: 48,
                    borderWidth: 1.5,
                    activeBorderWidth: 1.5,
                    selectedBorderWidth: 1.5,
                    inactiveBorderWidth: 1.5,
                    inactiveFillColor: Colors.white,
                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    inactiveColor: Colors.grey.shade300,
                    activeColor: Colors.grey.shade300,
                    selectedColor: AppColors.primary,
                  ),
                  enableActiveFill: true,
                  onCompleted: (value) {
                    print("OTP Entered: $value");
                  },
                  onChanged: (value) {
                    print(value);
                    if (_loginErrorMessage != null) {
                      setState(() => _loginErrorMessage = null);
                    }
                  },
                ),
                if (_loginErrorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _loginErrorMessage!,
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!_isResendVisible)
                      Text(
                        "Resend OTP in  00:${_remainingSeconds.toString().padLeft(2, '0')}",
                        style: FontUtils.secondaryFontStyle(
                          fontSize: 14,
                          color: AppColors.textColor50,
                        ),
                      ),
                    if (_isResendVisible)
                      GestureDetector(
                        onTap:resendOtp,
                        child: Text(
                          "Resend OTP",
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 36),
                // Verify CTA — full-width primary
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
                    onPressed: apiCalling ? null : verifyOtp,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (apiCalling)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        else ...[
                          Text(
                            "Verify",
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
    if (apiCalling) return;
    setState(() {
      apiCalling = true;
      _loginErrorMessage = null;
    });

    try {
      final ApiService apiService = ApiService();
      verifyOtpResponse = await apiService.verifyOtp(
          context, widget.countryCode, widget.phoneNo, _otpController.text);
      if (!mounted) return;
      setState(() {
        apiCalling = false;
      });

      final response = verifyOtpResponse!;
      if (response.hasFailure) {
        _setLoginError(response.failureMessage);
        return;
      }

      if (response.newUser == true) {
        //redirect to create account page
        PageRouteUtils.pushWithSlide(
            context,
            RegisterPage(
              phoneNo: widget.phoneNo,
              countryCode: widget.countryCode,
              token: response.token ?? '',
              redirectPage: widget.redirectPage,
            ));
        return;
      }

      final token = response.token;
      if (token == null || token.isEmpty) {
        _setLoginError(response.failureMessage);
        return;
      }
      await SharedPreferencesUtil().saveString('token', token);

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
      if (!mounted) return;
      _setLoginError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _setLoginError(String message) {
    if (!mounted) return;
    setState(() {
      apiCalling = false;
      _loginErrorMessage = message;
    });
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
