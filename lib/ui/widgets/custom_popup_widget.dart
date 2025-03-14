import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class CustomPopupWidget extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final Color iconBackgroundColor; // Dynamic background color
  final VoidCallback onConfirm;

  const CustomPopupWidget({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.iconBackgroundColor, // New parameter
    required this.onConfirm,
  });

  static void show(
      BuildContext context, {
        required String title,
        required String description,
        required String buttonText,
        required IconData icon,
        required Color iconBackgroundColor, // New parameter
        required VoidCallback onConfirm,
      }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CustomPopupWidget(
          title: title,
          description: description,
          buttonText: buttonText,
          icon: icon,
          iconBackgroundColor: iconBackgroundColor, // Pass the color
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50, // Adjust size as needed
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor.withOpacity(0.2), // Dynamic color
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, size: 42, color: iconBackgroundColor),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: FontUtils.primaryFontStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: FontUtils.primaryFontStyle(fontSize: 15.0),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
