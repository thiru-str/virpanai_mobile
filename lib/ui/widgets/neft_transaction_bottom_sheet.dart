import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/ui/widgets/custom_text_field.dart';
import 'dart:io';

import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

class NeftTransactionBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit; // Change from String to Map

  const NeftTransactionBottomSheet({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _NeftTransactionBottomSheetState createState() => _NeftTransactionBottomSheetState();
}

class _NeftTransactionBottomSheetState extends State<NeftTransactionBottomSheet> {
  final TextEditingController transactionController = TextEditingController();
  File? _selectedImage;
  String? _uploadedFileName;

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      var response = await ApiService().uploadImage(context, _selectedImage!);

      if (response != null && response['file'] != null) {
        setState(() {
          _uploadedFileName = response['file']['path']; // Store file name
        });
        print('Uploaded File Name: $_uploadedFileName');
      } else {
        print('File upload failed or invalid response');
      }
    }
  }

  void _submit() {

    String descriptionTxt = transactionController.text;

    if (descriptionTxt.isEmpty) {
      print('Transaction ID is required');
      return;
    }

    if (_uploadedFileName == null) {
      print('Please upload an image before submitting');
      return;
    }

    var payload = {
      "description": descriptionTxt,
      "image": _uploadedFileName,
    };

    widget.onSubmit(payload); // Pass the entire payload
    Navigator.pop(context); // Close the bottom sheet

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
                   AppStrings.upload_image,
                    style: FontUtils.secondaryFontStyle(fontSize: 17.0),
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
                        child: Image.file(_selectedImage!, fit: BoxFit.contain),
                      )
                          : Icon(Icons.add, size: 45, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    AppStrings.enter_desc,
                    style: FontUtils.secondaryFontStyle(fontSize: 17.0),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: AppStrings.enter_transaction_id,
                    
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
                      AppStrings.submit,
                      style: FontUtils.primaryFontStyle(
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
