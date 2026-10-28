import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/view_cart_model.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/cart_optimistic.dart';
import 'package:waioz/utility/cart_queue.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

/// Fired on every cart change, optimistic or confirmed.
class CartStateEvent {
  final CartResponse cart;

  /// Mutations are still queued or in flight, so totals are stale.
  final bool syncing;

  /// Lines whose visible quantity the server has not confirmed yet.
  final Set<String> pendingLineIds;

  const CartStateEvent(this.cart, this.syncing, this.pendingLineIds);
}

/// The one cart every screen shows. Mutations go through a serial queue and
/// update the cart, badge and steppers on tap; the server's answer (or a
/// rollback with its message) follows. Prices and totals always come from the
/// server.
class CartStore {
  CartStore._() {
    _queue = CartQueue(CartQueueDeps(
      readCart: () => _confirmed,
      publish: _publish,
      reconcile: _readServerCart,
      reportError: AppUtils.showToast,
      reportNotice: AppUtils.showToast,
    ));
  }

  static final CartStore instance = CartStore._();

  late final CartQueue _queue;
  CartJson _confirmed = {};
  CartJson _view = {};
  CartResponse _cart = CartResponse();
  bool _syncing = false;
  bool _hasPublished = false;
  Set<String> _pendingLineIds = const {};
  // Variants shown in the cart at some point; a variant that left the cart is
  // published with quantity 0 so steppers do not fall back to stale values.
  final Set<String> _knownVariantIds = {};
  BuildContext? _context;

  CartResponse get cart => _cart;
  bool get isSyncing => _syncing;
  Set<String> get pendingLineIds => _pendingLineIds;

  Map<String, dynamic>? lineForVariant(String variantId) =>
      findLineByVariant(_view, variantId);

  /// The variant's quantity in the visible cart, or null before any cart was
  /// read (callers then fall back to the quantity their own payload carried).
  int? quantityForVariant(String variantId) {
    if (!_hasPublished || variantId.isEmpty) return null;
    return (lineForVariant(variantId)?['quantity'] as num?)?.toInt() ?? 0;
  }

  /// Reads the cart from the server. While mutations are pending the queue
  /// re-reads once it is idle, so this returns the current view instead.
  Future<CartResponse> refresh(BuildContext? context) async {
    _context = context;
    if (_queue.isSyncing) return _cart;
    final fresh = await _readServerCart();
    if (fresh != null) _queue.acceptServerCart(fresh);
    return _cart;
  }

  /// The order was placed: the badge and every cart view empty at once.
  void clear() {
    _queue.reset({'items': <dynamic>[]});
  }

  Future<CartMutationResult?> addVariant(
    BuildContext? context,
    ProvisionalLine line,
  ) async {
    // No cart id yet (a guest, or the home payload not read): a request would
    // go to custom-carts//line-items and come back as an HTML error page.
    final cartId = await SharedPreferencesUtil().getString('cart_id');
    if (cartId == null || cartId.isEmpty) {
      AppUtils.showToast(await AppUtils.isLoggedIn()
          ? 'Your cart is still loading. Please try again.'
          : 'Please log in to add items to your cart.');
      return null;
    }
    await _prepare(context);
    return _queue.enqueue(
      (_) => _send(() => ApiService().addCartLine(_liveContext, line.variantId, line.quantity)),
      optimistic: (cart) => addItem(cart, line),
      rollbackMessage: 'Could not add to cart',
    );
  }

  Future<CartMutationResult?> setLineQuantity(
    BuildContext? context,
    String lineId,
    int quantity,
  ) async {
    await _prepare(context);
    return _queue.setLineQuantity(
      lineId,
      quantity,
      send: (id, qty) => _send(() => ApiService().updateCartLine(_liveContext, id, qty)),
      remove: (id) => _send(() => ApiService().deleteCartLine(_liveContext, id)),
    );
  }

  Future<CartMutationResult?> removeLine(BuildContext? context, String lineId) async {
    await _prepare(context);
    return _queue.removeCartLine(
      lineId,
      send: (id) => _send(() => ApiService().deleteCartLine(_liveContext, id)),
    );
  }

  /// A +/- stepper on a product card: changes the variant's line, or adds it.
  Future<CartMutationResult?> changeVariantQuantity(
    BuildContext? context,
    String variantId,
    int delta,
  ) async {
    final line = lineForVariant(variantId);
    final lineId = line?['id'];
    if (lineId is String) {
      final current = (line?['quantity'] as num?)?.toInt() ?? 0;
      return setLineQuantity(context, lineId, current + delta);
    }
    if (delta <= 0) return null;
    return addVariant(context, ProvisionalLine(variantId: variantId, quantity: delta));
  }

  BuildContext? get _liveContext {
    final context = _context;
    return context != null && context.mounted ? context : null;
  }

  // A cart id saved after sign-in or an order belongs to another cart; the
  // cached one must not be the base for optimistic changes.
  Future<void> _prepare(BuildContext? context) async {
    _context = context;
    if (_queue.isSyncing) return;
    final cartId = await SharedPreferencesUtil().getString('cart_id');
    if (cartId != null && cartId.isNotEmpty && _confirmed['id'] != cartId) {
      _confirmed = {'id': cartId, 'items': <dynamic>[]};
    }
  }

  Future<CartMutationResult> _send(Future<Map<String, dynamic>> Function() request) async {
    try {
      final body = await request();
      final cart = body['cart'];
      final notice = body['notice'];
      return CartMutationResult(
        cart: cart is Map ? Map<String, dynamic>.from(cart) : null,
        notice: notice is String ? notice : null,
      );
    } on ApiException catch (error) {
      throw CartMutationException(error.message, code: error.code);
    }
  }

  Future<CartJson?> _readServerCart() async {
    try {
      final body = await ApiService().getCartJson(_liveContext);
      final cart = body['cart'];
      return cart is Map ? Map<String, dynamic>.from(cart) : null;
    } catch (e) {
      AppLogger.print('Cart read failed:', '$e');
      return null;
    }
  }

  void _publish(CartJson view, CartJson serverCart, bool syncing) {
    final CartResponse parsed;
    try {
      parsed = CartResponse.fromJson({'cart': view});
    } catch (e) {
      AppLogger.print('Cart parse failed:', '$e');
      return;
    }
    _hasPublished = true;
    _confirmed = serverCart;
    _view = view;
    _cart = parsed;
    _syncing = syncing;
    _pendingLineIds = syncing ? unconfirmedLineIds(serverCart, view) : const {};

    eventBus.fire(CartStateEvent(parsed, syncing, _pendingLineIds));
    eventBus.fire(_badgeEvent(view));
  }

  ViewCartModel _badgeEvent(CartJson view) {
    final quantities = variantQuantities(view);
    _knownVariantIds.addAll(quantities.keys);
    final qtyMap = {
      for (final variantId in _knownVariantIds) variantId: quantities[variantId] ?? 0,
    };
    final images = cartLines(view)
        .where((line) => !isVirtualLine(line))
        .map((line) => line['thumbnail']?.toString() ?? '')
        .toList();
    return ViewCartModel(countCartItems(view), images, qtyMap);
  }
}
