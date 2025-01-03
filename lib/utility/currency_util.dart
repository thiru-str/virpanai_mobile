class CurrencyUtil {
  static String? _cachedCurrencySymbol;

  // Initialize the currency symbol (Call this once during app initialization)
  static Future<void> initializeCurrencySymbol(String? currencySymbol) async {
    _cachedCurrencySymbol = currencySymbol;
  }

  // Synchronous function to get the currency symbol or return a default
  static String getCurrencySymbol() {
    return _cachedCurrencySymbol ?? '₹'; // Default to an empty string
  }

  // Append the currency symbol to a value
  static String appendCurrency(String value) {
    final currencySymbol = getCurrencySymbol();
    return '$currencySymbol$value';
  }
}
