import 'package:flutter/material.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';

import '../utility/font_utils.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Description
              Padding(
                padding: EdgeInsets.only(left: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get_your_product_with_cartel,
                      style: FontUtils.gabaritoStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child:  Text(
                    AppStrings.get_started,
                    style: FontUtils.circularStdStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // "Or" Text
              const Center(
                child: Text(
                  AppStrings.or,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Continue with Google Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle Google sign-in
                  },
                  icon: Image.asset(
                   AppAssets.ic_google, // Replace with your Google logo
                    width: 37,
                    height: 37,
                  ),
                  label:  Text(
                    AppStrings.continue_with_google,
                    style: FontUtils.circularStdStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondary),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
