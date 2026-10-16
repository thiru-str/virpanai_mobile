// Pure cart transforms for the optimistic cart UI. They only move line
// quantities: the backend owns pricing, promotions, taxes and shipping, so
// every total on an optimistic cart is the last server value and must be shown
// as "updating" until the server confirms.

typedef CartJson = Map<String, dynamic>;
typedef CartTransform = CartJson Function(CartJson cart);

const String optimisticLinePrefix = 'optimistic_';
const String optimisticFlag = '__optimistic';

/// A line the shopper added that the server has not confirmed yet.
class ProvisionalLine {
  final String variantId;
  final int quantity;
  final String? productId;
  final String? productTitle;
  final String? variantTitle;
  final String? thumbnail;
  final num? unitPrice;

  const ProvisionalLine({
    required this.variantId,
    required this.quantity,
    this.productId,
    this.productTitle,
    this.variantTitle,
    this.thumbnail,
    this.unitPrice,
  });
}

List<Map<String, dynamic>> cartLines(CartJson? cart) {
  final items = cart?['items'];
  if (items is! List) return const [];
  return items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
}

String? _lineType(Map<String, dynamic> line) {
  final metadata = line['metadata'];
  return metadata is Map ? metadata['type']?.toString() : null;
}

bool isPlatformFeeLine(Map<String, dynamic> line) => _lineType(line) == 'platform_fee';

/// Platform fee and loyalty discount rows are added by the backend; the
/// shopper cannot change them and they are not products.
bool isVirtualLine(Map<String, dynamic> line) {
  final type = _lineType(line);
  return type == 'platform_fee' || type == 'loyalty_discount';
}

int _quantityOf(Map<String, dynamic> line) {
  final quantity = line['quantity'];
  return quantity is num ? quantity.toInt() : 0;
}

String provisionalLineId(String variantId) => '$optimisticLinePrefix$variantId';

bool isProvisionalLineId(String lineId) => lineId.startsWith(optimisticLinePrefix);

CartJson _withLines(CartJson cart, List<Map<String, dynamic>> lines) =>
    {...cart, 'items': lines};

Map<String, dynamic>? findLineByVariant(CartJson? cart, String? variantId) {
  if (variantId == null || variantId.isEmpty) return null;
  for (final line in cartLines(cart)) {
    if (!isVirtualLine(line) && line['variant_id'] == variantId) return line;
  }
  return null;
}

/// A provisional line keeps its `optimistic_<variant>` id until the server cart
/// arrives; after that, the same id has to resolve to the real line.
Map<String, dynamic>? resolveLine(CartJson? cart, String lineId) {
  final lines = cartLines(cart);
  for (final line in lines) {
    if (line['id'] == lineId) return line;
  }
  if (!isProvisionalLineId(lineId)) return null;
  return findLineByVariant(cart, lineId.substring(optimisticLinePrefix.length));
}

Map<String, dynamic> _buildProvisionalLine(ProvisionalLine line) => {
      'id': provisionalLineId(line.variantId),
      'variant_id': line.variantId,
      'product_id': line.productId,
      'product_title': line.productTitle,
      'variant_title': line.variantTitle,
      'thumbnail': line.thumbnail,
      'quantity': line.quantity,
      'unit_price': line.unitPrice,
      'metadata': <String, dynamic>{},
      'adjustments': <dynamic>[],
      'in_stock': true,
      'error': '',
    };

/// Adds `line.quantity` to the matching line, or appends a provisional line.
CartJson addItem(CartJson cart, ProvisionalLine line) {
  final lines = cartLines(cart);
  final index = lines.indexWhere(
      (item) => !isVirtualLine(item) && item['variant_id'] == line.variantId);
  if (index < 0) return _withLines(cart, [...lines, _buildProvisionalLine(line)]);

  final existing = lines[index];
  lines[index] = {...existing, 'quantity': _quantityOf(existing) + line.quantity};
  return _withLines(cart, lines);
}

CartJson setQuantity(CartJson cart, String lineId, int quantity) {
  if (quantity <= 0) return removeLine(cart, lineId);
  final target = resolveLine(cart, lineId);
  if (target == null || isVirtualLine(target)) return cart;
  return _withLines(
    cart,
    cartLines(cart)
        .map((line) => line['id'] == target['id'] ? {...line, 'quantity': quantity} : line)
        .toList(),
  );
}

CartJson removeLine(CartJson cart, String lineId) {
  final target = resolveLine(cart, lineId);
  if (target == null || isVirtualLine(target)) return cart;
  return _withLines(
    cart,
    cartLines(cart).where((line) => line['id'] != target['id']).toList(),
  );
}

CartJson markOptimistic(CartJson cart) => {...cart, optimisticFlag: true};

bool isOptimisticCart(CartJson? cart) => cart?[optimisticFlag] == true;

/// The header/bottom-nav badge: total quantity of product lines.
int countCartItems(CartJson? cart) => cartLines(cart)
    .where((line) => !isVirtualLine(line))
    .fold<int>(0, (total, line) => total + _quantityOf(line));

/// Variant id -> quantity for product lines, for the home-page steppers.
Map<String, int> variantQuantities(CartJson? cart) {
  final quantities = <String, int>{};
  for (final line in cartLines(cart)) {
    final variantId = line['variant_id'];
    if (isVirtualLine(line) || variantId is! String) continue;
    quantities[variantId] = _quantityOf(line);
  }
  return quantities;
}

/// Lines whose visible quantity the server has not confirmed yet.
Set<String> unconfirmedLineIds(CartJson? serverCart, CartJson? viewCart) {
  final pending = <String>{};
  for (final line in cartLines(viewCart)) {
    final id = line['id'];
    if (id is! String) continue;
    final confirmed = resolveLine(serverCart, id);
    if (confirmed == null || _quantityOf(confirmed) != _quantityOf(line)) {
      pending.add(id);
    }
  }
  return pending;
}
