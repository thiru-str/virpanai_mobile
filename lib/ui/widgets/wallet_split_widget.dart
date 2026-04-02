import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wallet_response.dart';
import 'package:waioz/utility/app_colors.dart';

class WalletSplitWidget extends StatefulWidget {
  final String cartId;
  final double cartTotal;
  final Function(double walletAmount, double gatewayAmount, bool fullCoverage)?
      onSplitApplied;
  final Function()? onSplitRemoved;
  final Function(bool isSplitMode)? onModeDetected;

  const WalletSplitWidget({
    super.key,
    required this.cartId,
    required this.cartTotal,
    this.onSplitApplied,
    this.onSplitRemoved,
    this.onModeDetected,
  });

  @override
  State<WalletSplitWidget> createState() => _WalletSplitWidgetState();
}

class _WalletSplitWidgetState extends State<WalletSplitWidget> {
  bool loading = true;
  bool toggling = false;
  bool walletApplied = false;
  double walletBalance = 0;
  double walletAmount = 0;
  double gatewayAmount = 0;
  String walletMode = 'full_payment';

  @override
  void initState() {
    super.initState();
    _loadAndApply();
  }

  Future<void> _loadAndApply() async {
    try {
      final walletData = await ApiService().getWalletBalance(context);
      final balance = walletData.wallet?.balance ?? 0;
      final mode = walletData.walletMode ?? 'full_payment';

      if (!mounted) return;
      setState(() {
        walletBalance = balance;
        walletMode = mode;
      });

      // Notify parent about the mode (so it can filter wallet from payment methods)
      widget.onModeDetected?.call(mode == 'split_payment');

      if (mode != 'split_payment' || balance <= 0) {
        setState(() => loading = false);
        return;
      }

      // If auto-apply is off, show banner with toggle but don't apply
      if (!walletData.autoApplyWallet) {
        setState(() {
          gatewayAmount = widget.cartTotal;
          loading = false;
        });
        return;
      }

      // Auto-apply split
      final splitResult =
          await ApiService().applyWalletSplit(context, widget.cartId);
      if (mounted && splitResult.walletApplied) {
        setState(() {
          walletApplied = true;
          walletAmount = splitResult.walletAmount;
          gatewayAmount = splitResult.gatewayAmount;
        });
        widget.onSplitApplied?.call(
          splitResult.walletAmount,
          splitResult.gatewayAmount,
          splitResult.fullWalletCoverage,
        );
      }
    } catch (e) {
      debugPrint('Error loading wallet split: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _toggleSplit() async {
    setState(() => toggling = true);
    try {
      if (walletApplied) {
        await ApiService().removeWalletSplit(context, widget.cartId);
        if (mounted) {
          setState(() {
            walletApplied = false;
            walletAmount = 0;
            gatewayAmount = widget.cartTotal;
          });
          widget.onSplitRemoved?.call();
        }
      } else {
        final result =
            await ApiService().applyWalletSplit(context, widget.cartId);
        if (mounted && result.walletApplied) {
          setState(() {
            walletApplied = true;
            walletAmount = result.walletAmount;
            gatewayAmount = result.gatewayAmount;
          });
          widget.onSplitApplied?.call(
            result.walletAmount,
            result.gatewayAmount,
            result.fullWalletCoverage,
          );
        }
      }
    } catch (e) {
      debugPrint('Toggle split error: $e');
    } finally {
      if (mounted) setState(() => toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || walletMode != 'split_payment' || walletBalance <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border.all(
          color: walletApplied
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (walletApplied)
                      Text(
                        'Using ₹${walletAmount.toStringAsFixed(2)} from wallet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                  ],
                ),
              ),
              // Toggle switch
              GestureDetector(
                onTap: toggling ? null : _toggleSplit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: walletApplied
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: walletApplied
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: toggling
                          ? const Padding(
                              padding: EdgeInsets.all(3),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Remaining amount info
          if (walletApplied && gatewayAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Remaining to pay',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '₹${gatewayAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Full coverage message
          if (walletApplied && gatewayAmount == 0) ...[
            const SizedBox(height: 8),
            Text(
              'Wallet covers the full order. No additional payment needed.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
