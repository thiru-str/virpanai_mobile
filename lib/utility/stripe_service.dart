import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeService {
  static const String _secretKey = 'sk_test_51QjKGFC5ZYai6Al89DMqc4eIRWE9xQyDx1FfgtFvWl7g4iIYzgpOgZwiUgoWYY6FyZ7lAXEqhsnvxuJGZyi8qjnB00vHHhcYf5'; // Replace with your Secret Key (NOT RECOMMENDED in production)
  static const String _baseUrl = 'https://api.stripe.com/v1/payment_intents';

  static Future<Map<String, dynamic>> createPaymentIntent(
      int amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(), // Amount in smallest currency unit (e.g., cents for USD)
          'currency': currency,
          'payment_method_types[]': 'card', // Supported payment methods
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create Payment Intent: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error creating Payment Intent: $error');
    }
  }
}
