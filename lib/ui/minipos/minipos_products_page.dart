import 'package:flutter/material.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

class MiniPosProductsPage extends StatefulWidget {
  const MiniPosProductsPage({super.key});
  @override
  State<MiniPosProductsPage> createState() => _MiniPosProductsPageState();
}

class _MiniPosProductsPageState extends State<MiniPosProductsPage> {
  List<Map<String, dynamic>> _products = [];
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
      final data = await MiniPosService.instance.get('minipos/products');
      if (mounted) {
        setState(() => _products =
            List<Map<String, dynamic>>.from(data['products'] ?? []));
      }
    } catch (e) {
      debugPrint('[MiniPOS products] Failed to load products: $e');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _price(Map<String, dynamic> product) async {
    final controller = TextEditingController(
        text: product['selling_price'] == null
            ? ''
            : ((num.tryParse('${product['selling_price']}') ?? 0) / 100)
                .toStringAsFixed(2));
    final value = await showDialog<String>(
        context: context,
        builder: (_) => MiniPosTheme(
                child: AlertDialog(
                    title: Text(product['product_title'] ?? 'Selling price'),
                    content: TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            prefixText: '₹ ',
                            labelText: 'Selling price',
                            border: OutlineInputBorder())),
                    actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Save'))
                ])));
    controller.dispose();
    if (value == null) return;
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      if (mounted) miniPosMessage(context, 'Enter a valid price.');
      return;
    }
    try {
      await MiniPosService.instance.put(
          'minipos/products/${product['variant_id']}/price',
          {'selling_price': (amount * 100).round(), 'enabled': true});
      await _load();
      if (mounted) miniPosMessage(context, 'Selling price saved.');
    } catch (e) {
      if (mounted) miniPosMessage(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
      appBar: AppBar(title: const Text('MiniPOS products')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? MiniPosUnavailable(message: _error!, onRetry: _load)
              : _products.isEmpty
                  ? const MiniPosEmpty(
                      icon: Icons.phone_android,
                      title: 'No eligible products',
                      message:
                          'Products appear after delivery and IMEI import.')
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _products.length,
                          itemBuilder: (_, i) {
                            final p = _products[i];
                            return Card(
                                child: ListTile(
                                    title: Text(p['product_title'] ?? 'Phone'),
                                    subtitle: Text(
                                        '${p['variant_title'] ?? ''}\n${p['available_quantity']} available · ${p['selling_price'] == null ? 'Price not set' : miniPosMoney(p['selling_price'])}'),
                                    isThreeLine: true,
                                    trailing: OutlinedButton(
                                        onPressed: () => _price(p),
                                        child: Text(p['selling_price'] == null
                                            ? 'Set price'
                                            : 'Edit'))));
                          })));
}
