import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/wallet_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';

const Color _kScaffoldBg = Color(0xFFF9F9FB);
const Color _kHairline = Color(0xFFE5E7EC);

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

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      scrolledUnderElevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.primary),
      title: Text(
        'Add Money to Wallet',
        style: UiTypography.cardTitle(color: Colors.black87)
            .copyWith(fontSize: 20, height: 1.25, letterSpacing: -0.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingConfig) {
      return Scaffold(
        backgroundColor: _kScaffoldBg,
        appBar: _appBar(),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (topupConfig != null && !topupConfig!.canTopUp) {
      return Scaffold(
        backgroundColor: _kScaffoldBg,
        appBar: _appBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.lock_outline,
                    size: 32, color: AppColors.primary.withOpacity(0.7)),
              ),
              const SizedBox(height: 14),
              Text(
                'Wallet top-up is currently not available',
                style: UiTypography.cardSubtitle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kScaffoldBg,
      appBar: _appBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Amount',
                            style: UiTypography.cardTitle().copyWith(
                                fontSize: 18, letterSpacing: -0.2),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixText: '₹ ',
                              prefixStyle: FontUtils.primaryFontStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              hintText: '0.00',
                              hintStyle: FontUtils.primaryFontStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (_) {
                              setState(() => selectedPreset = null);
                            },
                          ),
                          if (topupConfig != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Min: ₹${topupConfig!.minTopupAmount.toStringAsFixed(0)} · Max: ₹${topupConfig!.maxTopupAmount.toStringAsFixed(0)}',
                              style: UiTypography.cardMeta(
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Quick Select label
                    if (presetAmounts.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text(
                        'Quick Select',
                        style: UiTypography.cardTitle()
                            .copyWith(fontSize: 18, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 12),
                      // Preset Amounts
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: presetAmounts.map((amount) {
                          final isSelected = selectedPreset == amount;
                          return GestureDetector(
                            onTap: () => _selectPreset(amount),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '₹$amount',
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Add Money Button (bottom, thumb-reachable)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _kHairline)),
              ),
              child: ElevatedButton(
                onPressed: loading ? null : _handleTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _amountController.text.isNotEmpty
                            ? 'Pay ₹${_amountController.text}'
                            : 'Add money',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
