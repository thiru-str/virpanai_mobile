import 'package:flutter/material.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

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
      if (mounted) {
        setState(() => _order = Map<String, dynamic>.from(data['order']));
      }
    } catch (e) {
      debugPrint('[MiniPOS order] Failed to load order: $e');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    try {
      await MiniPosService.instance
          .get('minipos/payments/${widget.orderId}/status');
      await _load();
    } catch (e) {
      if (mounted) miniPosMessage(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(_order?['items'] ?? []);
    return MiniPosScaffold(
        appBar: AppBar(title: const Text('MiniPOS order')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? MiniPosUnavailable(message: _error!, onRetry: _load)
                : _order == null
                    ? const MiniPosEmpty(
                        icon: Icons.error_outline,
                        title: 'Order unavailable',
                        message: 'This order could not be loaded.')
                    : ListView(padding: const EdgeInsets.all(16), children: [
                        if (widget.paymentCompleted)
                          Card(
                              color: Colors.green.shade50,
                              child: const ListTile(
                                  leading: Icon(Icons.check_circle,
                                      color: Colors.green),
                                  title: Text('Payment verified'),
                                  subtitle: Text(
                                      'The sold IMEI is now locked to this order.'))),
                        Text('${_order!['order_number']}',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text(
                            '${_order!['end_customer_name']} · ${_order!['end_customer_phone']}'),
                        Text(
                            '${_order!['address_line_1']}${(_order!['address_line_2'] ?? '').toString().isEmpty ? '' : ', ${_order!['address_line_2']}'}\n${_order!['city']}, ${_order!['state']} - ${_order!['pincode']}',
                            style: const TextStyle(color: Colors.black54)),
                        const Divider(height: 32),
                        ...items.map((item) => Card(
                            child: ListTile(
                                title: Text(item['product_title'] ?? 'Phone'),
                                subtitle: Text(
                                    '${item['variant_title'] ?? ''}\nIMEI: ${(List<Map<String, dynamic>>.from(item['imeis'] ?? [])).map((e) => e['masked']).join(', ')}'),
                                isThreeLine: true,
                                trailing: Text(
                                    '${item['quantity']} × ${miniPosMoney(item['unit_price'])}')))),
                        const Divider(height: 32),
                        _row('Total', miniPosMoney(_order!['total'])),
                        _row('Payment', '${_order!['payment_status']}'),
                        _row('Order', '${_order!['status']}'),
                        _row('Settlement',
                            '${_order!['settlement']?['settlement_status'] ?? _order!['split_status']}'),
                        if (_order!['payment_status'] == 'pending')
                          Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: OutlinedButton(
                                  onPressed: _verify,
                                  child: const Text('Check payment status')))
                      ]));
  }

  Widget _row(String name, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
      ]));
}
