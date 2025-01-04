import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/register_page.dart';
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

  const OtpVerificationPage({super.key,required this.countryCode,required this.phoneNo,this.otp = ''});

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
    setState(() {
      _otpController.text = widget.otp;
    });
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
      body: Container(
        color: Colors.white, // Full page background color
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Title
            Text(
              'Enter Your 6-Digit\nCode',
              style: FontUtils.circularStdStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Form for phone input
            Text(
              'Enter the code from the number we sent to\n ${widget.countryCode} ${widget.phoneNo}',
              style: FontUtils.circularStdStyle(
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
              textStyle: FontUtils.circularStdStyle(
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
            const Spacer(),
            // Submit button
            Align(
              alignment: Alignment.bottomRight,
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
            const SizedBox(height: 20),
          ],
        ),
      )
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
        PageRouteUtils.pushAndRemoveUntil(context, RegisterPage(phoneNo: widget.phoneNo,countryCode: widget.countryCode,token: verifyOtpResponse!.token!,));
        return;
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
