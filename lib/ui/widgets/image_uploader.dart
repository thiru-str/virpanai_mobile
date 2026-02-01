import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';



class ImageUploader extends StatelessWidget {
  final String label;
  final File? imageFile;
  final bool isUploading;
  final VoidCallback onTap;

  const ImageUploader({
    super.key,
    required this.label,
    required this.imageFile,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: isUploading ? null : onTap,
          child: DottedBorder(
            color: AppColors.primary,
            strokeWidth: 1.5,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            child: Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(8),
              child: _buildContent(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContent() {
    if (isUploading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.cloud_upload_outlined, size: 40),
        SizedBox(height: 10),
        Text("Click to upload"),
        SizedBox(height: 4),
        Text(
          "(Max 5 MB)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
