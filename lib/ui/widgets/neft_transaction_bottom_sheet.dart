import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'dart:io';

import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class NeftTransactionBottomSheet extends StatefulWidget {
  final Function(String) onSubmit;

  const NeftTransactionBottomSheet({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _NeftTransactionBottomSheetState createState() => _NeftTransactionBottomSheetState();
}

class _NeftTransactionBottomSheetState extends State<NeftTransactionBottomSheet> {
  final TextEditingController transactionController = TextEditingController();
  File? _selectedImage;

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    widget.onSubmit(transactionController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Full white background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0, bottom: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10), // Ensures space below close button
                  Text(
                    "Upload Image",
                    style: FontUtils.gabaritoStyle(fontSize: 17.0),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                          : Icon(Icons.add, size: 45, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    "Enter Description",
                    style: FontUtils.gabaritoStyle(fontSize: 17.0),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Enter transaction ID / Any description",
                    controller: transactionController,
                    validator: (value) {
                      return null;
                    },
                    maxLines: 3,
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Submit",
                      style: FontUtils.circularStdStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Close Button Positioned Absolutely
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, size: 25),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
