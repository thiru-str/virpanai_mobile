import 'package:flutter/material.dart';
import 'package:waioz/utility/AppColors.dart';

class OpenBoxDialog extends StatefulWidget {
  final ValueChanged<String> onOpenBoxPressed;

  OpenBoxDialog({required this.onOpenBoxPressed});

  static void show(BuildContext context, ValueChanged<String> onOpenBoxPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OpenBoxDialog(onOpenBoxPressed: onOpenBoxPressed);
      },
    );
  }

  @override
  _OpenBoxDialogState createState() => _OpenBoxDialogState();
}

class _OpenBoxDialogState extends State<OpenBoxDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Close Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: const Text(
                        "Open box",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const CircleAvatar(
                        radius: 20, // Adjust size as needed
                        backgroundColor: AppColors.primary, // Background color
                        child: Icon(
                          Icons.close,
                          color: Colors.white, // Icon color
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Label for Opening Cash Balance
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Opening cash balance",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Text Field for Input
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "₹",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: "0.00",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: AppColors.buttonBgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Open Box Button
                ElevatedButton(
                  onPressed: () {
                    widget.onOpenBoxPressed(_controller.text); // Pass input back
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    "Open Box",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
