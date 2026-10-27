import 'package:dio/dio.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

/// Dedicated MiniPOS client. It deliberately does not use ApiService because
/// that client logs request headers and bodies, which is unsafe for bank/KYC
/// and end-customer checkout data.
class MiniPosService {
  MiniPosService._();
  static final MiniPosService instance = MiniPosService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: const {'Content-Type': 'application/json'},
  ));

  Future<Options> _options() async {
    final prefs = SharedPreferencesUtil();
    final token = await prefs.getString('token');
    final publishableKey = await prefs.getString('publishable_key');
    return Options(headers: {
      if (token?.isNotEmpty == true) 'Authorization': 'Bearer $token',
      if (publishableKey?.isNotEmpty == true)
        'x-publishable-api-key': publishableKey,
    });
  }

  Never _throw(DioException error) {
    final data = error.response?.data;
    final message = data is Map && data['message'] is String
        ? data['message'] as String
        : 'MiniPOS request failed. Please try again.';
    throw MiniPosException(message, error.response?.statusCode);
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(path,
          queryParameters: query, options: await _options());
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      _throw(error);
    }
  }

  Future<Map<String, dynamic>> post(String path,
      [Map<String, dynamic>? data]) async {
    try {
      final response = await _dio.post(path,
          data: data ?? <String, dynamic>{}, options: await _options());
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      _throw(error);
    }
  }

  Future<Map<String, dynamic>> put(String path,
      [Map<String, dynamic>? data]) async {
    try {
      final response = await _dio.put(path,
          data: data ?? <String, dynamic>{}, options: await _options());
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      _throw(error);
    }
  }

  Future<Map<String, dynamic>> patch(String path,
      [Map<String, dynamic>? data]) async {
    try {
      final response = await _dio.patch(path,
          data: data ?? <String, dynamic>{}, options: await _options());
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      _throw(error);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path, options: await _options());
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      _throw(error);
    }
  }
}

class MiniPosException implements Exception {
  final String message;
  final int? statusCode;
  const MiniPosException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}
