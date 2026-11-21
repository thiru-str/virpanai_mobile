import 'package:waioz/ui/minipos/minipos_temp_cart.dart';
import 'package:waioz/ui/minipos/minipos_scan_flow.dart';
import 'package:flutter/material.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_cart_widgets.dart';
import 'package:waioz/ui/minipos/minipos_checkout_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';

class MiniPosCartPage extends StatefulWidget {
  const MiniPosCartPage({super.key});
  @override
  State<MiniPosCartPage> createState() => _MiniPosCartPageState();
}

class _MiniPosCartPageState extends State<MiniPosCartPage> {
  final _api = MiniPosService.instance;
  final _tempCart = MiniPosTempCart.instance;
  Map<String, dynamic>? _cart;
  bool _loading = true;
  String? _error;
  // Items whose quantity change or removal is in progress.
  final Set<String> _updating = {};
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _scan() async {
    if (_scanning || _tempCart.itemCount > 0) return;
    setState(() => _scanning = true);
    try {
      final cart = await scanMiniPosPhone(context);
      if (mounted && cart != null) setState(() => _cart = cart);
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _tempCart.bindToCurrentAccount();
      final status = await _api.get('minipos/status');
      _tempCart.setPlatformFee(
          int.tryParse('${status['platform_fee_paise'] ?? 0}') ?? 0);
      if (mounted) {
        setState(() => _cart = _tempCart.snapshot());
      }
    } catch (e) {
      debugPrint('[MiniPOS cart] Failed to load cart: $e');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _quantity(Map<String, dynamic> item, int quantity) async {
    final id = '${item['id']}';
    setState(() => _updating.add(id));
    try {
      if (quantity < 1) _tempCart.remove(id);
      if (mounted) {
        setState(() => _cart = _tempCart.snapshot());
      }
    } catch (e) {
      if (mounted) miniPosMessage(context, e);
    } finally {
      if (mounted) setState(() => _updating.remove(id));
    }
  }

  /// Medusa names option-less products "Default variant"; the card hides an empty size.
  String _variant(Map<String, dynamic> item) {
    final title = '${item['variant_title'] ?? ''}'.trim();
    return RegExp(r'^default( variant| option| title)?\b', caseSensitive: false)
            .hasMatch(title)
        ? ''
        : title;
  }

  Future<void> _checkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MiniPosCheckoutPage(
          total: int.tryParse('${_cart?['total']}') ?? 0,
          items: _tempCart.checkoutItems(),
          checkoutToken: _tempCart.checkoutToken,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(_cart?['items'] ?? []);
    return MiniPosScaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('EMI POS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Cart', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Scan product IMEI',
            onPressed: _scanning ||
                    _loading ||
                    _updating.isNotEmpty ||
                    items.isNotEmpty
                ? null
                : _scan,
            icon: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? MiniPosUnavailable(message: _error!, onRetry: _load)
              : items.isEmpty
                  ? const MiniPosEmpty(
                      icon: Icons.remove_shopping_cart_outlined,
                      title: 'Cart is empty',
                      message:
                          'Scan a product or enter its IMEI manually to add it.',
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                              itemCount: items.length,
                              itemBuilder: (_, index) {
                                final item = items[index];
                                final qty =
                                    int.tryParse('${item['quantity']}') ?? 1;
                                return MiniPosCartItemCard(
                                  // Catalogue file names can contain spaces.
                                  imageUrl: Uri.encodeFull(
                                      '${item['thumbnail'] ?? ''}'),
                                  productName:
                                      '${item['product_title'] ?? 'Product'}',
                                  size: _variant(item),
                                  color: '',
                                  price: miniPosMoney(item['line_total']),
                                  quantity: qty,
                                  isUpdating:
                                      _updating.contains('${item['id']}'),
                                  onRemoveAll: () => _quantity(item, 0),
                                );
                              },
                            ),
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: MiniPosCartTotalBar(
                            loading: _updating.isNotEmpty,
                            onCheckout: _checkout,
                          ),
                        ),
                      ],
                    ),
    );
  }
}
