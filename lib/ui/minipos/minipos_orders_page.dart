import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_order_detail_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

class MiniPosOrdersPage extends StatefulWidget {
  const MiniPosOrdersPage({super.key});
  @override
  State<MiniPosOrdersPage> createState() => _MiniPosOrdersPageState();
}

class _MiniPosOrdersPageState extends State<MiniPosOrdersPage> {
  static const _pageSize = 20;
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.extentAfter < 240 &&
          _hasMore &&
          !_loadingMore &&
          !_loading) _loadMore();
    });
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await MiniPosService.instance
          .get('minipos/orders', query: {'limit': _pageSize, 'offset': 0});
      final fetched = List<Map<String, dynamic>>.from(data['orders'] ?? []);
      if (!mounted) return;
      setState(() {
        _orders
          ..clear()
          ..addAll(fetched);
        final count = (data['count'] as num?)?.toInt();
        _hasMore = count == null
            ? fetched.length == _pageSize
            : _orders.length < count;
      });
    } catch (error) {
      debugPrint('[MiniPOS orders] Failed to load orders: $error');
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final data = await MiniPosService.instance.get('minipos/orders',
          query: {'limit': _pageSize, 'offset': _orders.length});
      final fetched = List<Map<String, dynamic>>.from(data['orders'] ?? []);
      if (!mounted) return;
      setState(() {
        _orders.addAll(fetched);
        final count = (data['count'] as num?)?.toInt();
        _hasMore = count == null
            ? fetched.length == _pageSize
            : _orders.length < count;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _hasMore = false);
        miniPosMessage(context, error);
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
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
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                                SizedBox(height: 100),
                                MiniPosEmpty(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'No MiniPOS orders yet',
                                    message:
                                        'Paid customer sales will appear here.'),
                              ])
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _orders.length + (_loadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _orders.length)
                                return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              final order = _orders[index];
                              return _MiniPosOrderCard(
                                  order: order,
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                MiniPosOrderDetailPage(
                                                    orderId:
                                                        '${order['id']}')));
                                    if (mounted) _load();
                                  });
                            },
                          ),
                  ),
      );
}

class _MiniPosOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  const _MiniPosOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse('${order['created_at'] ?? ''}')?.toLocal();
    final status = '${order['status'] ?? ''}'.toLowerCase();
    final payment = '${order['payment_status'] ?? ''}'.toLowerCase();
    final label = status == 'refunded' || payment == 'refunded'
        ? 'Refunded'
        : status == 'cancelled'
            ? 'Cancelled'
            : payment == 'paid'
                ? 'Confirmed'
                : 'Payment pending';
    final color = label == 'Confirmed'
        ? AppColors.primary
        : label == 'Payment pending'
            ? Colors.orange.shade700
            : Colors.red.shade700;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.09),
                          shape: BoxShape.circle),
                      child: Icon(Icons.receipt_long_outlined,
                          color: AppColors.primary, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Order ${miniPosOrderLabel(order)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        const SizedBox(height: 7),
                        Text('${order['end_customer_name'] ?? 'Customer'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 7),
                        Row(children: [
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Text(label,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600))),
                          const Spacer(),
                          Text(miniPosMoney(order['total']),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                        ]),
                        if (date != null) ...[
                          const SizedBox(height: 7),
                          Text(DateFormat('dd MMM yyyy, hh:mm a').format(date),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      ])),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Colors.black45),
                ])),
          )),
    );
  }
}
