import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../utility/app_assets.dart';
import '../../utility/app_colors.dart';

class PaymentMethodsBottomSheet extends StatelessWidget {
  final List<PaymentProvider> paymentProviders;
  final String? providerId;
  final Function(PaymentProvider paymentProvider) onPaymentSelected;

  const PaymentMethodsBottomSheet({
    Key? key,
    required this.paymentProviders,
    required this.providerId,
    required this.onPaymentSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.payemnt_method,
            style: FontUtils.secondaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Main white box with rounded border
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Column(
              children: List.generate(paymentProviders.length, (index) {
                final provider = paymentProviders[index];
                final isSelected = providerId == provider.id;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      onTap: () {
                        onPaymentSelected(provider);
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _getProviderIcon(provider.id),
                      ),
                      title: Text(
                        provider.name ?? '',
                        style: FontUtils.primaryFontStyle(fontSize: 16),
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.primary : AppColors.primary.withAlpha(50),
                      ),
                    ),

                    // ✅ Divider except last item
                    if (index != paymentProviders.length - 1)
                      Divider(
                        color: Colors.grey.shade300,
                        indent: 12,
                        endIndent: 12,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProviderIcon(String? providerId) {
    switch (providerId) {
      case "pp_system_default":
        return SvgPicture.asset(AppAssets.ic_payment_cash, width: 24, height: 24);

      case "pp_razorpay_razorpay":
        return SvgPicture.asset(AppAssets.ic_online, width: 24, height: 24);

      case "pp_neft_neft":
        return SvgPicture.asset(AppAssets.ic_bank_transfer, width: 24, height: 24);

      default:
        return SvgPicture.asset(AppAssets.ic_payment_cash, width: 24, height: 24);
    }
  }


}
