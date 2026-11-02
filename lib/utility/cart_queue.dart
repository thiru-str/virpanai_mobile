import 'dart:async';

import 'cart_optimistic.dart';

// One FIFO for every cart mutation. The backend's cart workflows use a fixed
// per-cart transaction id, so two mutations on the same cart must never be in
// flight together; the shopper still sees each change instantly through its
// optimistic transform.

const Duration quantityCoalesceWindow = Duration(milliseconds: 350);
const String defaultCartErrorMessage = 'Could not update your cart';

class CartMutationResult {
  /// The settled cart the server answered with, when it sent one.
  final CartJson? cart;

  /// Shown to the shopper on success, e.g. a quantity clamped to stock.
  final String? notice;

  const CartMutationResult({this.cart, this.notice});
}

/// A refused mutation; [message] is shown to the shopper.
class CartMutationException implements Exception {
  final String message;
  final String? code;

  const CartMutationException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Receives the latest server-confirmed cart, e.g. to resolve a line id.
typedef CartTask = Future<CartMutationResult> Function(CartJson serverCart);

class CartQueueDeps {
  /// Best known cart when an idle queue receives its first mutation.
  final CartJson Function() readCart;

  /// Called with the cart to show and whether mutations are still syncing.
  final void Function(CartJson view, CartJson serverCart, bool syncing) publish;

  /// Fresh server cart after a failure, or null when it cannot be read.
  final Future<CartJson?> Function() reconcile;
  final void Function(String message) reportError;
  final void Function(String notice) reportNotice;
  final Future<void> Function(Duration duration) delay;
  final DateTime Function() now;

  CartQueueDeps({
    required this.readCart,
    required this.publish,
    required this.reconcile,
    required this.reportError,
    required this.reportNotice,
    Future<void> Function(Duration duration)? delay,
    DateTime Function()? now,
  })  : delay = delay ?? Future<void>.delayed,
        now = now ?? DateTime.now;
}

class _QueuedMutation {
  CartTask task;
  CartTransform? optimistic;
  String rollbackMessage;
  final String? coalesceKey;
  DateTime readyAt;
  bool started = false;
  Completer<CartMutationResult?> completer;

  _QueuedMutation({
    required this.task,
    required this.optimistic,
    required this.rollbackMessage,
    required this.coalesceKey,
    required this.readyAt,
    required this.completer,
  });
}

class _Outcome {
  final bool ok;
  final CartMutationResult? result;
  final String? message;

  const _Outcome.success(this.result)
      : ok = true,
        message = null;
  const _Outcome.failure(this.message)
      : ok = false,
        result = null;
}

class CartQueue {
  final CartQueueDeps _deps;
  final List<_QueuedMutation> _queue = [];
  CartJson _serverCart = {};
  bool _draining = false;
  bool _needsReconcile = false;

  CartQueue(this._deps);

  bool get isSyncing => _queue.isNotEmpty;

  CartJson get serverCart => _serverCart;

  /// A cart read outside the queue (e.g. a GET). It only replaces the base
  /// when nothing is pending; otherwise the queue re-reads once it is idle.
  void acceptServerCart(CartJson cart) {
    if (_queue.isNotEmpty) {
      _needsReconcile = true;
      return;
    }
    _serverCart = cart;
    _publishView();
  }

  /// Drops every pending mutation's base, e.g. after an order was placed.
  void reset(CartJson cart) {
    _serverCart = cart;
    if (_queue.isEmpty) _publishView();
  }

  void _publishView() {
    if (_queue.isEmpty) {
      _deps.publish(_serverCart, _serverCart, false);
      return;
    }
    var view = _serverCart;
    for (final mutation in _queue) {
      view = mutation.optimistic?.call(view) ?? view;
    }
    _deps.publish(markOptimistic(view), _serverCart, true);
  }

  Future<_Outcome> _execute(_QueuedMutation mutation) async {
    try {
      return _Outcome.success(await mutation.task(_serverCart));
    } on CartMutationException catch (error) {
      return _Outcome.failure(
          error.message.isNotEmpty ? error.message : mutation.rollbackMessage);
    } catch (_) {
      return _Outcome.failure(mutation.rollbackMessage);
    }
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    while (_queue.isNotEmpty) {
      final mutation = _queue.first;
      // A coalescing quantity change waits until the taps settle; each new tap
      // pushes readyAt out again, and a removal may drop it while it waits.
      final wait = mutation.readyAt.difference(_deps.now());
      if (wait > Duration.zero) {
        await _deps.delay(wait);
        continue;
      }
      mutation.started = true;
      final outcome = await _execute(mutation);
      _queue.removeAt(0);

      final confirmedCart = outcome.result?.cart;
      if (outcome.ok && confirmedCart != null) {
        _serverCart = confirmedCart;
      } else if (outcome.ok) {
        // Succeeded without returning its cart: keep the change visible and
        // read the real cart once the queue is idle.
        _serverCart = mutation.optimistic?.call(_serverCart) ?? _serverCart;
        _needsReconcile = true;
      } else {
        _needsReconcile = true;
        final message = outcome.message;
        if (message != null && message.isNotEmpty) _deps.reportError(message);
      }

      final notice = outcome.result?.notice;
      if (notice != null && notice.isNotEmpty) _deps.reportNotice(notice);

      _publishView();
      mutation.completer.complete(outcome.ok ? outcome.result : null);

      if (_queue.isEmpty && _needsReconcile) {
        _needsReconcile = false;
        CartJson? fresh;
        try {
          fresh = await _deps.reconcile();
        } catch (_) {
          fresh = null;
        }
        if (fresh != null && _queue.isEmpty) {
          _serverCart = fresh;
          _publishView();
        } else if (fresh != null) {
          _needsReconcile = true;
        }
      }
    }
    _draining = false;
  }

  Future<CartMutationResult?> _push(
    CartTask task, {
    CartTransform? optimistic,
    String? rollbackMessage,
    String? coalesceKey,
    DateTime? readyAt,
  }) {
    if (_queue.isEmpty && !_draining) _serverCart = _deps.readCart();
    final completer = Completer<CartMutationResult?>();
    _queue.add(_QueuedMutation(
      task: task,
      optimistic: optimistic,
      rollbackMessage: rollbackMessage ?? defaultCartErrorMessage,
      coalesceKey: coalesceKey,
      readyAt: readyAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      completer: completer,
    ));
    _publishView();
    unawaited(_drain());
    return completer.future;
  }

  _QueuedMutation? _findWaiting(String coalesceKey) {
    for (final mutation in _queue) {
      if (!mutation.started && mutation.coalesceKey == coalesceKey) return mutation;
    }
    return null;
  }

  /// Resolves with the mutation's result, or null once it was rolled back.
  Future<CartMutationResult?> enqueue(
    CartTask task, {
    CartTransform? optimistic,
    String? rollbackMessage,
  }) =>
      _push(task, optimistic: optimistic, rollbackMessage: rollbackMessage);

  void _dropWaiting(String coalesceKey) {
    final waiting = _findWaiting(coalesceKey);
    if (waiting == null) return;
    _queue.remove(waiting);
    waiting.completer.complete(null);
  }

  /// The line id to send: a provisional id resolves to the line the server
  /// created; a real id the known cart lacks is still sent and the server decides.
  static String? serverLineId(CartJson cart, String lineId) {
    final resolved = resolveLine(cart, lineId)?['id'];
    if (resolved is String) return resolved;
    return isProvisionalLineId(lineId) ? null : lineId;
  }

  static const _missingLine =
      CartMutationException('This item is no longer in your cart');

  Future<CartMutationResult?> removeCartLine(
    String lineId, {
    required Future<CartMutationResult> Function(String serverLineId) send,
    String? rollbackMessage,
  }) {
    _dropWaiting('qty:$lineId');
    return _push(
      (cart) async {
        final id = serverLineId(cart, lineId);
        if (id == null) throw _missingLine;
        return send(id);
      },
      optimistic: (cart) => removeLine(cart, lineId),
      rollbackMessage: rollbackMessage ?? 'Could not remove the item',
    );
  }

  /// Taps on the same line within [quantityCoalesceWindow] become one request
  /// with the final quantity. Earlier callers resolve with null (superseded).
  Future<CartMutationResult?> setLineQuantity(
    String lineId,
    int quantity, {
    required Future<CartMutationResult> Function(String serverLineId, int quantity) send,
    required Future<CartMutationResult> Function(String serverLineId) remove,
    String? rollbackMessage,
  }) {
    if (quantity <= 0) {
      return removeCartLine(lineId, send: remove, rollbackMessage: rollbackMessage);
    }

    final coalesceKey = 'qty:$lineId';
    final readyAt = _deps.now().add(quantityCoalesceWindow);
    CartJson optimistic(CartJson cart) => setQuantity(cart, lineId, quantity);
    Future<CartMutationResult> task(CartJson cart) async {
      final id = serverLineId(cart, lineId);
      if (id == null) throw _missingLine;
      return send(id, quantity);
    }

    final waiting = _findWaiting(coalesceKey);
    if (waiting != null) {
      final superseded = waiting.completer;
      final completer = Completer<CartMutationResult?>();
      waiting
        ..task = task
        ..optimistic = optimistic
        ..readyAt = readyAt
        ..completer = completer;
      superseded.complete(null);
      _publishView();
      return completer.future;
    }

    return _push(
      task,
      optimistic: optimistic,
      rollbackMessage: rollbackMessage ?? 'Could not update the quantity',
      coalesceKey: coalesceKey,
      readyAt: readyAt,
    );
  }
}
