import 'package:flutter/material.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_colors.dart';

class AddressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String address;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isFromEdit;

  const AddressCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.address,
    required this.onDelete,
    required this.onEdit,
    this.isFromEdit = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Visibility(
            visible: isFromEdit,
            child: Container(
              margin: const EdgeInsets.only(left: 36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding:  EdgeInsets.zero, // Removes the default padding
                      minimumSize: const Size(0, 0), // Ensures no extra size is added
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks the tap area
                    ),
                    onPressed: onDelete,
                    child:  Text(
                     AppStrings.delete,
                      style: FontUtils.primaryFontStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: onEdit,
                    child:  Text(
                      AppStrings.edit,
                      style: FontUtils.primaryFontStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(visible: !isFromEdit,child:
          const SizedBox(height: 8),)
        ],
      ),
    );
  }
}
