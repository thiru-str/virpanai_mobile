import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waioz/model/login_response_model.dart';
import 'package:waioz/ui/main_page.dart';
import 'package:waioz/utility/AppColors.dart';

import '../api/api_service.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';

class LoginScreen extends StatefulWidget {
  final int branchId;
  final String tenantId;
  const LoginScreen({required this.branchId, required this.tenantId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  LoginResponse? loginResponse;
  final ApiService apiService = ApiService();

  final List<String> captions = [
    'Easy And Quick Entry Of Customer Orders',
    'Seamless Integration With Inventory System',
    'Real-Time Analytics And Sales Insights'
  ];


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Container - Expanded Background Image with Carousel
        Expanded(
        flex: 2, // Increase flex to give more space to the background
        child: Stack(
          children: [
            // Background image with curve
            Positioned.fill(
              child: SvgPicture.asset(
                'images/curved_background.svg', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
            // Centered Carousel
            Positioned(
              left: 50, // Aligns PageView to the left of the container
              top: 0,
              bottom: 0,
              child: Container(
                width: 500, // Set the desired width for the PageView container
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    SvgPicture.asset(
                      'images/intro_1.svg',
                      fit: BoxFit.scaleDown,
                    ),
                    SvgPicture.asset(
                      'images/intro_2.svg',
                      fit: BoxFit.scaleDown,
                    ),
                    SvgPicture.asset(
                      'images/intro_3.svg',
                      fit: BoxFit.scaleDown,
                    ),
                  ],
                ),
              ),
            ),
            // Caption text
            Positioned(
              bottom: 60,
              left: 30,
              right: 30,
              child: Text(
                captions[_currentPage],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            // Page indicator
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  captions.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.indicatorInActiveBg,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          // Right Container - Reduced Width for Login Section
          Expanded(
            flex: 2, // Reduce flex to give less space to the login section
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset('images/storees_logo.svg', width: 120),
                    const SizedBox(height: 20),
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please enter your details to create an account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: userNameController,
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: !isPasswordVisible,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon:  IconButton(
                          icon: Icon(
                            size: 18,
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Your Password?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: isLoading? Center(child: CircularProgressIndicator(color: AppColors.primary,),):ElevatedButton(
                        onPressed: () {
                          _validateAndLogin();
                        },
                        child: const Text('Sign In'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndLogin() {
    String userName = userNameController.text.trim();
    String password = passwordController.text.trim();

    if (userName.isEmpty) {
      AppUtils.showToast('Enter Username');
      return;
    }

    if (password.isEmpty) {
      AppUtils.showToast('Please enter your password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    login();
  }

  void login() async {
    try {
      loginResponse = await apiService.login(context,widget.tenantId,widget.branchId,userNameController.text.trim(),passwordController.text.trim());
      // Save the user info to SharedPreferences
      await SharedPreferencesUtil().saveString('token', loginResponse!.data!.token!);
      await SharedPreferencesUtil().saveInt('user_id', loginResponse!.data!.id!);
      await SharedPreferencesUtil().saveMap('user_data', loginResponse!.data!.toJson());

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        // Replace NewPage with your target page
        (Route<dynamic> route) =>
            false, // This condition removes all previous routes
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }
}


