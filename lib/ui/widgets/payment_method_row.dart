

import 'package:flutter/material.dart';

import '../../model/home_page_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/font_utils.dart';
import '../../utility/shared_preferences_util.dart';

class PaymentMethodRow extends StatelessWidget {
  final String selectedMethod;
  final VoidCallback onTap;

  const PaymentMethodRow({
    Key? key,
    required this.selectedMethod,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Payment Method",
          style: FontUtils.primaryFontStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10,),
                Text(
                  selectedMethod,
                  style: FontUtils.primaryFontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -1.5),
                  child: const Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<Global?> getGlobal() async {
    dynamic global = await SharedPreferencesUtil().getMap('global');
    if (global != null) {
      return Global.fromJson(global);
    }
    return null;
  }

}
