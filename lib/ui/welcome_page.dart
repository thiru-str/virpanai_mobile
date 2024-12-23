import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spin_wheel_menu/flutter_spin_wheel_menu.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:waioz/model/branch_response_model.dart';
import 'package:waioz/model/send_otp_response_model.dart';
import 'package:waioz/model/verify_otp_response_model.dart';
import 'package:waioz/ui/login_page.dart';
import 'package:waioz/utility/AppColors.dart';

import '../api/api_service.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  int cardPosition = 0;
  int selectedIndex = 0;
  final FixedExtentScrollController _scrollController = FixedExtentScrollController();

  int _start = 50; // Initial countdown time in seconds
  Timer? _timer;
  bool _timerStarted = false; // Track if the timer has started
  bool _isResendButtonEnabled = false; // Disable resend button initially

  bool _isApiCalled = false; // Track if the timer has started
  final ApiService apiService = ApiService();
  BranchResponse? branchResponse;

  SendOtpResponse? sendOtpResponse;
  VerifyOtpResponse? verifyOtpResponse;

  String emailId = "",tenantId = "";
  int branchId = 0;
  int otp = 0;

  final TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // SVG Background
          Positioned.fill(
            child: SvgPicture.asset(
              'images/welcome_bg.svg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 60, // Adjust as needed
            left: 60, // Adjust as needed
            child: SvgPicture.asset(
              'images/welcome_logo.svg', // Path to your logo
            ),
          ),
          Center(
            child: getContainer(cardPosition),
          ),
        ],
      ),
    );
  }

  Widget phoneNoContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      width: 450,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Keep Ordering Amazing",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Main Food!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add Your email. We'll Send You A Verification Code So We Know You're Real.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          // Phone Number Field
          Row(
            children: [
              /*SizedBox(
                height: 56, // Set height to match the TextField height
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border( top: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey),
                      left: BorderSide(color: Colors.grey),
                      right: BorderSide.none, ),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)),
                  ),
                  child: const Row(
                    children: [
                      Text('+91'),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),*/
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Send OTP Button
          SizedBox(
              width: double.infinity,
              child: isLoading? Center(child: CircularProgressIndicator(color: AppColors.primary,)):ElevatedButton(
                child: const Text('Send OTP'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  _validateEmail();
                },
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  void startTimer() {
    // Prevent multiple timer instances
    if (_timerStarted) return;

    _timer?.cancel(); // Cancel any existing timer
    _timerStarted = true;
    _isResendButtonEnabled = false;
    _start = 50;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendButtonEnabled = true;
          _timer?.cancel();
          _timerStarted = false; // Allow timer to start again if needed
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }


  Widget otpContainer() {
    startTimer();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      width: 450,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Verify your \n Phone Number",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your OTP code here",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 350,
            child: PinCodeTextField(
              appContext: context,
              controller: otpController,
              length: 6, // Number of digits in the PIN code
              onChanged: (value) {},
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(15), // Rounded corners
                fieldHeight: 50,
                fieldWidth: 50,
                activeColor: Colors.transparent, // No border for active field
                inactiveColor: Colors.transparent, // No border for inactive fields
                selectedColor: Colors.transparent, // No border for selected field
                activeFillColor: Colors.grey[200]!, // Background color of the active field
                inactiveFillColor: Colors.grey[200]!, // Background color of inactive fields
                selectedFillColor: Colors.grey[200]!, // Background color of the selected field
              ),
              keyboardType: TextInputType.number,
              textStyle: const TextStyle(color: Colors.black, fontSize: 20),
              enableActiveFill: true, // Enable fill color
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _isResendButtonEnabled
                    ? () {
                  startTimer(); // Restart the timer
                  // Add resend OTP logic here
                }
                    : null,
                child: Text(
                  "Resend OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isResendButtonEnabled
                        ? AppColors.primary
                        : Colors.grey, // Change color based on button state
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "00:${_start.toString().padLeft(2, '0')}", // Format time as mm:ss
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: isLoading? Center(child: CircularProgressIndicator(color: AppColors.primary,)):ElevatedButton(
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (otpController.text.length == 6) {
                  verifyOtp(emailId, otpController.text);
                } else {
                  AppUtils.showToast('Enter otp');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget branchContainer() {

    getBranches();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      width: 450,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Choose Your Branch",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          // Phone Number Field
      branchResponse?.data!=null ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200, // Total height for the visible list
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: 50, // Height of each item
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  return Center(
                    child: Text(
                      branchResponse!.data!.branchList![index].branchName!,
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedIndex == index ? AppColors.primary : Colors.black,
                        fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
                childCount: branchResponse!.data!.branchList!.length,
              ),
            ),
          ),
          const SizedBox(height: 20),
          /*ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text('Selected: ${branchResponse!.data!.branchList![selectedIndex].branchName!}'),
                ),
              );
            },
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),*/
        ],
      ): const CircularProgressIndicator(),
          const SizedBox(height: 10),
          // Send OTP Button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  /*setState(() {
                    cardPosition =2;
                  });*/
                  branchId = branchResponse!.data!.branchList![selectedIndex].id!;
                  saveBranchInfo(branchId,tenantId);
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(branchId: branchId,tenantId: tenantId,),
                        ),
                      );
                },
              )),
        ],
      ),
    );
  }

  getContainer(int cardPosition) {
    switch (cardPosition) {
      case 0:
        return phoneNoContainer();
      case 1:
        return otpContainer();
      case 2:
        return branchContainer();
    }
  }

  void getBranches() async {

    if(_isApiCalled) return;

    // Replace with actual tenantId, jwtToken, and branchId
    tenantId = verifyOtpResponse!.data!.tenantId!;

    try {
      branchResponse = await apiService.getBranches(context,tenantId);
      setState(() {
        _isApiCalled = true;
        branchResponse;
      });
    } catch (e) {
      print(e);
    }
  }

  void sendOtp(String emailId) async {
    try {
      sendOtpResponse = await apiService.sendOtp(context,emailId);
      this.emailId = emailId;
      this.otp = sendOtpResponse!.data!.otp!;
      if (kDebugMode) {
        AppUtils.showToast(sendOtpResponse!.data!.otp!.toString());
      }
      setState(() {
        isLoading = false;
        cardPosition = 1;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  void verifyOtp(String emailId,String otp) async {
    try {
      setState(() {
        isLoading = true;
      });
      verifyOtpResponse = await apiService.verifyOtp(context,emailId,otp);
      setState(() {
        AppUtils.showToast(verifyOtpResponse!.message!);
        isLoading = false;
        cardPosition = 2;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  void _validateEmail() {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      AppUtils.showToast('enterEmail');
      return;
    }

    // Additional validation for email format
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email)) {
      AppUtils.showToast('Please enter a valid email address.');
      return;
    }

    setState(() {
      isLoading = true;
    });
    sendOtp(emailController.text.toString());

  }

  void saveBranchInfo(int branchId,String tenantId) async {
    await SharedPreferencesUtil().saveInt('branch_id', branchId);
    await SharedPreferencesUtil().saveString('tenant_id', tenantId);
  }
}


