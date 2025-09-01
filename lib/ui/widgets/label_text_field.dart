import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.inputType = TextInputType.text,
    this.validator,
    this.isPassword = false,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late final ValueNotifier<bool> _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = ValueNotifier(widget.isPassword);
  }

  @override
  void dispose() {
    _obscureText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<bool>(
            valueListenable: _obscureText,
            builder: (context, obscure, _) {
              return TextFormField(
                controller: widget.controller,
                keyboardType: widget.inputType,
                obscureText: widget.isPassword ? obscure : false,
                validator: widget.validator,
                inputFormatters: widget.inputFormatters,
                maxLength: widget.maxLength,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => _obscureText.value = !obscure,
                  )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}