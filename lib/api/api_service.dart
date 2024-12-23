import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Configure Dio
    _dio.options.baseUrl = "https://test.posapi.storees.io/";
    _dio.options.headers = {
      "Content-Type": "application/json",
    };
    _dio.options.connectTimeout = const Duration(seconds: 30); // 5 seconds
    _dio.options.receiveTimeout = const Duration(seconds: 30); // 3 seconds
  }


  Future<T> _makePostRequest<T>(
      String endpoint,
      Map<String, dynamic>? data,
      T Function(Map<String, dynamic>) fromJson,
      BuildContext context,
      ) async {
    try {
      debugPrint('API Request: ${_dio.options.baseUrl}$endpoint');
      debugPrint('API Params: ${data ?? {}}');

      final response = await _dio.post(endpoint, data: data ?? {});
      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          debugPrint('API Response: ${response.data}');
          return fromJson(response.data);
        } else if (response.data['status'] == 401) {
          await _handleLogout(context, response.data['message']);
          throw Exception('Unauthorized: ${response.data['message']}');
        } else {
          AppUtils.showToast(response.data['message'] ?? 'An error occurred');
          throw Exception('API Error: ${response.data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }

    } catch (e, stacktrace) {
      debugPrint('API Exception: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('An error occurred: $e');
    }
  }


  Future<void> _handleLogout(BuildContext context, String? message) async {
    // Optionally show a toast with the message
    if (message != null) {
      AppUtils.showToast(message);
    }

    // Clear user-specific data
    await SharedPreferencesUtil.removeUserId();

    int? branchId = await SharedPreferencesUtil().getInt('branch_id');
    String? tenantId = await SharedPreferencesUtil().getString('tenant_id');

    // Navigate to the login screen and clear all navigation history
    /*Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(branchId: branchId!, tenantId: tenantId!)),
          (route) => false,
    );*/
  }





/*  Future<BranchResponse> getBranches(BuildContext context,String tenantId) async {
    _dio.options.headers['x-tenant-id'] = tenantId;
    return _makePostRequest(
      "get_branches",
          null,
          (data) => BranchResponse.fromJson(data),
          context
    );
  }*/


  Future<void> addHeader() async {
    _dio.options.headers['x-jwt-token'] = await SharedPreferencesUtil().getString('token');
  }
}
