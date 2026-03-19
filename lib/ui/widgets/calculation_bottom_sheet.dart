import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';
import '../../utility/currency_util.dart';
import 'cart_calculation.dart';

class CalculationBottomSheet extends StatelessWidget {

  final CartResponse? cartResponse;

  const CalculationBottomSheet({
    Key? key,
    required this.cartResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Payment Info',
            style: FontUtils.secondaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Main white box with rounded border
          CartCalculation(
            keyText: '${AppStrings.subTotal}:',
            valueText: CurrencyUtil.appendCurrency(
              ((cartResponse!.cart!.itemSubtotal ?? 0) -
                  (cartResponse!.cart!.items
                      ?.where((item) => item.isPlatformFee)
                      .fold<num>(0, (sum, item) => sum + (item.total ?? 0)) ?? 0))
                  .toStringAsFixed(2)),
          ),
          Visibility(
              visible: cartResponse!.cart!.discountSubtotal!>0,
              child: CartCalculation(
                keyText: '${AppStrings.discount}:',
                valueText: '- ${CurrencyUtil.appendCurrency(cartResponse!.cart!.discountSubtotal!.toStringAsFixed(2))}',
              )),
          Visibility(
              visible: cartResponse!.cart!.shippingSubtotal!>0,
              child: CartCalculation(
                keyText: '${AppStrings.shipping}:',
                valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.shippingSubtotal!.toStringAsFixed(2)),
              )),
          if ((cartResponse!.cart!.items?.any((item) => item.isPlatformFee) ?? false) &&
              (cartResponse!.cart!.items!.firstWhere((item) => item.isPlatformFee).total ?? 0) > 0)
            CartCalculation(
              keyText: 'Platform Fee:',
              valueText: CurrencyUtil.appendCurrency(
                (cartResponse!.cart!.items!
                    .firstWhere((item) => item.isPlatformFee)
                    .total ?? 0)
                    .toStringAsFixed(2)),
            ),
          Visibility(
            visible: (cartResponse?.cart?.taxTotal??0)>0,
            child: CartCalculation(
              keyText: '${AppStrings.tax}:',
              valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.taxTotal!.toStringAsFixed(2)),
            ),
          ),
          CartCalculation(
            keyText: '${AppStrings.total}:',
            keyStyle: FontUtils.primaryFontStyle(fontSize: 14,color: AppColors.primary,fontWeight: FontWeight.bold),
            valueStyle: FontUtils.primaryFontStyle(fontSize: 14,color: AppColors.primary,fontWeight: FontWeight.bold),
            valueText: CurrencyUtil.appendCurrency(cartResponse!.cart!.total!.toStringAsFixed(2)),
          ),
        ],
      ),
    );
  }


}
