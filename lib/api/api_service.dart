import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/customer_response.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/model/product_category_response.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/model/send_otp_response.dart';
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/page_route_utils.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Configure Dio
    _dio.options.baseUrl = "https://cartel.waioz.com/";
    _dio.options.headers = {
      "Content-Type": "application/json",
      "x-publishable-api-key": "pk_44ebcac78abeb65b06a8adfc90f56bafa548043255c2da64f99174bfb1bd2830",
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
      AppLogger.print('API Params:', '${data ?? {}}');

      final response = await _dio.post(endpoint, data: data ?? {});
      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 400) {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Unexpected status code: ${response.statusCode}');
      }else if (response.statusCode == 401) {
        await _handleLogout(context, response.data['message']);
        throw Exception('Unauthorized: ${response.data['message']}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }

    } catch (e, stacktrace) {
      AppLogger.print('API Exception:','$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _makeGetRequest<T>(
      String endpoint,
      String? dynamicPath, // Optional dynamic path
      T Function(Map<String, dynamic>) fromJson,
      BuildContext context,
      ) async {
    try {

      // Combine endpoint and dynamic path
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath'
          : endpoint;

      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');

      final response = await _dio.get(fullEndpoint);

      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      }
      else if (response.statusCode == 400) {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:','$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }



  Future<void> _handleLogout(BuildContext context, String? message) async {
    // Optionally show a toast with the message
    if (message != null) {
      AppUtils.showToast(message);
    }

    // Clear user-specific data
    await SharedPreferencesUtil().clear();


    // Navigate to the login screen and clear all navigation history
    PageRouteUtils.pushAndRemoveUntil(context, WelcomePage());
  }

  Future<SendOtpResponse> sendOtp(BuildContext context,String phone) async {
    return _makePostRequest(
        "store/customers/send-otp",
        {"phone": phone},
            (data) => SendOtpResponse.fromJson(data),
        context
    );
  }

  Future<VerifyOtpResponse> verifyOtp(BuildContext context,String phone,String otp) async {
    return _makePostRequest(
        "store/customers/verify-otp",
        {"phone": phone,"otp": otp},
            (data) => VerifyOtpResponse.fromJson(data),
        context
    );
  }

  Future<RegisterResponse> register(BuildContext context,String email,String companyName,String firstName,String lastName,String phone,String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    return _makePostRequest(
        "store/customers",
        {"email": email,"company_name": companyName,"first_name":firstName,"last_name":lastName,"phone":phone, "metadata": {}},
            (data) => RegisterResponse.fromJson(data),
        context
    );
  }

  Future<ProductsResponse> listProducts(BuildContext context) async {
      return _makeGetRequest<ProductsResponse>(
        'store/products',
        null,
            (json) => ProductsResponse.fromJson(json),
        context,
      );
  }

  Future<ProductDetailReponse> productDetail(BuildContext context,String productId) async {
      return _makeGetRequest<ProductDetailReponse>(
        'store/products',
        productId,
            (json) => ProductDetailReponse.fromJson(json),
        context,
      );
  }

  Future<ProductCategoriesResponse> productCategories(BuildContext context) async {
      return _makeGetRequest<ProductCategoriesResponse>(
        'store/product-custom-categories',
            null,
            (json) => ProductCategoriesResponse.fromJson(json),
        context,
      );
  }

  Future<ProductCategoryResponse> productCategory(BuildContext context,String categoryId) async {
      return _makeGetRequest<ProductCategoryResponse>(
        'store/product-custom-categories',
        categoryId,
            (json) => ProductCategoryResponse.fromJson(json),
        context,
      );
  }

  Future<CustomerResponse> getCustomer(BuildContext context) async {
      await addToken();
      return _makeGetRequest<CustomerResponse>(
        'store/customers/me',
        null,
            (json) => CustomerResponse.fromJson(json),
        context,
      );
  }


  Future<void> addToken() async {
    _dio.options.headers['Authorization'] = 'Bearer ${await SharedPreferencesUtil().getString('token')}';
  }
}
