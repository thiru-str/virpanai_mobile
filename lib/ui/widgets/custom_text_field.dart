import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/utility/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final int? maxLength; // Optional: Allows multi-line input
  final int maxLines; // Optional: Allows multi-line input
  final bool enabled; // Optional: Allows multi-line input
  final List<TextInputFormatter>? inputFormatters;


  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1, // Default single-line, can be changed
    this.enabled = true,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
