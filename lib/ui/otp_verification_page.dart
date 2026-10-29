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
import '../utility/app_utils.dart';

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

  // A second verify of the same OTP is refused as "Invalid OTP", so only one
  // request may be in flight.
  bool _verifying = false;
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
    if (widget.otp.isNotEmpty) {
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9FB),
          elevation: 0,
          leading: IconButton(
            icon:
                SvgPicture.asset(AppAssets.ic_arrow_svg, height: 16, width: 16),
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
                  onChanged: (_) {},
                ),
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
                        onTap: resendOtp,
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
                    onPressed: _verifying ? null : verifyOtp,
                    child: _verifying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                              semanticsLabel: 'Verifying',
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Verify",
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
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
      final sendOtpResponse =
          await apiService.sendOtp(context, widget.countryCode, widget.phoneNo);

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

  Future<void> verifyOtp() async {
    if (_verifying) return;
    if (_otpController.text.trim().length < 6) {
      AppUtils.showToast('Please enter the 6-digit OTP');
      return;
    }
    setState(() => _verifying = true);
    try {
      final response = await ApiService().verifyOtp(
          context, widget.countryCode, widget.phoneNo, _otpController.text);
      verifyOtpResponse = response;
      if (!mounted) return;

      if (response.isRefused) {
        AppUtils.showToast(
            response.errorMessage ?? 'Unable to sign in. Please try again.');
        return;
      }

      if (response.newUser == true) {
        PageRouteUtils.pushWithSlide(
            context,
            RegisterPage(
              phoneNo: widget.phoneNo,
              countryCode: widget.countryCode,
              token: response.token!,
              redirectPage: widget.redirectPage,
            ));
        return;
      }

      await SharedPreferencesUtil().saveString('token', response.token!);
      if (!mounted) return;
      if (widget.redirectPage != null) {
        // The signed-in cart id must be stored before the page it returns to
        // reads the cart.
        await getHomePageApi();
        if (!mounted) return;
        PageRouteUtils.pushAndRemoveUntil(context, widget.redirectPage!);
      } else {
        PageRouteUtils.pushAndRemoveUntil(context, const BottomNavPage());
      }
    } catch (e) {
      // The API layer already showed the backend's message (e.g. "Invalid OTP").
      debugPrint('verify otp failed: $e');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> getHomePageApi() async {
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
