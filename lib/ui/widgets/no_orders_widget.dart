import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';

class NoOrdersWidget extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonTap;

  const NoOrdersWidget({
    Key? key,
    required this.message,
    required this.buttonText,
    required this.onButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Section
          Stack(
            alignment: Alignment.topRight,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: Colors.orange,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Message Section
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Button Section
          ElevatedButton(
            onPressed: onButtonTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // Background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
