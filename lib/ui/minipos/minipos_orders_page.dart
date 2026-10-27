import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_order_detail_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

class MiniPosOrdersPage extends StatefulWidget {
  const MiniPosOrdersPage({super.key});
  @override
  State<MiniPosOrdersPage> createState() => _MiniPosOrdersPageState();
}

class _MiniPosOrdersPageState extends State<MiniPosOrdersPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _orders = [];
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
      final data = await MiniPosService.instance
          .get('minipos/orders', query: {'limit': 100});
      if (mounted) {
        setState(() =>
            _orders = List<Map<String, dynamic>>.from(data['orders'] ?? []));
      }
    } catch (e) {
      debugPrint('[MiniPOS orders] Failed to load orders: $e');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
      appBar: AppBar(title: const Text('MiniPOS orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? MiniPosUnavailable(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _orders.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 120),
                          MiniPosEmpty(
                              icon: Icons.receipt_long_outlined,
                              title: 'No MiniPOS orders',
                              message:
                                  'Completed and pending customer sales appear here.')
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _orders.length,
                          itemBuilder: (_, i) {
                            final order = _orders[i];
                            final date =
                                DateTime.tryParse('${order['created_at']}');
                            return Card(
                                child: ListTile(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                MiniPosOrderDetailPage(
                                                    orderId:
                                                        '${order['id']}'))),
                                    title: Text(
                                        '${order['order_number']} · ${miniPosMoney(order['total'])}'),
                                    subtitle: Text(
                                        '${order['end_customer_name']} · ${order['payment_status']}\n${date == null ? '' : DateFormat('dd MMM yyyy, h:mm a').format(date.toLocal())}'),
                                    isThreeLine: true,
                                    trailing: const Icon(Icons.chevron_right)));
                          })));
}
