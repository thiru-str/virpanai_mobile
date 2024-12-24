import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/utility/page_route_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../api/api_service.dart';
import '../utility/app_assets.dart';
import '../utility/app_colors.dart';

class OtpVerificationPage extends StatefulWidget {
  final String countryCode;
  final String phoneNo;

  const OtpVerificationPage({super.key,required this.countryCode,required this.phoneNo});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool apiCalling = true;
  VerifyOtpResponse? verifyOtpResponse;

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(AppAssets.ic_arrow_svg,height: 16,width: 16),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Title
            const Text(
              'Enter Your 6-Digit\nCode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              'Enter the code from the number we sent to\n ${widget.countryCode} ${widget.phoneNo}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
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
              textStyle: const TextStyle(
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
            const SizedBox(height: 24),
            // Resend Code and Timer Aligned with FAB
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Resend Code Button and Timer
                TextButton(
                  onPressed: () {
                    // Handle Resend Code
                    print('Resend Code');
                  },
                  child: const Row(
                    children: [
                      Text(
                        'Resend Code',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '02:32', // Replace with actual timer logic
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating Action Button
                FloatingActionButton(
                  onPressed: () {
                    // Validate OTP and proceed
                    print('Submitted OTP: ${_otpController.text}');
                    verifyOtp();
                  },
                  backgroundColor: const Color(0xFF6A4BF6), // Purple color
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void verifyOtp() async {
    try {
      final ApiService apiService = ApiService();
      verifyOtpResponse = await apiService.verifyOtp(context,widget.phoneNo,_otpController.text);
      setState(() {
        apiCalling = false;
      });

      if(!verifyOtpResponse!.newUser!) {
        SharedPreferencesUtil().saveString('token', verifyOtpResponse!.token!);
      }
      else{
        //redirect to create account page

      }

      PageRouteUtils.pushAndRemoveUntil(context, const BottomNavPage());
    } catch (e) {
      setState(() {
        apiCalling = false;
      });
      print(e);
    }
  }
}
