import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_colors.dart';
import '../../utility/rich_text_helper.dart';

class AddressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String address;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isFromEdit;
  final String? customerSupport;

  const AddressCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.address,
    required this.onDelete,
    required this.onEdit,
    this.isFromEdit = true,
    this.customerSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.primary.withAlpha(20), width: 1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8,),
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.profileItemArrowColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(left: 36.0),
                child: Text(
                  address,
                  style:  FontUtils.primaryFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.profileItemArrowColor,
                  ),
                ),
              ),
              // Visibility(
              //   visible: isFromEdit,
              //   child: Container(
              //     margin: const EdgeInsets.only(left: 16.0),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         TextButton(
              //           onPressed: onEdit,
              //           child:  Text(
              //             AppStrings.edit,
              //             style: FontUtils.primaryFontStyle(
              //               color: AppColors.primary,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //         const SizedBox(width: 16),
              //         Visibility(
              //           visible:false,
              //           child: TextButton(
              //             style: TextButton.styleFrom(
              //               padding:  EdgeInsets.zero, // Removes the default padding
              //               minimumSize: const Size(0, 0), // Ensures no extra size is added
              //               tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks the tap area
              //             ),
              //             onPressed: onDelete,
              //             child:  Text(
              //               AppStrings.delete,
              //               style: FontUtils.primaryFontStyle(
              //                 color: AppColors.primary,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // Visibility(visible: !isFromEdit,child:
              // const SizedBox(height: 8),)
              const SizedBox(height: 8),
            ],
          ),
        ),
        RichTextHelper(
          segments: [
            RichTextSegment(text: 'Note: ',textStyle: TextStyle(fontSize:12,fontWeight: FontWeight.bold,color: Colors.black)),
            RichTextSegment(text: 'To Change/Edit address. Please contact',textStyle: TextStyle(fontSize:12,color: Colors.black)),
            RichTextSegment(text: ' GoWelMart Support',textStyle: TextStyle(fontSize:12,color: Color(0xFF0066CC)),onTap: (){
              _launchPhoneDialer(customerSupport??AppStrings.customerSupport);
            }),
          ],
        ),
      ],
    );

  }

  void _launchPhoneDialer(String phoneNumber) async {
    // Remove any non-digit characters except +
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Create tel: URI (works on both Android and iOS)
    final Uri telUri = Uri(scheme: 'tel', path: cleanedNumber);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      throw 'Could not launch dialer';
    }
  }
}
