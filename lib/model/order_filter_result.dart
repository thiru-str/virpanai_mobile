class OrdersFilterResult {
  final DateTime? startUtc;
  final DateTime? endUtc;
  final String? status;

  OrdersFilterResult({this.startUtc, this.endUtc, required this.status});

  @override
  String toString() =>
      'OrdersFilterResult(startUtc: $startUtc, endUtc: $endUtc, statuses: $status)';
}
