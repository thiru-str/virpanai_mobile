import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/app_colors.dart';

// ─── Payment provider metadata ────────────────────────────────────────────────

class _ProviderMeta {
  final String displayName;
  final String subtitle;
  final String ctaLabel;
  final IconData icon;
  final Color color;

  const _ProviderMeta({
    required this.displayName,
    required this.subtitle,
    required this.ctaLabel,
    required this.icon,
    required this.color,
  });
}

_ProviderMeta _meta(String? id, {String? walletBalanceLabel}) {
  switch (id) {
    case 'pp_razorpay_razorpay':
      return const _ProviderMeta(
        displayName: 'Razorpay',
        subtitle: 'UPI · Cards · Net banking · Wallets',
        ctaLabel: 'Pay Online · Razorpay',
        icon: Icons.bolt_rounded,
        color: Color(0xFF2D81F7),
      );
    case 'pp_payu_payu':
      return const _ProviderMeta(
        displayName: 'PayU',
        subtitle: 'UPI · Cards · Net banking · Wallets',
        ctaLabel: 'Pay Online · PayU',
        icon: Icons.credit_card_rounded,
        color: Color(0xFF6CB33F),
      );
    case 'pp_paytm_paytm':
      return const _ProviderMeta(
        displayName: 'Paytm',
        subtitle: 'UPI · Cards · Net banking · Wallets',
        ctaLabel: 'Pay Online · Paytm',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF00BAF2),
      );
    case 'pp_icici_icici':
      return const _ProviderMeta(
        displayName: 'ICICI Bank',
        subtitle: 'Redirects to ICICI Bank payment page',
        ctaLabel: 'Pay Online · ICICI Bank',
        icon: Icons.account_balance_rounded,
        color: Color(0xFFE87722),
      );
    case 'pp_neft_neft':
      return const _ProviderMeta(
        displayName: 'Bank Transfer (NEFT)',
        subtitle: 'Bank details provided after placing order',
        ctaLabel: 'Confirm Order · Bank Transfer',
        icon: Icons.swap_horiz_rounded,
        color: Color(0xFF1565C0),
      );
    case 'pp_wallet_wallet':
      return _ProviderMeta(
        displayName: 'Wallet',
        subtitle: walletBalanceLabel ?? 'Pay from wallet balance',
        ctaLabel: 'Pay with Wallet',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF2E7D32),
      );
    case 'pp_system_default':
      return const _ProviderMeta(
        displayName: 'Cash on Delivery',
        subtitle: 'Pay when your order arrives',
        ctaLabel: 'Place Order · Cash on Delivery',
        icon: Icons.local_shipping_rounded,
        color: Color(0xFF3EAA3C),
      );
    case 'pp_stripe_stripe':
      return const _ProviderMeta(
        displayName: 'Credit / Debit Card',
        subtitle: 'Powered by Stripe',
        ctaLabel: 'Pay Online · Card',
        icon: Icons.credit_card_rounded,
        color: Color(0xFF635BFF),
      );
    default:
      return _ProviderMeta(
        displayName: 'Payment',
        subtitle: '',
        ctaLabel: 'Place Order',
        icon: Icons.payment_rounded,
        color: AppColors.primary,
      );
  }
}

// ─── Bottom sheet widget ───────────────────────────────────────────────────────

class PaymentMethodsBottomSheet extends StatefulWidget {
  final List<PaymentProvider> paymentProviders;
  final String? providerId;
  final Function(PaymentProvider paymentProvider) onPaymentSelected;
  final double? walletBalance;

  /// When true: tapping a tile only selects it; a sticky CTA button
  /// at the bottom fires [onPaymentSelected] and closes the sheet.
  /// When false (default): tapping a tile fires immediately and closes.
  final bool showConfirmButton;

  const PaymentMethodsBottomSheet({
    Key? key,
    required this.paymentProviders,
    required this.providerId,
    required this.onPaymentSelected,
    this.walletBalance,
    this.showConfirmButton = false,
  }) : super(key: key);

  @override
  State<PaymentMethodsBottomSheet> createState() =>
      _PaymentMethodsBottomSheetState();
}

class _PaymentMethodsBottomSheetState
    extends State<PaymentMethodsBottomSheet> {
  late String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.providerId;
  }

  PaymentProvider? get _selectedProvider => widget.paymentProviders
      .where((p) => p.id == _selectedId)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final selectedMeta = _selectedProvider != null
        ? _meta(_selectedId,
            walletBalanceLabel: _selectedProvider!.id == 'pp_wallet_wallet' &&
                    widget.walletBalance != null
                ? 'Balance: ₹${widget.walletBalance!.toStringAsFixed(2)}'
                : null)
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Scrollable method list
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.payemnt_method,
                      style: FontUtils.secondaryFontStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF272727),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select how you\'d like to pay',
                      style: FontUtils.primaryFontStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...List.generate(widget.paymentProviders.length, (i) {
                      final provider = widget.paymentProviders[i];
                      final isSelected = _selectedId == provider.id;
                      final walletLabel = provider.id == 'pp_wallet_wallet' &&
                              widget.walletBalance != null
                          ? 'Balance: ₹${widget.walletBalance!.toStringAsFixed(2)}'
                          : null;
                      final meta = _meta(provider.id,
                          walletBalanceLabel: walletLabel);
                      final displayName =
                          (provider.name?.isNotEmpty == true)
                              ? provider.name!
                              : meta.displayName;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PaymentTile(
                          displayName: displayName,
                          subtitle: provider.id == 'pp_wallet_wallet' &&
                                  walletLabel != null
                              ? walletLabel
                              : meta.subtitle,
                          icon: meta.icon,
                          color: meta.color,
                          isSelected: isSelected,
                          onTap: () {
                            if (widget.showConfirmButton) {
                              // Confirm mode — just update selection, keep sheet open
                              setState(() => _selectedId = provider.id);
                            } else {
                              // Immediate mode — fire and close
                              widget.onPaymentSelected(provider);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Sticky confirm CTA (confirm mode only)
            if (widget.showConfirmButton && selectedMeta != null) ...[
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedProvider == null
                        ? null
                        : () {
                            widget.onPaymentSelected(_selectedProvider!);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedMeta.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(selectedMeta.icon, size: 18, color: Colors.white),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            selectedMeta.ctaLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Individual tile ───────────────────────────────────────────────────────────

class _PaymentTile extends StatefulWidget {
  final String displayName;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.displayName,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PaymentTile> createState() => _PaymentTileState();
}

class _PaymentTileState extends State<_PaymentTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.color.withValues(alpha: 0.06)
              : _pressed
                  ? Colors.grey.shade50
                  : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected
                ? widget.color.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
            const SizedBox(width: 14),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.displayName,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF272727),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    widget.isSelected ? widget.color : Colors.transparent,
                border: Border.all(
                  color: widget.isSelected
                      ? widget.color
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: widget.isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
