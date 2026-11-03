import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/ui/widgets/app_shimmer.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/ui_typography.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import 'package:waioz/utility/app_colors.dart';

/// MiniPOS copy of the main cart's item card (kept separate so MiniPOS can change on its own).
class MiniPosCartItemCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String size;
  final String color;
  final String price;
  final String error;
  final int quantity;
  final bool isUpdating;
  final VoidCallback onRemoveAll;
  final VoidCallback onEditPrice;

  const MiniPosCartItemCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
    this.error = '',
    required this.quantity,
    this.isUpdating = false,
    required this.onRemoveAll,
    required this.onEditPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 250),
                              placeholder: (context, url) => const AppShimmer(
                                child: ShimmerBox(
                                  width: 60,
                                  height: 80,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              errorWidget: (context, _, __) =>
                                  const ImageFallbackWidget(w: 60, h: 80),
                            )
                          : const ImageFallbackWidget(w: 60, h: 80),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          size,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: FontUtils.primaryFontStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary),
                        onPressed: isUpdating ? null : onEditPrice,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit price'),
                      ),
                      Row(
                        children: [
                          Text('Qty: $quantity',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 12),
                          if (quantity > 0)
                            GestureDetector(
                              onTap: onRemoveAll,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: error.isNotEmpty,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Text(
                    error,
                    style: FontUtils.secondaryFontStyle(color: Colors.red),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isUpdating)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Center(
              child: AppShimmer(
                child: ShimmerBox(
                  width: 120,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MiniPosCartTotalBar extends StatelessWidget {
  final String amount;
  final bool loading;
  final VoidCallback? onCheckout;

  const MiniPosCartTotalBar({
    super.key,
    required this.amount,
    this.loading = false,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EC))),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, -4),
            blurRadius: 18,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: total amount
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: UiTypography.cardMeta()),
                const SizedBox(height: 1),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTypography.cardPrice(color: AppColors.textColor)
                      .copyWith(fontSize: 22, letterSpacing: -0.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Right: dominant Checkout CTA
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: loading ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withAlpha(128),
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: loading
                    ? const SizedBox(
                        key: ValueKey('loader'),
                        height: 38,
                        child: Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        key: const ValueKey('text'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Checkout',
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18),
                            ],
                          ),
                          const Text(
                            'Online / Card Payment',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniPosCartPriceDialog extends StatefulWidget {
  final int unitPrice;
  final int quantity;
  final Future<bool> Function(int price) checkPrice;
  const MiniPosCartPriceDialog(
      {super.key,
      required this.unitPrice,
      required this.quantity,
      required this.checkPrice});

  @override
  State<MiniPosCartPriceDialog> createState() => _MiniPosCartPriceDialogState();
}

class _MiniPosCartPriceDialogState extends State<MiniPosCartPriceDialog> {
  Timer? _checkTimer;
  int _checkVersion = 0;
  bool _belowCost = false;

  @override
  void initState() {
    super.initState();
    _checkCost();
  }

  void _checkCost() {
    _checkTimer?.cancel();
    final version = ++_checkVersion;
    final value = _price.text.trim();
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return;
    final price = (double.parse(value) * 100).round();
    if (price <= 0) return;
    _checkTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final below = await widget.checkPrice(price);
        if (mounted && version == _checkVersion)
          setState(() => _belowCost = below);
      } catch (_) {
        // Advisory only: a failed price check must not stop a valid price edit.
      }
    });
  }

  late final TextEditingController _price = TextEditingController(
      text: (widget.unitPrice / 100)
          .toStringAsFixed(widget.unitPrice % 100 == 0 ? 0 : 2));
  String? _error;

  void _save() {
    final value = _price.text.trim();
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      setState(
          () => _error = 'Enter a valid price with up to 2 decimal places.');
      return;
    }
    final parts = value.split('.');
    final paise = int.tryParse(parts[0])! * 100 +
        (parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0);
    if (paise <= 0) {
      setState(() => _error = 'Price must be greater than zero.');
      return;
    }
    Navigator.pop(context, paise);
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: AppColors.primary, onPrimary: Colors.white)),
        child: AlertDialog(
          backgroundColor: const Color(0xFFF5FEF2),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: AppColors.primary),
          ),
          scrollable: true,
          title: Row(children: [
            Icon(Icons.edit_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            const Expanded(child: Text('Edit cart price')),
          ]),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    widget.quantity > 1
                        ? 'Price per phone for all ${widget.quantity} phones in this cart item. The saved product price stays unchanged.'
                        : 'This price applies only to this cart. The saved product price stays unchanged.',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 16),
                TextField(
                  controller: _price,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [LengthLimitingTextInputFormatter(12)],
                  decoration: InputDecoration(
                      labelText: 'Price per phone',
                      prefixText: '₹ ',
                      errorText: _error,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      )),
                  onChanged: (_) {
                    setState(() {
                      _error = null;
                      _belowCost = false;
                    });
                    _checkCost();
                  },
                  onSubmitted: (_) => _save(),
                ),
                if (_belowCost)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange.shade800, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(
                                  'Selling price is below cost price. You can still save.',
                                  style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 12))),
                        ]),
                  ),
              ]),
          actions: [
            TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                onPressed: _save,
                child: const Text('Save')),
          ],
        ),
      );
}
