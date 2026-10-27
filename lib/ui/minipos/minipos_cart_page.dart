import 'package:flutter/material.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_checkout_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

class MiniPosCartPage extends StatefulWidget {
  const MiniPosCartPage({super.key});
  @override
  State<MiniPosCartPage> createState() => _MiniPosCartPageState();
}

class _MiniPosCartPageState extends State<MiniPosCartPage> {
  final _api = MiniPosService.instance;
  Map<String, dynamic>? _cart;
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
      final data = await _api.get('minipos/cart');
      if (mounted) {
        setState(() => _cart = Map<String, dynamic>.from(data['cart']));
      }
    } catch (e) {
      debugPrint('[MiniPOS cart] Failed to load cart: $e');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _quantity(Map<String, dynamic> item, int quantity) async {
    try {
      final data = quantity < 1
          ? await _api.delete('minipos/cart/items/${item['id']}')
          : await _api.patch(
              'minipos/cart/items/${item['id']}', {'quantity': quantity});
      if (mounted) {
        setState(() => _cart = Map<String, dynamic>.from(data['cart']));
      }
    } catch (e) {
      if (mounted) miniPosMessage(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(_cart?['items'] ?? []);
    return MiniPosScaffold(
      appBar: AppBar(title: const Text('MiniPOS cart')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? MiniPosUnavailable(message: _error!, onRetry: _load)
              : items.isEmpty
                  ? const MiniPosEmpty(
                      icon: Icons.remove_shopping_cart_outlined,
                      title: 'Cart is empty',
                      message: 'Add a configured phone from MiniPOS.',
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: items.length,
                            itemBuilder: (_, index) {
                              final item = items[index];
                              final qty =
                                  int.tryParse('${item['quantity']}') ?? 1;
                              return Card(
                                child: ListTile(
                                  title: Text(item['product_title'] ?? 'Phone'),
                                  subtitle: Text(
                                    '${item['variant_title'] ?? ''}\n${miniPosMoney(item['unit_price'])} each',
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _quantity(item, qty - 1),
                                        icon: Icon(qty == 1
                                            ? Icons.delete_outline
                                            : Icons.remove_circle_outline),
                                      ),
                                      Text('$qty'),
                                      IconButton(
                                        onPressed: () =>
                                            _quantity(item, qty + 1),
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12, blurRadius: 10),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Total',
                                          style:
                                              TextStyle(color: Colors.black54)),
                                      Text(miniPosMoney(_cart?['total']),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MiniPosCheckoutPage(
                                          total: int.tryParse(
                                                  '${_cart?['total']}') ??
                                              0,
                                        ),
                                      ),
                                    );
                                    _load();
                                  },
                                  child: const Text('Checkout'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
