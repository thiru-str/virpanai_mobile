import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';
import '../../utility/font_utils.dart';

class LoginPrompt extends StatelessWidget {
  final bool showClose;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback? onClosePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: showClose,
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon:
              const Icon(Icons.clear, color: Colors.grey),
              onPressed: onClosePressed,
            ),
          ),
        ),
        Padding(
          padding:  EdgeInsets.only(top:showClose?0:20,left: 20,right: 20,bottom: 20),
          child: Column(
            children: [
              Text(
                title,
                style: FontUtils.primaryFontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: FontUtils.secondaryFontStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style:  ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(
                        double.infinity, 56), // Full width button
                  ),
                  child: Text(
                    buttonText,
                    style: FontUtils.primaryFontStyle(fontSize: 16, color:Colors.white,fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  const LoginPrompt({
    Key? key,
    this.showClose = false,
    this.title = 'Login to continue',
    this.description= 'Please log in to view your cart and complete your purchase.',
    this.buttonText = 'Login Now',
    required this.onButtonPressed,
    this.onClosePressed,
  }) : super(key: key);
}
