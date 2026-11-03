import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

class MiniPosOrderDetailPage extends StatefulWidget {
  final String orderId;
  final bool paymentCompleted;
  const MiniPosOrderDetailPage(
      {super.key, required this.orderId, this.paymentCompleted = false});

  @override
  State<MiniPosOrderDetailPage> createState() => _MiniPosOrderDetailPageState();
}

class _MiniPosOrderDetailPageState extends State<MiniPosOrderDetailPage> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await MiniPosService.instance.get('minipos/orders/${widget.orderId}');
      if (mounted)
        setState(() => _order = Map<String, dynamic>.from(data['order']));
    } catch (error) {
      debugPrint('[MiniPOS order] Failed to load order: $error');
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    if (_verifying) return;
    setState(() => _verifying = true);
    try {
      await MiniPosService.instance
          .get('minipos/payments/${widget.orderId}/status');
      await _load();
    } catch (error) {
      if (mounted) miniPosMessage(context, error);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return MiniPosScaffold(
      appBar: AppBar(
          title: widget.paymentCompleted ? null : const Text('Order details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? MiniPosUnavailable(message: _error!, onRetry: _load)
              : order == null
                  ? const MiniPosEmpty(
                      icon: Icons.error_outline,
                      title: 'Order unavailable',
                      message: 'This order could not be loaded.')
                  : RefreshIndicator(onRefresh: _load, child: _content(order)),
    );
  }

  Widget _content(Map<String, dynamic> order) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final metadata = order['metadata'];
    final pricing = metadata is Map && metadata['pricing'] is Map
        ? metadata['pricing'] as Map
        : null;
    final oldPricing = pricing?['version'] == 'exclusive_v1' ||
        pricing?['version'] == 'exclusive_v2';
    final oldBaseValue = pricing == null
        ? null
        : pricing['version'] == 'exclusive_v1'
            ? pricing['convenience_fee']
            : pricing['platform_fee'];
    final oldBaseFee = int.tryParse('$oldBaseValue');
    final oldExtraFee = int.tryParse('${pricing?['mdr_fee']}');
    final status = '${order['status'] ?? ''}'.toLowerCase();
    final payment = '${order['payment_status'] ?? ''}'.toLowerCase();
    final label = status == 'refunded' || payment == 'refunded'
        ? 'Refunded'
        : status == 'cancelled'
            ? 'Cancelled'
            : payment == 'paid'
                ? 'Order confirmed'
                : 'Awaiting payment';
    final statusColor = label == 'Order confirmed'
        ? AppColors.primary
        : label == 'Awaiting payment'
            ? Colors.orange.shade700
            : Colors.red.shade700;
    final date = DateTime.tryParse('${order['created_at'] ?? ''}')?.toLocal();
    final address = [
      order['address_line_1'],
      order['address_line_2'],
      order['city'],
      order['state'],
      order['pincode']
    ]
        .map((part) => '${part ?? ''}'.trim())
        .where((part) => part.isNotEmpty)
        .join(', ');
    final settlement =
        order['settlement'] is Map ? order['settlement'] as Map : null;

    return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _summaryCard(order, label, statusColor, date),
          _title('Customer'),
          _card(
              child: Column(children: [
            _detailRow('Name', '${order['end_customer_name'] ?? '—'}'),
            _detailRow('Phone', '${order['end_customer_phone'] ?? '—'}'),
            if (address.isNotEmpty) _detailRow('Address', address),
          ])),
          _title('Order items'),
          if (items.isEmpty)
            _card(child: const Text('No item details available.')),
          ...items.map(_itemCard),
          _title('Price details'),
          _card(
              child: Column(children: [
            _detailRow('SubTotal', miniPosMoney(order['subtotal'])),
            if (pricing?['version'] == 'exclusive_v3')
              _detailRow(
                  'Platform Fee', miniPosMoney(pricing?['platform_fee'])),
            if (oldPricing && oldBaseFee != null && oldExtraFee != null)
              _detailRow('Previous order fees',
                  miniPosMoney(oldBaseFee + oldExtraFee)),
            const Divider(height: 24, color: Color(0xFFE5E7EC)),
            _detailRow('Total Amount', miniPosMoney(order['total']),
                strong: true),
          ])),
          _title('Payment & settlement'),
          _card(
              child: Column(children: [
            _detailRow(
                'Payment',
                payment == 'paid'
                    ? 'Paid'
                    : payment == 'refunded'
                        ? 'Refunded'
                        : 'Pending'),
            _detailRow(
                'Shopkeeper allocation',
                _allocationLabel(
                    '${settlement?['status'] ?? order['split_status'] ?? ''}')),
            _detailRow('Bank settlement',
                _settlementLabel('${settlement?['settlement_status'] ?? ''}')),
            if (payment == 'pending') ...[
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _verifying ? null : _verify,
                    child: _verifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Check payment status'),
                  )),
            ],
          ])),
        ]);
  }

  Widget _summaryCard(
      Map<String, dynamic> order, String label, Color color, DateTime? date) {
    final confirmed = label == 'Order confirmed';
    final message = confirmed
        ? 'Payment received successfully'
        : label == 'Awaiting payment'
            ? 'Payment has not been confirmed yet'
            : label == 'Refunded'
                ? 'This order has been refunded'
                : 'This order was cancelled';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(children: [
        if (confirmed && widget.paymentCompleted)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: Opacity(
                  opacity: ((scale - 0.6) / 0.4).clamp(0.0, 1.0), child: child),
            ),
            child: _statusIcon(confirmed, color),
          )
        else
          _statusIcon(confirmed, color),
        const SizedBox(height: 12),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            const Text('Total amount',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 3),
            Text(miniPosMoney(order['total']),
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor)),
          ]),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFE5E7EC)),
        const SizedBox(height: 14),
        Text('Order ${miniPosOrderLabel(order)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        if (date != null) ...[
          const SizedBox(height: 4),
          Text(DateFormat('dd MMM yyyy, hh:mm a').format(date),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ]),
    );
  }

  Widget _statusIcon(bool confirmed, Color color) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(
            confirmed ? Icons.check_rounded : Icons.receipt_long_outlined,
            size: 34,
            color: color),
      );

  Widget _itemCard(Map<String, dynamic> item) {
    final imageUrl = '${item['thumbnail'] ?? ''}'.trim();
    final imeis = (item['imeis'] is List ? item['imeis'] as List : const [])
        .whereType<Map>()
        .map((entry) => '${entry['value'] ?? entry['masked'] ?? ''}')
        .where((value) => value.isNotEmpty)
        .join(', ');
    final variant = '${item['variant_title'] ?? ''}'.trim();
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _card(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: imageUrl.isEmpty
                    ? const ImageFallbackWidget(w: 68, h: 76)
                    : CachedNetworkImage(
                        imageUrl: Uri.encodeFull(imageUrl),
                        width: 68,
                        height: 76,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const ImageFallbackWidget(w: 68, h: 76))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${item['product_title'] ?? 'Product'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  if (variant.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(variant,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                  if (imeis.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text('IMEI: $imeis',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                  const SizedBox(height: 7),
                  Row(children: [
                    Text('Qty: ${item['quantity'] ?? 1}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    const Spacer(),
                    Text(miniPosMoney(item['line_total']),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                ])),
          ]),
        ));
  }

  Widget _title(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)));

  Widget _card({required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary)),
      child: child);

  Widget _detailRow(String label, String value, {bool strong = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                        color: strong ? Colors.black87 : Colors.black54))),
            const SizedBox(width: 12),
            Expanded(
                flex: 2,
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: strong ? 15 : 13,
                        fontWeight:
                            strong ? FontWeight.w700 : FontWeight.w600))),
          ]));

  String _allocationLabel(String value) => switch (value) {
        'completed' => 'Confirmed',
        'failed' => 'Failed',
        'processing' => 'Processing',
        'not_ready' => 'Not ready',
        _ => 'Pending',
      };

  String _settlementLabel(String value) => switch (value) {
        'completed' => 'Completed',
        'failed' => 'Failed',
        _ => 'Pending',
      };
}
