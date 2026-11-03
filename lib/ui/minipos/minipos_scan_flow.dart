import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_temp_cart.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

/// Preview stays on the caller's page. Only a confirmed, successful add returns a cart.
Future<Map<String, dynamic>?> scanMiniPosPhone(BuildContext context) async {
  try {
    final code = await Navigator.push<String>(
        context, MaterialPageRoute(builder: (_) => const _MiniPosScanner()));
    if (code == null || !context.mounted) return null;
    final result = await MiniPosService.instance
        .post('minipos/cart/scan', {'imei': code.trim(), 'transient': true});
    if (!context.mounted) return null;
    final product = Map<String, dynamic>.from(result['product']);
    final cart = MiniPosTempCart.instance;
    await cart.bindToCurrentAccount();
    if (cart.containsImei('${product['imei']}')) {
      throw const FormatException('This IMEI is already in your cart.');
    }
    final currentPrice = cart.priceForVariant('${product['variant_id']}');
    if (currentPrice != null) product['selling_price'] = currentPrice;
    final variant = '${product['variant_title'] ?? ''}'.trim();
    final imageUrl = '${product['thumbnail'] ?? ''}'.trim();
    final showVariant = variant.isNotEmpty &&
        !RegExp(r'^default( variant| option| title)?\b', caseSensitive: false)
            .hasMatch(variant);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF5FEF2),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.primary),
        ),
        scrollable: true,
        title: Row(children: [
          Icon(Icons.check_circle_outline, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(child: Text('Product found')),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Check this product before adding it to the cart.',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl.isEmpty
                      ? const _ScannedPhoneImageFallback()
                      : Image.network(
                          Uri.encodeFull(imageUrl),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const _ScannedPhoneImageFallback(),
                        ),
                ),
                const SizedBox(height: 12),
                Text('${product['product_title'] ?? 'Product'}',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                if (showVariant) ...[
                  const SizedBox(height: 4),
                  Text(variant,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            _ScannedDetailRow(label: 'IMEI', value: '${product['imei']}'),
            const SizedBox(height: 12),
            _ScannedDetailRow(
              label: 'Selling price',
              value: miniPosMoney(product['selling_price']),
              highlight: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return null;
    cart.add(product);
    if (!context.mounted) return null;
    return cart.snapshot();
  } catch (e) {
    if (context.mounted) miniPosMessage(context, e);
  }
  return null;
}

class _ScannedDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ScannedDetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 104,
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  softWrap: true,
                  style: TextStyle(
                      fontSize: highlight ? 18 : 15,
                      fontWeight: FontWeight.w700,
                      color: highlight ? AppColors.primary : Colors.black87)),
            ),
          ],
        ),
      );
}

class _ScannedPhoneImageFallback extends StatelessWidget {
  const _ScannedPhoneImageFallback();

  @override
  Widget build(BuildContext context) => Center(
        child: Icon(Icons.inventory_2_outlined,
            size: 36, color: AppColors.primary),
      );
}

class _MiniPosScanner extends StatefulWidget {
  const _MiniPosScanner();
  @override
  State<_MiniPosScanner> createState() => _MiniPosScannerState();
}

class _MiniPosScannerState extends State<_MiniPosScanner> {
  final _imeiForm = GlobalKey<FormState>();
  final _imeiController = TextEditingController();
  final _imeiFocus = FocusNode();
  bool _done = false;

  @override
  void dispose() {
    _imeiController.dispose();
    _imeiFocus.dispose();
    super.dispose();
  }

  Future<void> _findPhone() async {
    if (_done || _imeiForm.currentState?.validate() != true) return;
    _done = true;
    final imei = _imeiController.text.trim();
    _imeiFocus.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    final deadline = DateTime.now().add(const Duration(milliseconds: 700));
    while (mounted &&
        MediaQuery.viewInsetsOf(context).bottom > 0 &&
        DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    if (!mounted) return;
    Navigator.pop(context, imei);
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
      appBar: AppBar(title: const Text('Scan IMEI')),
      body: LayoutBuilder(builder: (context, constraints) {
        final cameraSize = math.min(
            360.0,
            math.min(constraints.maxWidth - 40,
                math.max(220.0, constraints.maxHeight * 0.48)));
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Scan the product IMEI barcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 22),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox.square(
                      dimension: cameraSize,
                      child: Stack(children: [
                        MobileScanner(onDetect: (capture) {
                          if (_done || _imeiFocus.hasFocus) return;
                          for (final barcode in capture.barcodes) {
                            final value = barcode.rawValue?.trim();
                            if (value == null ||
                                !RegExp(r'^\d{15}$').hasMatch(value)) {
                              continue;
                            }
                            _done = true;
                            Navigator.pop(context, value);
                            return;
                          }
                        }),
                        Center(
                          child: Container(
                            width: cameraSize * 0.74,
                            height: cameraSize * 0.54,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or enter IMEI manually',
                        style: TextStyle(color: Colors.black54)),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 18),
                Form(
                  key: _imeiForm,
                  child: TextFormField(
                    controller: _imeiController,
                    focusNode: _imeiFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter IMEI',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) =>
                        RegExp(r'^\d{15}$').hasMatch(value?.trim() ?? '')
                            ? null
                            : 'Enter a valid 15-digit IMEI',
                    onFieldSubmitted: (_) => _findPhone(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _findPhone,
                  child: const Text('Find product'),
                ),
              ],
            ),
          ),
        );
      }));
}
