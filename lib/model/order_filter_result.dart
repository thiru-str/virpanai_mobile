class OrdersFilterResult {
  final DateTime? startUtc;
  final DateTime? endUtc;
  final List<String> statuses;

  OrdersFilterResult({this.startUtc, this.endUtc, required this.statuses});

  @override
  String toString() =>
      'OrdersFilterResult(startUtc: $startUtc, endUtc: $endUtc, statuses: $statuses)';
}
