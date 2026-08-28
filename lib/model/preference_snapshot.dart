class PreferenceSnapshot {
  final String productId;
  final String variantId;
  final String title;
  final num amount;
  final String currencyCode;

  const PreferenceSnapshot({
    required this.productId,
    required this.variantId,
    required this.title,
    required this.amount,
    required this.currencyCode,
  });

  static PreferenceSnapshot? fromDynamic(dynamic value) {
    if (value is! Map) return null;

    final productId = value['product_id']?.toString() ?? '';
    final variantId = value['variant_id']?.toString() ?? '';
    final title = value['title']?.toString() ?? '';
    final amount = value['amount'] is num
        ? value['amount'] as num
        : num.tryParse(value['amount']?.toString() ?? '');
    final currencyCode = value['currency_code']?.toString() ?? '';

    if (productId.isEmpty ||
        variantId.isEmpty ||
        title.isEmpty ||
        amount == null ||
        amount < 0 ||
        currencyCode.isEmpty) {
      return null;
    }

    return PreferenceSnapshot(
      productId: productId,
      variantId: variantId,
      title: title,
      amount: amount,
      currencyCode: currencyCode.toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'variant_id': variantId,
        'title': title,
        'amount': amount,
        'currency_code': currencyCode,
      };
}
