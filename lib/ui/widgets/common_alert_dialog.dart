import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class CommonAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String contentOk;
  final String contentCancel;
  final VoidCallback onTapOk;

  const CommonAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.contentOk,
    required this.contentCancel,
    required this.onTapOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title,style: FontUtils.secondaryFontStyle(color: AppColors.textColor,fontSize: 16,fontWeight: FontWeight.bold),),
      content: Text(content,style: FontUtils.primaryFontStyle(color: AppColors.textColor,fontSize: 14,fontWeight: FontWeight.w400),),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(contentCancel,style: FontUtils.primaryFontStyle(color: AppColors.textColor),),
        ),
        TextButton(
          onPressed: () {
            onTapOk();
          },
          child: Text(contentOk,style:FontUtils.primaryFontStyle(color: AppColors.textColor)),
        ),
      ],
    );
  }

}