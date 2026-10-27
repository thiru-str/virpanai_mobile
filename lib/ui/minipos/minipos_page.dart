import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_cart_page.dart';
import 'package:waioz/ui/minipos/minipos_orders_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

class MiniPosPage extends StatefulWidget {
  const MiniPosPage({super.key});
  @override
  State<MiniPosPage> createState() => _MiniPosPageState();
}

class _MiniPosPageState extends State<MiniPosPage> {
  final _api = MiniPosService.instance;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _products = [];
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait(
          [_api.get('minipos/products'), _api.get('minipos/cart')]);
      if (!mounted) return;
      setState(() {
        _products =
            List<Map<String, dynamic>>.from(results[0]['products'] ?? []);
        _cartCount =
            int.tryParse('${results[1]['cart']?['item_count'] ?? 0}') ?? 0;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add(Map<String, dynamic> product) async {
    try {
      final data = await _api.post('minipos/cart/items',
          {'variant_id': product['variant_id'], 'quantity': 1});
      if (!mounted) return;
      setState(() => _cartCount =
          int.tryParse('${data['cart']?['item_count'] ?? 0}') ?? 0);
      miniPosMessage(
          context, '${product['product_title']} added to MiniPOS cart');
    } catch (e) {
      if (mounted) miniPosMessage(context, e);
    }
  }

  Future<void> _scan() async {
    final code = await Navigator.push<String>(
        context, MaterialPageRoute(builder: (_) => const _MiniPosScanner()));
    if (code == null || !mounted) return;
    final matches = _products.where((product) {
      final codes = List<String>.from(product['item_codes'] ?? []);
      return product['variant_id'] == code || codes.contains(code);
    }).toList();
    if (matches.isEmpty)
      miniPosMessage(
          context, 'This barcode is not in your available MiniPOS inventory.');
    else if (matches.first['enabled'] != true)
      miniPosMessage(
          context, 'Configure a selling price for this product first.');
    else
      _add(matches.first);
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
            title: const Text('MiniPOS'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  tooltip: 'Scan product',
                  onPressed: _scan,
                  icon: const Icon(Icons.qr_code_scanner)),
              IconButton(
                  tooltip: 'Orders',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MiniPosOrdersPage())),
                  icon: const Icon(Icons.receipt_long_outlined)),
              Badge(
                  isLabelVisible: _cartCount > 0,
                  label: Text('$_cartCount'),
                  child: IconButton(
                      tooltip: 'MiniPOS cart',
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MiniPosCartPage()));
                        _load();
                      },
                      icon: const Icon(Icons.shopping_cart_outlined))),
              const SizedBox(width: 8),
            ]),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? MiniPosUnavailable(message: _error!, onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _products.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 100),
                            MiniPosEmpty(
                                icon: Icons.phone_android,
                                title: 'No devices available',
                                message:
                                    'Delivered eligible phones appear here after the admin imports their IMEIs.')
                          ])
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _products.length,
                            itemBuilder: (_, index) {
                              final product = _products[index];
                              final ready = product['enabled'] == true &&
                                  product['selling_price'] != null;
                              return Card(
                                  child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: product['thumbnail'] != null
                                          ? Image.network(product['thumbnail'],
                                              width: 54,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.phone_android,
                                                      size: 42))
                                          : const Icon(Icons.phone_android,
                                              size: 42),
                                      title: Text(product['product_title'] ?? 'Phone',
                                          maxLines: 2),
                                      subtitle: Text(
                                          '${product['variant_title'] ?? ''}\n${product['available_quantity']} device(s) available${ready ? ' · ${miniPosMoney(product['selling_price'])}' : ' · Price not configured'}'),
                                      isThreeLine: true,
                                      trailing: FilledButton(
                                          onPressed:
                                              ready ? () => _add(product) : null,
                                          child: const Text('Add'))));
                            })),
      );
}

class _MiniPosScanner extends StatefulWidget {
  const _MiniPosScanner();
  @override
  State<_MiniPosScanner> createState() => _MiniPosScannerState();
}

class _MiniPosScannerState extends State<_MiniPosScanner> {
  bool _done = false;
  @override
  Widget build(BuildContext context) => MiniPosScaffold(
      appBar: AppBar(title: const Text('Scan product')),
      body: Stack(children: [
        MobileScanner(onDetect: (capture) {
          if (_done || capture.barcodes.isEmpty) return;
          final value = capture.barcodes.first.rawValue;
          if (value != null) {
            _done = true;
            Navigator.pop(context, value);
          }
        }),
        Center(
            child: Container(
                width: 240,
                height: 160,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
                    borderRadius: BorderRadius.circular(16))))
      ]));
}
