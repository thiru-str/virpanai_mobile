/// One order and one default for a product's variants, shared by the product
/// page and the BASKET options sheet so the two always agree:
///
///  * order: cheapest first (the smallest pack first on a grocery shelf);
///    variants at the same price keep the product's own order;
///  * default: the cheapest variant in stock (the cheapest overall when none is).
///
/// The home card already shows the cheapest variant's price, so the sheet and
/// the product page open on the option the shopper just saw.
library;

/// A price string as a number; missing or unreadable prices sort last.
double variantPriceValue(Object? price) {
  final v = double.tryParse((price ?? '').toString().trim());
  return v ?? double.infinity;
}

/// [items] cheapest first. Stable: equal prices keep their original order
/// (Dart's List.sort is not stable, so the index breaks ties).
List<T> sortCheapestFirst<T>(Iterable<T> items, double Function(T item) price) {
  final indexed = items.toList().asMap().entries.toList();
  indexed.sort((a, b) {
    final byPrice = price(a.value).compareTo(price(b.value));
    return byPrice != 0 ? byPrice : a.key.compareTo(b.key);
  });
  return [for (final e in indexed) e.value];
}

/// The default pick from a list already sorted cheapest first.
T? cheapestInStock<T>(List<T> sorted, bool Function(T item) inStock) {
  for (final item in sorted) {
    if (inStock(item)) return item;
  }
  return sorted.isEmpty ? null : sorted.first;
}
