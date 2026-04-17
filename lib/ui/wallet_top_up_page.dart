import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wallet_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_utils.dart';

class WalletTopUpPage extends StatefulWidget {
  const WalletTopUpPage({super.key});

  @override
  State<WalletTopUpPage> createState() => _WalletTopUpPageState();
}

class _WalletTopUpPageState extends State<WalletTopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  bool loading = false;
  bool loadingConfig = true;
  int? selectedPreset;
  TopUpConfig? topupConfig;
  Razorpay? _razorpay;

  final List<int> defaultPresets = [100, 200, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _loadTopUpConfig();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> _loadTopUpConfig() async {
    try {
      final walletData = await ApiService().getWalletBalance(context);
      if (mounted) {
        setState(() {
          topupConfig = walletData.topupConfig;
          loadingConfig = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loadingConfig = false);
      debugPrint('Error loading top-up config: $e');
    }
  }

  List<int> get presetAmounts {
    if (topupConfig == null) return defaultPresets;
    return defaultPresets
        .where((a) =>
            a >= topupConfig!.minTopupAmount && a <= topupConfig!.maxTopupAmount)
        .toList();
  }

  void _selectPreset(int amount) {
    setState(() {
      selectedPreset = amount;
      _amountController.text = amount.toString();
    });
  }

  Future<void> _handleTopUp() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      AppUtils.showToast('Please enter a valid amount');
      return;
    }

    if (topupConfig != null) {
      if (amount < topupConfig!.minTopupAmount) {
        AppUtils.showToast(
            'Minimum top-up amount is ₹${topupConfig!.minTopupAmount.toStringAsFixed(0)}');
        return;
      }
      if (amount > topupConfig!.maxTopupAmount) {
        AppUtils.showToast(
            'Maximum top-up amount is ₹${topupConfig!.maxTopupAmount.toStringAsFixed(0)}');
        return;
      }
    }

    setState(() => loading = true);

    try {
      final result = await ApiService().initiateWalletTopUp(context, amount);

      if (result.razorpayOrderId != null && result.razorpayKey != null) {
        _openRazorpay(result, amount);
      } else {
        setState(() => loading = false);
        AppUtils.showToast('Top-up is not available right now');
      }
    } catch (e) {
      setState(() => loading = false);
      AppUtils.showToast('Failed to initiate top-up');
      debugPrint('Top-up error: $e');
    }
  }

  void _openRazorpay(WalletTopUpResponse result, double amount) {
    _razorpay = Razorpay();

    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (PaymentSuccessResponse response) async {
      // Confirm top-up on backend
      try {
        await ApiService().confirmWalletTopUp(
          context,
          response.paymentId!,
          amount,
        );
        AppUtils.showToast('₹${amount.toStringAsFixed(0)} added to wallet');
      } catch (e) {
        debugPrint('Failed to confirm top-up: $e');
        AppUtils.showToast('Payment received. Balance will update shortly.');
      }

      _razorpay?.clear();
      if (mounted) {
        setState(() => loading = false);
        Navigator.pop(context, true); // Return true to refresh wallet page
      }
    });

    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
      _razorpay?.clear();
      if (mounted) setState(() => loading = false);
      AppUtils.showToast('Payment failed. Please try again.');
    });

    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET,
        (ExternalWalletResponse response) {});

    var options = {
      'key': result.razorpayKey ?? AppConfig.razorPayKey,
      'amount': (amount * 100).toInt(),
      'order_id': result.razorpayOrderId,
      'name': AppConfig.appName,
      'description': 'Wallet Top-Up',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'theme': {'color': AppUtils.colorToHex(AppColors.primary)},
    };
    _razorpay!.open(options);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingConfig) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Money to Wallet')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (topupConfig != null && !topupConfig!.canTopUp) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Money to Wallet')),
        body: const Center(
          child: Text(
            'Wallet top-up is currently not available',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Money to Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              ),
              onChanged: (_) {
                setState(() => selectedPreset = null);
              },
            ),

            if (topupConfig != null) ...[
              const SizedBox(height: 4),
              Text(
                'Min: ₹${topupConfig!.minTopupAmount.toStringAsFixed(0)} · Max: ₹${topupConfig!.maxTopupAmount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],

            const SizedBox(height: 20),

            // Quick Select label
            if (presetAmounts.isNotEmpty) ...[
              Text(
                'Quick Select',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
            ],

            // Preset Amounts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presetAmounts.map((amount) {
                final isSelected = selectedPreset == amount;
                return GestureDetector(
                  onTap: () => _selectPreset(amount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹$amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // Add Money Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _handleTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _amountController.text.isNotEmpty
                            ? 'Pay ₹${_amountController.text}'
                            : 'Enter amount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
