import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

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

    try {
      final number = double.tryParse(value.replaceAll(',', ''));
      if (number != null) {
        final formatter = NumberFormat("#,##0.00", "en_IN");
        final formattedValue = formatter.format(number);
        return '$currencySymbol$formattedValue';
      }
    } catch (e) {
      // If parsing fails, return original with symbol
    }

    // Fallback: return original value with currency symbol
    return '$currencySymbol$value';
  }
}
