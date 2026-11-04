import 'package:waioz/ui/cart_response.dart';

const String walletProviderId = 'pp_wallet_wallet';
const String cashOnDeliveryProviderId = 'pp_system_default';

/// Sessions that can take the gateway payment. With a wallet split the cart
/// also carries the wallet's own session, which is never the one to pay with.
List<PaymentSession> payableSessions(List<PaymentSession> sessions) {
  final hasSplit = sessions.length > 1 &&
      sessions.any((session) => session.providerId == walletProviderId);
  return hasSplit
      ? sessions.where((session) => session.providerId != walletProviderId).toList()
      : sessions;
}

String? _rememberedProviderId(dynamic metadata) =>
    metadata is Map ? metadata['last_payment_provider_id']?.toString() : null;

/// The provider to preselect, matching the web checkout: the shopper's own
/// selection stored on the cart (seeded by the backend from their previous
/// order) when this store still offers it, then the active session.
String preferredPaymentProviderId(
  Cart? cart, {
  required Iterable<String> availableProviderIds,
}) {
  final remembered = _rememberedProviderId(cart?.metadata);
  final available = availableProviderIds.toSet();
  if (remembered != null &&
      remembered.isNotEmpty &&
      (available.isEmpty || available.contains(remembered))) {
    return remembered;
  }

  final sessions = payableSessions(cart?.paymentCollection?.paymentSessions ?? const []);
  final pending = sessions.where((session) => session.status == 'pending');
  return pending.firstOrNull?.providerId ??
      sessions.firstOrNull?.providerId ??
      cashOnDeliveryProviderId;
}

/// The session created for [providerId], preferring one that is still pending.
/// Leftovers from an earlier selection must not be paid with.
PaymentSession? sessionForProvider(Cart? cart, String? providerId) {
  if (providerId == null) return null;
  final matching = (cart?.paymentCollection?.paymentSessions ?? const <PaymentSession>[])
      .where((session) => session.providerId == providerId)
      .toList();
  return matching.where((session) => session.status == 'pending').firstOrNull ??
      matching.firstOrNull;
}
