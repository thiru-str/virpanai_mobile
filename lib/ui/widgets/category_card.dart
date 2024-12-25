import 'package:flutter/material.dart';
import 'package:waioz/utility/font_utils.dart';

class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final Color borderColor;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.borderColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*Image.asset(
                imagePath,
                height: 80,
                fit: BoxFit.contain,
              ),*/
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: FontUtils.circularStdStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
