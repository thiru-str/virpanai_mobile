import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wallet_response.dart';
import 'package:waioz/utility/app_colors.dart';

class WalletCheckoutWidget extends StatefulWidget {
  final String cartId;
  final Function(double walletAmount, double remainingAmount)? onWalletApplied;
  final Function()? onWalletRemoved;

  const WalletCheckoutWidget({
    super.key,
    required this.cartId,
    this.onWalletApplied,
    this.onWalletRemoved,
  });

  @override
  State<WalletCheckoutWidget> createState() => _WalletCheckoutWidgetState();
}

class _WalletCheckoutWidgetState extends State<WalletCheckoutWidget> {
  WalletCheckoutResponse? checkoutInfo;
  bool loading = true;
  bool applying = false;
  bool applied = false;
  double walletAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadCheckoutInfo();
  }

  Future<void> _loadCheckoutInfo() async {
    try {
      final info = await ApiService().getWalletCheckoutInfo(
        context,
        widget.cartId,
      );
      if (mounted) {
        setState(() {
          checkoutInfo = info;
          loading = false;
        });

        // Auto-apply if enabled
        if (info.autoApply && info.canUseWallet && info.applicableAmount > 0) {
          _applyWallet();
        }
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
      debugPrint('Error loading wallet checkout info: $e');
    }
  }

  Future<void> _applyWallet() async {
    setState(() => applying = true);
    try {
      final result = await ApiService().applyWalletToCheckout(
        context,
        widget.cartId,
      );
      if (mounted && result.applied) {
        setState(() {
          applied = true;
          walletAmount = result.walletAmount;
          applying = false;
        });
        widget.onWalletApplied?.call(result.walletAmount, result.remainingAmount);
      }
    } catch (e) {
      if (mounted) setState(() => applying = false);
      debugPrint('Error applying wallet: $e');
    }
  }

  Future<void> _removeWallet() async {
    setState(() => applying = true);
    try {
      await ApiService().removeWalletFromCheckout(context, widget.cartId);
      if (mounted) {
        setState(() {
          applied = false;
          walletAmount = 0;
          applying = false;
        });
        widget.onWalletRemoved?.call();
      }
    } catch (e) {
      if (mounted) setState(() => applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox.shrink();
    if (checkoutInfo == null || !checkoutInfo!.canUseWallet) {
      return const SizedBox.shrink();
    }
    if (checkoutInfo!.walletBalance <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '₹${checkoutInfo!.walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (applied)
                  Text(
                    'Applied: -₹${walletAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (applying)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (applied)
            TextButton(
              onPressed: _removeWallet,
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
          else
            ElevatedButton(
              onPressed: _applyWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Use ₹${checkoutInfo!.applicableAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
