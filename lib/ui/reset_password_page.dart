import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/ui/widgets/common_app_bar.dart';
import 'package:waioz/ui/widgets/label_text_field.dart';
import 'package:waioz/utility/app_utils.dart';

import '../api/api_service.dart';
import '../utility/app_colors.dart';
import '../utility/page_route_utils.dart';

class ResetPasswordPage extends StatefulWidget {
  final String emailMasked;

  const ResetPasswordPage({super.key, required this.emailMasked});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  int _remainingSeconds = 30;
  Timer? _timer;
  bool _isResendVisible = false;
  bool apiCalling = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _focusNode.dispose();
    super.dispose();
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
        setState(() => _isResendVisible = true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _resendOtp() async {
    await ApiService().sendEmailOtp(context);
    startTimer();
  }

  Future<void> handleReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => apiCalling = true);
      try {
        final response = await ApiService().verifyEmailOtp(context,_otpController.text,_passwordController.text);
        if (response.status ?? false) {
          AppUtils.showToast(response.message??'');
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (error) {
        debugPrint('Error sending OTP: $error');
      } finally {
        if (mounted) {
          setState(() => apiCalling = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Reset Password", showBack: true),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 OTP Section
                    const Text(
                      "Enter Verification Code",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "We’ve sent a 6-digit code to your registered Email ID (${widget.emailMasked})",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.none,
                      autoFocus: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Enter OTP";
                        }
                        if (val.length < 6) {
                          return "Enter full 6-digit OTP";
                        }
                        return null;
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 50,
                        inactiveColor: AppColors.secondary,
                        activeColor: AppColors.primary,
                        selectedColor: AppColors.primary,
                        inactiveFillColor: Colors.white,
                        activeFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                      ),
                      enableActiveFill: true,
                      onChanged: (_) {},
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        !_isResendVisible
                            ? Text(
                          "Time Remaining : 00:${_remainingSeconds.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.black),
                        )
                            : GestureDetector(
                          onTap: _resendOtp,
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 🔹 Password Section
                    const Text(
                      "Set a New Password",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    LabeledTextField(
                      label: "New Password",
                      controller: _passwordController,
                      isPassword: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Please enter new password'
                          : val.length < 5
                          ? 'Password must be at least 5 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    LabeledTextField(
                      label: "Confirm Password",
                      controller: _confirmPasswordController,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm password';
                        }
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 100), // space before button
                  ],
                ),
              ),
            ),

            // 🔹 Bottom Reset Button
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (){
                    handleReset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
