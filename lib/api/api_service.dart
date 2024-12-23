import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/product_model.dart';
import 'package:waioz/model/branch_response_model.dart';
import 'package:waioz/model/create_order_response_model.dart';
import 'package:waioz/model/login_response_model.dart';
import 'package:waioz/model/open_cash_response_model.dart';
import 'package:waioz/model/send_otp_response_model.dart';
import 'package:waioz/model/verify_otp_response_model.dart';
import 'package:waioz/ui/login_page.dart';

import '../model/get_orders_response_model.dart';
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(branchId: branchId!, tenantId: tenantId!)),
          (route) => false,
    );
  }



  Future<List<ProductCategory>> getAllProducts() async {
    try {
      await addHeader();
      int? branchId = await SharedPreferencesUtil().getInt('branch_id');

      final response = await _dio.post("get_all_products", data: {"branch_id": branchId});
      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data']['products_list'] as List)
            .map((categoryJson) => ProductCategory.fromJson(categoryJson))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }



  Future<BranchResponse> getBranches(BuildContext context,String tenantId) async {
    _dio.options.headers['x-tenant-id'] = tenantId;
    return _makePostRequest(
      "get_branches",
          null,
          (data) => BranchResponse.fromJson(data),
          context
    );
  }

  Future<GetOrdersResponse> getOrders(BuildContext context) async {
    await addHeader();
    int? branchId = await SharedPreferencesUtil().getInt('branch_id');
    return _makePostRequest(
      "get_orders",
        {"branch_id": branchId,"fiscal_year": "2024-2025"},
          (data) => GetOrdersResponse.fromJson(data),
          context
    );
  }

  Future<LoginResponse> login(BuildContext context,String tenantId,int branchId,String employeeName,String password) async {
    _dio.options.headers['x-tenant-id'] = tenantId;
    return _makePostRequest(
      "employee_login",
      {"branch_id": branchId,"employee_name": employeeName,"password": password},
          (data) => LoginResponse.fromJson(data),
      context
    );
  }

  Future<SendOtpResponse> sendOtp(BuildContext context,String emailId) async {
    return _makePostRequest(
      "login_otp",
      {"email_id": emailId},
          (data) => SendOtpResponse.fromJson(data),
      context
    );
  }

  Future<VerifyOtpResponse> verifyOtp(BuildContext context,String emailId, String otp) async {
    return _makePostRequest(
      "verify_login_otp",
      {"email_id": emailId, "otp": otp},
          (data) => VerifyOtpResponse.fromJson(data),
      context
    );
  }


  Future<CreateOrderResponse> createOrder(String tenantId,String branchId,String employeeName,String password) async {
    try {
      _dio.options.headers['x-tenant-id'] = tenantId;
        debugPrint('API Request: ${_dio.options.baseUrl}get_branches');
      final response = await _dio.post("get_branches",data: {"branch_id": branchId,"employee_name": employeeName,"password": password});
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('API Response: ${response.data}');
        return CreateOrderResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<OpenCashResponse> openCash(BuildContext context,int employeeId,int openBalanceAmount) async {
    await addHeader();
    int? branchId = await SharedPreferencesUtil().getInt('branch_id');
    return _makePostRequest(
      "open_cash",
      {
        "branch_id": branchId,
        "employee_id": employeeId,
        "open_balence": openBalanceAmount
      },
          (data) => OpenCashResponse.fromJson(data),
      context
    );
  }

  Future<OpenCashResponse> get(String tenantId,String branchId,String employeeName,String password) async {
    try {
      _dio.options.headers['x-tenant-id'] = tenantId;
        debugPrint('API Request: ${_dio.options.baseUrl}get_branches');
      final response = await _dio.post("get_branches",data: {"branch_id": branchId,"employee_name": employeeName,"password": password});
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('API Response: ${response.data}');
        return OpenCashResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> addHeader() async {
    _dio.options.headers['x-jwt-token'] = await SharedPreferencesUtil().getString('token');
  }
}
