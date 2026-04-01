import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waioz/model/public_detail_model.dart';

class SharedPreferencesUtil {
  static final SharedPreferencesUtil _instance = SharedPreferencesUtil._internal();
  factory SharedPreferencesUtil() => _instance;

  SharedPreferencesUtil._internal();

  // Save data to SharedPreferences
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(value);
    await prefs.setString(key, jsonString);
  }

  Future<void> savePublicDetails(PublicDetailsResponse publicDetailsResponse) async {
    await saveMap('public_details', publicDetailsResponse.toJson());
    await saveString('publishable_key', publicDetailsResponse.token ?? '');
    await saveBool('google_map_usage', publicDetailsResponse.googleMapUsage ?? false);
    await saveString('app_header', publicDetailsResponse.theme?.header ?? '');
    await saveString(
      'invoice_url',
      publicDetailsResponse.storeDetails?.storeMetadata?.invoiceUrl ?? '',
    );
    await saveString(
      'customer_support',
      publicDetailsResponse.storeDetails?.storeMetadata?.customerSupport ?? '',
    );
  }

  // Retrieve data from SharedPreferences
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Delete data from SharedPreferences
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear all data in SharedPreferences
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    PublicDetailsResponse? publicDetailsResponse = await getPublicDetails();

    // Clear all preferences
    await prefs.clear();

    if (publicDetailsResponse != null) {
      await savePublicDetails(publicDetailsResponse);
      await SharedPreferencesUtil().saveBool('skip_login', false);
    }
  }

  Future<PublicDetailsResponse?> getPublicDetails() async {
    dynamic global = await SharedPreferencesUtil().getMap('public_details');
    if (global != null) {
      return PublicDetailsResponse.fromJson(global);
    }
    return null;
  }

  // Check if a key exists
  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  // Static method to save the user ID to SharedPreferences
  static Future<void> saveUserId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  // Static method to retrieve the user ID from SharedPreferences
  static Future<int?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Static method to remove the user ID from SharedPreferences (e.g., on logout)
  static Future<void> removeUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
