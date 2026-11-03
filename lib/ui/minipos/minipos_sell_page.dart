import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

/// MiniPOS product catalogue with read-only prices.
class MiniPosSellPage extends StatefulWidget {
  const MiniPosSellPage({super.key});
  @override
  State<MiniPosSellPage> createState() => _MiniPosSellPageState();
}

class _MiniPosSellPageState extends State<MiniPosSellPage>
    with WidgetsBindingObserver {
  int _costGeneration = 0;
  final _api = MiniPosService.instance;
  bool _loading = true;
  bool _showCostPrices = false;
  String? _error;
  List<Map<String, dynamic>> _products = [];

  void _hideCosts() {
    _costGeneration++;
    if (!mounted) return;
    setState(() {
      _showCostPrices = false;
      for (final product in _products) {
        product.remove('buy_price');
        product.remove('buy_price_min');
        product.remove('buy_price_max');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _hideCosts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _products.clear();
    super.dispose();
  }

  Future<void> _toggleCostPrices() async {
    if (_showCostPrices) {
      _hideCosts();
      return;
    }
    final generation = _costGeneration;
    final products = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (_) => const _CostPricePinDialog(),
    );
    if (mounted && products != null && generation == _costGeneration) {
      setState(() {
        _products = products;
        _showCostPrices = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    _hideCosts();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.get('minipos/products');
      if (!mounted) return;
      setState(() {
        _products = List<Map<String, dynamic>>.from(result['products'] ?? []);
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
        appBar: AppBar(
            title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('MiniPOS',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('Products',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ]),
            actions: [
              IconButton(
                tooltip:
                    _showCostPrices ? 'Hide cost prices' : 'Show cost prices',
                onPressed: _toggleCostPrices,
                icon: Icon(_showCostPrices
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
              ),
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
                            itemBuilder: (_, index) => _ProductCard(
                                product: _products[index],
                                showCostPrice: _showCostPrices))),
      );
}

String? _variantLabel(Map<String, dynamic> product) {
  final title = '${product['variant_title'] ?? ''}'.trim();
  return title.isEmpty ||
          RegExp(r'^default( variant| option| title)?\b', caseSensitive: false)
              .hasMatch(title)
      ? null
      : title;
}

/// Shown when a product has no catalogue image.
class _NoImage extends StatelessWidget {
  const _NoImage();
  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFF3F4F6),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.image_not_supported_outlined,
              size: 22, color: Colors.grey.shade500),
          const SizedBox(height: 2),
          Text('No image',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
        ]),
      );
}

/// Product summary with matching read-only cost and MOP prices.
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool showCostPrice;
  const _ProductCard({required this.product, required this.showCostPrice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buy = int.tryParse('${product['buy_price'] ?? ''}');
    final selling = int.tryParse('${product['selling_price'] ?? ''}');
    final min = int.tryParse('${product['buy_price_min'] ?? ''}');
    final max = int.tryParse('${product['buy_price_max'] ?? ''}');
    final buyText = buy == null
        ? '—'
        : min != null && max != null && min != max
            ? '${miniPosMoney(min)} – ${miniPosMoney(max)}'
            : miniPosMoney(buy);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.primary)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: Colors.white,
                child: '${product['thumbnail'] ?? ''}'.isNotEmpty
                    ? Image.network(
                        // Catalogue file names can contain spaces.
                        Uri.encodeFull('${product['thumbnail']}'),
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const Center(
                                child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))),
                        errorBuilder: (_, __, ___) => const _NoImage())
                    : const _NoImage(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['product_title'] ?? 'Product',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    // Medusa names option-less products "Default variant"; hide it.
                    if (_variantLabel(product) != null)
                      Text(_variantLabel(product)!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600)),
                  ]),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _PriceSummary(
                    label: 'Cost price',
                    value: showCostPrice ? buyText : '****')),
            const SizedBox(width: 10),
            Expanded(
                child: _PriceSummary(
              label: 'MOP price',
              value: selling == null ? '—' : miniPosMoney(selling),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _CostPricePinDialog extends StatefulWidget {
  const _CostPricePinDialog();

  @override
  State<_CostPricePinDialog> createState() => _CostPricePinDialogState();
}

class _CostPricePinDialogState extends State<_CostPricePinDialog>
    with WidgetsBindingObserver {
  bool _busy = false;
  bool _inactive = false;
  bool _hidePin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _inactive = true;
      _pin.clear();
      if (mounted) Navigator.pop(context);
    }
  }

  final _pin = TextEditingController();
  String? _error;

  Future<void> _confirm() async {
    if (_busy) return;
    if (_pin.text.length != 4) {
      setState(() => _error = 'Enter a 4-digit PIN.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await MiniPosService.instance
          .post('minipos/products', {'pin': _pin.text});
      if (mounted && !_inactive)
        Navigator.pop(
            context, List<Map<String, dynamic>>.from(result['products'] ?? []));
    } catch (e) {
      if (mounted && !_inactive) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.primary,
            ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withValues(alpha: 0.2),
          selectionHandleColor: AppColors.primary,
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Enter PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _pin,
              enabled: !_busy,
              autofocus: true,
              obscureText: _hidePin,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                hintText: 'PIN',
                errorText: _error,
                errorMaxLines: 4,
                suffixIcon: IconButton(
                  tooltip: _hidePin ? 'Show PIN' : 'Hide PIN',
                  onPressed:
                      _busy ? null : () => setState(() => _hidePin = !_hidePin),
                  icon: Icon(_hidePin
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  color: AppColors.primary,
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _confirm(),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _busy ? null : _confirm,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Confirm'),
          ),
        ],
      ));
}

class _PriceSummary extends StatelessWidget {
  final String label;
  final String value;
  const _PriceSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.grey.shade600)),
          Text(value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
