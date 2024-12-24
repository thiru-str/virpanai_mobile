import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../utility/app_colors.dart';

class OtpVerificationPage extends StatefulWidget {
  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
            Text(
              'Enter Your 4-Digit\nCode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              'Enter the code from the number we sent to\n+91 856234125',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 32),
            // OTP Fields
            PinCodeTextField(
              appContext: context,
              length: 4, // Number of OTP digits
              controller: _otpController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              autoFocus: true,
              animationType: AnimationType.none,
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 50,
                inactiveFillColor: Colors.grey[200]!,
                activeFillColor: Colors.grey[200]!,
                selectedFillColor: Colors.white,
                inactiveColor: Colors.grey[400]!,
                activeColor: Colors.blue,
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
                  child: Row(
                    children: [
                      Text(
                        'Resend Code',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    PageRouteUtils.pushAndRemoveUntil(context, BottomNavPage());
                  },
                  backgroundColor: Color(0xFF6A4BF6), // Purple color
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
