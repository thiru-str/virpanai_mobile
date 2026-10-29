import 'package:flutter/material.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_colors.dart';
import '../../utility/currency_util.dart';
import 'cart_calculation.dart';

class CalculationBottomSheet extends StatelessWidget {
  final CartResponse? cartResponse;

  const CalculationBottomSheet({
    Key? key,
    required this.cartResponse,
  }) : super(key: key);

  double _doubleFromDynamic(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  Map<String, dynamic> _cartMetadataMap() {
    final metadata = cartResponse?.cart?.metadata;
    if (metadata is Map<String, dynamic>) {
      return metadata;
    }
    if (metadata is Map) {
      return Map<String, dynamic>.from(metadata);
    }
    return const {};
  }

  double _platformFeeTotal() {
    return (cartResponse?.cart?.items ?? [])
        .where((item) => item.isPlatformFee)
        .fold<double>(0, (sum, item) => sum + _doubleFromDynamic(item.total));
  }

  double _walletAmount() {
    final metadata = _cartMetadataMap();
    if (metadata['wallet_auto_apply_dismissed'] == true) {
      return 0;
    }
    final walletSplit = metadata['wallet_split'];
    if (walletSplit is Map) {
      return _doubleFromDynamic(walletSplit['wallet_amount']);
    }
    return 0;
  }

  double _loyaltyDiscountAmount() {
    final loyaltyMeta = _cartMetadataMap()['loyalty_checkout_apply'];
    if (loyaltyMeta is Map) {
      return _doubleFromDynamic(loyaltyMeta['discount_amount']);
    }
    return 0;
  }

  double _displayTotalAmount() {
    final total = _doubleFromDynamic(cartResponse?.cart?.total);
    return (total - _walletAmount() - _loyaltyDiscountAmount())
        .clamp(0, double.infinity);
  }

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
                ((cartResponse!.cart!.itemSubtotal ?? 0) - _platformFeeTotal())
                    .toStringAsFixed(2)),
          ),
          Visibility(
              visible: cartResponse!.cart!.discountSubtotal! > 0,
              child: CartCalculation(
                keyText: '${AppStrings.discount}:',
                valueText:
                    '- ${CurrencyUtil.appendCurrency(cartResponse!.cart!.discountSubtotal!.toStringAsFixed(2))}',
              )),
          Visibility(
              visible: cartResponse!.cart!.shippingSubtotal! > 0,
              child: CartCalculation(
                keyText: '${AppStrings.shipping}:',
                valueText: CurrencyUtil.appendCurrency(
                    cartResponse!.cart!.shippingSubtotal!.toStringAsFixed(2)),
              )),
          if ((cartResponse!.cart!.items?.any((item) => item.isPlatformFee) ??
                  false) &&
              _platformFeeTotal() > 0)
            CartCalculation(
              keyText: '${AppStrings.platform_fee}:',
              valueText: CurrencyUtil.appendCurrency(
                  _platformFeeTotal().toStringAsFixed(2)),
            ),
          Visibility(
            visible: (cartResponse?.cart?.taxTotal ?? 0) > 0,
            child: CartCalculation(
              keyText: '${AppStrings.tax}:',
              valueText: CurrencyUtil.appendCurrency(
                  cartResponse!.cart!.taxTotal!.toStringAsFixed(2)),
            ),
          ),
          if (_walletAmount() > 0)
            CartCalculation(
              keyText: 'Wallet:',
              valueText:
                  '- ${CurrencyUtil.appendCurrency(_walletAmount().toStringAsFixed(2))}',
            ),
          if (_loyaltyDiscountAmount() > 0)
            CartCalculation(
              keyText: 'Loyalty:',
              valueText:
                  '- ${CurrencyUtil.appendCurrency(_loyaltyDiscountAmount().toStringAsFixed(2))}',
            ),
          CartCalculation(
            keyText: '${AppStrings.total}:',
            keyStyle: FontUtils.primaryFontStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.bold),
            valueStyle: FontUtils.primaryFontStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.bold),
            valueText: CurrencyUtil.appendCurrency(
                _displayTotalAmount().toStringAsFixed(2)),
          ),
        ],
      ),
    );
  }
}
