import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/address_list_response.dart';
import 'package:waioz/model/customer_response.dart';
import 'package:waioz/model/delete_response.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/order_history_reponse.dart';
import 'package:waioz/model/place_order_response.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/model/product_category_response.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_info_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/model/review_response.dart';
import 'package:waioz/model/send_otp_response.dart';
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/page_route_utils.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Configure Dio
    _dio.options.baseUrl = "https://cartel.waioz.com/";
    _dio.options.headers = {
      "Content-Type": "application/json",
      "x-publishable-api-key":
          "pk_44ebcac78abeb65b06a8adfc90f56bafa548043255c2da64f99174bfb1bd2830",
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
      debugPrint('API headers: ${_dio.options.headers}');
      debugPrint('API Request: ${_dio.options.baseUrl}$endpoint');
      AppLogger.print('API Params:', '${data ?? {}}');

      final response = await _dio.post(endpoint, data: data ?? {});
      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 400) {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else if (response.statusCode == 401) {
        await _handleLogout(context, response.data['message']);
        throw Exception('Unauthorized: ${response.data['message']}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _makeGetRequest<T>(
      String endpoint,
      String? dynamicPath,
      Map<String, dynamic>? queryParams,
      T Function(Map<String, dynamic>) fromJson,
      BuildContext context) async {
    try {
      // Combine endpoint and dynamic path
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath'
          : endpoint;

      debugPrint('API headers: ${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.print('API Params:', '${queryParams ?? {}}');

      // Include query parameters in the GET request
      final response = await _dio.get(
        fullEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 400) {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _makeDeleteRequest<T>(
    String endpoint,
    String? dynamicPath,
    Map<String, dynamic>?
        queryParams, // Optional dynamic path (for example, addressID)
    T Function(Map<String, dynamic>) fromJson,
    BuildContext context,
  ) async {
    try {
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath' // Append dynamic path if provided
          : endpoint;
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.print('API Params:', '${queryParams ?? {}}');

      // Make the DELETE request
      final response =
          await _dio.delete(fullEndpoint, data: queryParams);

      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data); // Parse the response data
      } else if (response.statusCode == 400) {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
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

  Future<SendOtpResponse> sendOtp(BuildContext context, String phone) async {
    return _makePostRequest("store/customers/send-otp", {"phone": phone},
        (data) => SendOtpResponse.fromJson(data), context);
  }

  Future<VerifyOtpResponse> verifyOtp(
      BuildContext context, String phone, String otp) async {
    return _makePostRequest(
        "store/customers/verify-otp",
        {"phone": phone, "otp": otp},
        (data) => VerifyOtpResponse.fromJson(data),
        context);
  }

  Future<RegisterResponse> register(
      BuildContext context,
      String email,
      String companyName,
      String firstName,
      String lastName,
      String phone,
      String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    return _makePostRequest(
        "store/customers",
        {
          "email": email,
          "company_name": companyName,
          "first_name": firstName,
          "last_name": lastName,
          "phone": phone,
          "metadata": {}
        },
        (data) => RegisterResponse.fromJson(data),
        context);
  }

  Future<ProductsResponse> listProducts(
      BuildContext context, String categoryId) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makeGetRequest<ProductsResponse>(
      'store/products',
      null,
      {"region_id": regionId, "category_id": categoryId},
      (json) => ProductsResponse.fromJson(json),
      context,
    );
  }

  Future<ProductsResponse> listBrands(
      BuildContext context, String tagId) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makeGetRequest<ProductsResponse>(
      'store/products',
      null,
      {"region_id": regionId, "tag_id": tagId},
      (json) => ProductsResponse.fromJson(json),
      context,
    );
  }

  Future<ProductDetailReponse> productDetail(
      BuildContext context, String productId) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makeGetRequest<ProductDetailReponse>(
      'store/products',
      productId,
      {"region_id": regionId},
      (json) => ProductDetailReponse.fromJson(json),
      context,
    );
  }

  Future<ProductCategoriesResponse> productCategories(
      BuildContext context) async {
    return _makeGetRequest<ProductCategoriesResponse>(
      'store/product-custom-categories',
      null,
      null,
      (json) => ProductCategoriesResponse.fromJson(json),
      context,
    );
  }

  Future<ProductCategoryResponse> productCategory(
      BuildContext context, String categoryId) async {
    return _makeGetRequest<ProductCategoryResponse>(
      'store/product-custom-categories',
      categoryId,
      null,
      (json) => ProductCategoryResponse.fromJson(json),
      context,
    );
  }

  Future<CustomerResponse> getCustomer(BuildContext context) async {
    await addToken();
    return _makeGetRequest<CustomerResponse>(
      'store/customers/me',
      null,
      null,
      (json) => CustomerResponse.fromJson(json),
      context,
    );
  }

  Future<HomePageResponse> getHomePage(BuildContext context) async {
    await addToken();
    return _makeGetRequest<HomePageResponse>(
      'store/get_home_page/v1',
      null,
      null,
      (json) => HomePageResponse.fromJson(json),
      context,
    );
  }

  Future<RegisterResponse> createOrUpdateAddress(
      BuildContext context,
      String? firstName,
      String? lastName,
      String? addressID,
      String address_1,
      String phone,
      String city,
      String state,
      String country,
      String zipCode,
      String addressName) async {
    await addToken();
    return _makePostRequest(
        addressID != null
            ? "store/customers/me/addresses/$addressID"
            : "store/customers/me/addresses",
        {
          "first_name" : firstName,
          "last_name" : lastName,
          "address_1": address_1,
          "phone": phone,
          "city": city,
          "province": state,
          "postal_code": zipCode,
          "address_name": addressName,
          "metadata": {}
        },
        (data) => RegisterResponse.fromJson(data),
        context);
  }

  Future<GetAddressListResponse> getAddressList(BuildContext context) async {
    await addToken();
    return _makeGetRequest<GetAddressListResponse>(
      'store/customers/me/addresses?fields=+address_name',
      null,
      null,
      (json) => GetAddressListResponse.fromJson(json),
      context,
    );
  }

  Future<RegisterResponse> deleteAddress(
      BuildContext context, String? addressID) async {
    await addToken();
    return _makeDeleteRequest("store/customers/me/addresses/$addressID", null, null,
        (data) => RegisterResponse.fromJson(data), context);
  }

  Future<ReviewResponse> getProductReviews(
      BuildContext context, String productId) async {
    await addToken();
    return _makeGetRequest<ReviewResponse>(
      'store/product-reviews',
      productId,
      null,
      (json) => ReviewResponse.fromJson(json),
      context,
    );
  }

  Future<WishlistResponse> getWishList(
      BuildContext context, String? customerID) async {
    await addToken();
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makeGetRequest<WishlistResponse>(
      'store/product-wishlist',
      null,
      {"region_id": regionId},
      (json) => WishlistResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> addCart(
      BuildContext context, int qty, String variantId) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/carts/$cartId/line-items',
      {"variant_id": variantId, "quantity": qty, "metadata": {}},
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> getCart(BuildContext context) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makeGetRequest(
      'store/carts/$cartId',
      null,
      null,
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<WishlistResponse> addFavourite(
      BuildContext context, String productId) async {
    await addToken();
    return _makePostRequest(
      'store/product-wishlist',
      {"product_id": productId},
      (json) => WishlistResponse.fromJson(json),
      context,
    );
  }

  Future<WishlistResponse> deleteFavourite(
      BuildContext context, String? productId, String? wishlistId) async {
    await addToken();
    return _makeDeleteRequest('store/product-wishlist', wishlistId, {"product_id": productId},
            (data) => WishlistResponse.fromJson(data), context);

  }

  Future<CartResponse> updateAddress(
      BuildContext context, CheckOut.ShippingAddress address) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/carts/$cartId',
      {"shipping_address": address},
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> updateCart(
      BuildContext context, int qty, String cartItemId) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/carts/$cartId/line-items/$cartItemId',
      {"quantity": qty, "metadata": {}},
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<DeleteResponse> removeCart(
      BuildContext context, String cartItemId) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makeDeleteRequest(
      'store/carts/$cartId/line-items/$cartItemId',
      null,
      null,
      (json) => DeleteResponse.fromJson(json),
      context,
    );
  }

  Future<PlaceOrderResponse> placeOrder(
      BuildContext context, String pp_id) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/place-order/$cartId',
      {"payment_provider_id": pp_id},
      (json) => PlaceOrderResponse.fromJson(json),
      context,
    );
  }

  // Future<CartResponse> getOrderHistory(BuildContext context) async {
  //   await addToken();
  //   return _makeGetRequest<WishlistResponse>(
  //     'store/product-wishlist/$customerID',
  //     null,
  //     {"region_id": regionId},
  //         (json) => WishlistResponse.fromJson(json),
  //     context,
  //   );
  // }
  Future<OrderHistoryResponse> getOrderHistory(BuildContext context) async {
    await addToken();
    return _makeGetRequest<OrderHistoryResponse>(
      'store/orders?fields=+subtotal,+tax_total,+total,+cart.shipping_address.*',
      null,
      null,
      (json) => OrderHistoryResponse.fromJson(json),
      context,
    );
  }

  Future<ProductInfoResponse> getProductInfo(
      BuildContext context, String? productId, String? variantId) async {
    await addToken();
    return _makePostRequest(
      'store/product-info',
      {"product_id": productId, "variant_id": variantId},
      (json) => ProductInfoResponse.fromJson(json),
      context,
    );
  }

  Future<RegisterResponse> updateProfile(
    BuildContext context,
    String phone,
    String companyName,
    String firstName,
    String lastName,
  ) async {
    await addToken();
    return _makePostRequest(
        "store/customers/me",
        {
          "phone": phone,
          "company_name": companyName,
          "first_name": firstName,
          "last_name": lastName,
          "metadata": {}
        },
        (data) => RegisterResponse.fromJson(data),
        context);
  }

  Future<void> addToken() async {
    _dio.options.headers['Authorization'] =
        'Bearer ${await SharedPreferencesUtil().getString('token')}';
  }
}
