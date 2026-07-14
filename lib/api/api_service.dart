import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/add_on_products_response.dart';
import 'package:waioz/model/address_list_response.dart';
import 'package:waioz/model/collection_response.dart';
import 'package:waioz/model/cross_sell_products_response.dart';
import 'package:waioz/model/filter_category_response.dart';
import 'package:waioz/model/order_detail_response.dart';
import 'package:waioz/model/payment_method_response.dart';
import 'package:waioz/model/related_products_response.dart';
import 'package:waioz/model/return_response.dart';
import 'package:waioz/model/return_success_response.dart';
import 'package:waioz/model/store_content_response.dart';
import 'package:waioz/model/customer_response.dart';
import 'package:waioz/model/delete_response.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/neft_transaction_response.dart';
import 'package:waioz/model/wallet_response.dart';
import 'package:waioz/model/promotion_list_model.dart';
import 'package:waioz/model/order_history_reponse.dart';
import 'package:waioz/model/place_order_response.dart';
import 'package:waioz/model/product_categories_response.dart';
import 'package:waioz/model/product_category_response.dart';
import 'package:waioz/model/product_detail_response.dart';
import 'package:waioz/model/product_info_response.dart';
import 'package:waioz/model/product_response.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/model/register_response.dart';
import 'package:waioz/model/review_response.dart';
import 'package:waioz/model/send_otp_response.dart';
import 'package:waioz/model/shipping_response.dart';
import 'package:waioz/model/up_sell_products_response.dart';
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_error_reporter.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/page_route_utils.dart';
import '../model/cancel_order_response.dart';
import '../model/custom_page_response.dart';
import '../model/email_register_response.dart';
import '../model/order_history_individual_reponse.dart';
import '../model/refresh_token_response.dart';
import '../model/tags_response.dart';
import '../ui/bottom_nav_page.dart';
import '../utility/app_strings.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  late final Dio _dio;

  ApiService._internal() {
    // Configure Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: {
          "Content-Type": "application/json",
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // Pull a human-readable error message from response.data without assuming
  // it's a Map. Some upstreams return plain text or HTML, in which case
  // response.data['message'] threw "type 'String' is not a subtype of type
  // 'int' of 'index'" and masked the real failure.
  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) return m;
      final err = data['error'];
      if (err is Map) {
        final em = err['message'];
        if (em is String && em.isNotEmpty) return em;
      }
      if (err is String && err.isNotEmpty) return err;
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return 'An error occurred';
  }

  Future<T> _makePostRequest<T>(
    String endpoint,
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>) fromJson,
    BuildContext context,
  ) async {
    try {
      await setPublishableKey();

      AppLogger.logFullJson(_dio.options.headers);
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$endpoint');
      AppLogger.logFullJson(data ?? {});

      final response =
          await _dio.post(endpoint, data: data ?? {}, options: Options(
        validateStatus: (status) {
          // Accept status codes 400-499 as valid responses for handling errors manually
          return status != null && status < 500;
        },
      ));
      if (response.statusCode == 200) {
        AppLogger.logFullJson(response.data);
        return fromJson(response.data);
      } else if (response.statusCode == 401) {
        final errorMsg = _extractErrorMessage(response.data);
        await _handleLogout(context, errorMsg);
        throw Exception('Unauthorized: $errorMsg');
      } else {
        AppUtils.showToast(_extractErrorMessage(response.data));
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      AppErrorReporter.instance.recordHandled(
        e,
        stacktrace,
        reason: 'POST request failed',
        attributes: {
          'endpoint': endpoint,
          'method': 'POST',
        },
      );
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _makeGetRequest<T>(
      String endpoint,
      String? dynamicPath,
      Map<String, dynamic>? queryParams,
      T Function(Map<String, dynamic>) fromJson,
      BuildContext? context) async {
    try {
      await setPublishableKey();
      // Combine endpoint and dynamic path
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath'
          : endpoint;

      AppLogger.logFullJson(_dio.options.headers);
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.logFullJson(queryParams ?? {});

      // Include query parameters in the GET request
      final response = await _dio
          .get(fullEndpoint, queryParameters: queryParams, options: Options(
        validateStatus: (status) {
          // Accept status codes 400-499 as valid responses for handling errors manually
          return status != null && status < 500;
        },
      ));

      AppLogger.print('response  statuscode:', '${response.statusCode}');
      if (response.statusCode == 200) {
        AppLogger.logFullJson(response.data);
        return fromJson(response.data);
      } else if (response.statusCode == 400) {
        AppUtils.showToast(_extractErrorMessage(response.data));
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else if (response.statusCode == 401) {
        final errorMsg = _extractErrorMessage(response.data);
        await _handleLogout(context!, errorMsg);
        throw Exception('Unauthorized: $errorMsg');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      AppErrorReporter.instance.recordHandled(
        e,
        stacktrace,
        reason: 'GET request failed',
        attributes: {
          'endpoint': endpoint,
          'dynamic_path': dynamicPath ?? '',
          'method': 'GET',
        },
      );
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
      await setPublishableKey();
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath' // Append dynamic path if provided
          : endpoint;
      AppLogger.logFullJson(_dio.options.headers);
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.logFullJson(queryParams ?? {});

      // Make the DELETE request
      final response =
          await _dio.delete(fullEndpoint, data: queryParams, options: Options(
        validateStatus: (status) {
          // Accept status codes 400-499 as valid responses for handling errors manually
          return status != null && status < 500;
        },
      ));

      if (response.statusCode == 200) {
        AppLogger.logFullJson(response.data);
        return fromJson(response.data); // Parse the response data
      } else if (response.statusCode == 400) {
        AppUtils.showToast(_extractErrorMessage(response.data));
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      AppErrorReporter.instance.recordHandled(
        e,
        stacktrace,
        reason: 'DELETE request failed',
        attributes: {
          'endpoint': endpoint,
          'dynamic_path': dynamicPath ?? '',
          'method': 'DELETE',
        },
      );
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _uploadFile<T>({
    required File file,
    required String apiUrl,
    required T Function(Map<String, dynamic>) fromJson,
    required BuildContext context,
  }) async {
    try {
      // Prepare FormData with the image file
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });

      AppLogger.print('API Request:', '${_dio.options.baseUrl}$apiUrl');
      AppLogger.print('Uploading File:', file.path);

      await setPublishableKey();

      // Make the POST request
      final response = await _dio.post(
        '${_dio.options.baseUrl}$apiUrl',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.logFullJson(response.data);
        return fromJson(response.data);
      } else if (response.statusCode == 400) {
        AppUtils.showToast(_extractErrorMessage(response.data));
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      AppErrorReporter.instance.recordHandled(
        e,
        stacktrace,
        reason: 'File upload failed',
        attributes: {
          'endpoint': apiUrl,
          'file_path': file.path,
          'method': 'POST',
        },
      );
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
    await AppErrorReporter.instance.clearUser();

    bool skipLogin =
        await SharedPreferencesUtil().getBool('skip_login') ?? false;

    PageRouteUtils.pushAndRemoveUntil(
        context, skipLogin ? const BottomNavPage() : WelcomePage());
  }

  Future<SendOtpResponse> sendOtp(
      BuildContext context, String countryCode, String phone) async {
    return _makePostRequest(
        "store/customers/send-otp",
        {"country_code": countryCode, "phone": phone},
        (data) => SendOtpResponse.fromJson(data),
        context);
  }

  Future<VerifyOtpResponse> verifyOtp(BuildContext context, String countryCode,
      String phone, String otp) async {
    String? deviceId = await _updateToken();
    return _makePostRequest(
        "store/customers/verify-otp",
        {
          "device_id": deviceId,
          "country_code": countryCode,
          "phone": phone,
          "otp": otp
        },
        (data) => VerifyOtpResponse.fromJson(data),
        context);
  }

  Future<String?> _updateToken() async {
    String? fcmToken = await SharedPreferencesUtil().getString('fcm_token');

    if (fcmToken == null || fcmToken.isEmpty) {
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          AppLogger.print('FCM token: ', fcmToken);
          await SharedPreferencesUtil().saveString('fcm_token', fcmToken);
        } else {
          AppLogger.print('Failed to generate a new FCM token', '');
          return null;
        }
      } catch (e) {
        AppLogger.print('Error getting FCM token: $e', '');
        return null;
      }
    }

    // 3. Check if the token we have has been uploaded
    String uploadedToken =
        await SharedPreferencesUtil().getString('fcm_token_uploaded') ?? '';

    // 4. If it's a new token, upload it to the server
    if (fcmToken != uploadedToken) {
      AppLogger.print('Uploading new FCM token', fcmToken);
      // Note: It's generally advised to avoid passing 'context' to long-lived operations
      // as it might be disposed. Consider providing a way to get a fresh context or use a global navigator key.
      await SharedPreferencesUtil().saveString('fcm_token_uploaded', fcmToken);
    } else {
      AppLogger.print('FCM token already uploaded', '');
    }

    // 5. Return the token to the caller
    return fcmToken;
  }

  Future<RegisterResponse> register(
      BuildContext context,
      String email,
      String companyName,
      String firstName,
      String lastName,
      String countryCode,
      String phone,
      String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    String? deviceId = await _updateToken();
    final response = await _makePostRequest(
        "store/customers",
        {
          "email": email,
          "company_name": companyName,
          "first_name": firstName,
          "last_name": lastName,
          "phone": phone,
          "metadata": {"country_code": countryCode, "device_id": deviceId}
        },
        (data) => RegisterResponse.fromJson(data),
        context);
    await AppErrorReporter.instance.syncCustomer(response.customer);
    await AppErrorReporter.instance.addBreadcrumb(
      'customer_registered',
      attributes: {
        'auth_type': 'otp',
      },
    );
    return response;
  }

  Future<EmailRegisterResponse> registerEmail(
      BuildContext context,
      String email,
      String companyName,
      String firstName,
      String lastName,
      String countryCode,
      String phone,
      String password) async {
    String? deviceId = await _updateToken();
    final response = await _makePostRequest(
        "store/customers/email-register",
        {
          "email": email,
          "company_name": companyName,
          "first_name": firstName,
          "last_name": lastName,
          "phone": phone,
          "password": password,
          "metadata": {"country_code": countryCode, "device_id": deviceId}
        },
        (data) => EmailRegisterResponse.fromJson(data),
        context);
    await AppErrorReporter.instance.setUser(
      id: response.customer?.id,
      email: response.customer?.email,
      phone: response.customer?.phone,
      firstName: response.customer?.firstName,
      lastName: response.customer?.lastName,
      companyName: response.customer?.companyName,
    );
    await AppErrorReporter.instance.addBreadcrumb(
      'customer_registered',
      attributes: {
        'auth_type': 'email',
      },
    );
    return response;
  }

  Future<RefreshTokenResponse> refreshToken(
    BuildContext context,
    String token,
  ) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    return _makePostRequest("auth/token/refresh", null,
        (data) => RefreshTokenResponse.fromJson(data), context);
  }

  Future<ProductsResponse> listProducts(
    BuildContext context,
    String categoryId,
    String collectionId,
    String tagId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String searchString, {
    int offset = 0,
    int limit = 10,
  }) async {
    await addToken();
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    final queryParams = <String, dynamic>{};

    if (regionId != null && regionId.isNotEmpty) {
      queryParams['region_id'] = regionId;
    }

    if (categoryId.trim().isNotEmpty) {
      final categories = categoryId
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (categories.isNotEmpty) {
        queryParams['category_id[]'] = categories;
      }
    }

    if (tagId.trim().isNotEmpty) {
      final tags = tagId
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (tags.isNotEmpty) {
        queryParams['tag_id[]'] = tags;
      }
    }

    if (collectionId.trim().isNotEmpty) {
      final collections = collectionId
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (collections.isNotEmpty) {
        queryParams['collection_id[]'] = collections;
      }
    }

    if (minPrice != null) {
      queryParams['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice;
    }

    if (sortBy != null) {
      queryParams['order'] = sortBy == AppStrings.low_high ? 'price' : '-price';
    }

    if (searchString.isNotEmpty) {
      queryParams['q'] = searchString;
    }

    queryParams['offset'] = offset.toString();
    queryParams['limit'] = limit.toString();

    return _makeGetRequest<ProductsResponse>(
      'store/list-products',
      null,
      queryParams,
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
      '$productId?fields=+variants.inventory_quantity,+metadata',
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
    final response = await _makeGetRequest<CustomerResponse>(
      'store/customers/me',
      null,
      null,
      (json) => CustomerResponse.fromJson(json),
      context,
    );
    await AppErrorReporter.instance.syncCustomer(response.customer);
    return response;
  }

  Future<HomePageResponse> getHomePage(BuildContext context,
      {int offset = 0,
      int limit = 0,
      double? latitude,
      double? longitude,
      String? pincode}) async {
    await addToken();
    return _makePostRequest<HomePageResponse>(
      'store/get_home_page/v8',
      {
        'limit': limit,
        'offset': offset,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      },
      (json) => HomePageResponse.fromJson(json),
      context,
    );
  }

  Future<CustomPageResponse> getCustomPage(
      BuildContext context, String slug) async {
    await addToken();
    return _makePostRequest<CustomPageResponse>(
      'store/get_custom_page/v2/$slug',
      null,
      (json) => CustomPageResponse.fromJson(json),
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
      String addressName,
      String latitude,
      String longitude) async {
    await addToken();
    return _makePostRequest(
        addressID != null
            ? "store/customers/me/addresses/$addressID"
            : "store/customers/me/addresses",
        {
          "first_name": firstName,
          "last_name": lastName,
          "address_1": address_1,
          "phone": phone,
          "city": city,
          "province": state,
          "postal_code": zipCode,
          "address_name": addressName,
          "country_code": "in",
          "metadata": {"latitude": latitude, "longitude": longitude}
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
    return _makeDeleteRequest("store/customers/me/addresses/$addressID", null,
        null, (data) => RegisterResponse.fromJson(data), context);
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

  Future<ReturnSuccessResponse> postProductReview(
    BuildContext context,
    String productId,
    String rating,
    String description,
  ) async {
    await addToken();
    return _makePostRequest(
      'store/product-reviews',
      {
        'product_id': productId,
        'rating': rating,
        'description': description,
      },
      (json) => ReturnSuccessResponse.fromJson(json),
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
      'store/custom-carts/$cartId/line-items',
      {"variant_id": variantId, "quantity": qty, "metadata": {}},
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> getCart(BuildContext context) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makeGetRequest(
      'store/custom-carts/$cartId',
      null,
      null,
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<PromotionListResponse> getAvailablePromotions(
      BuildContext context, String cartId) async {
    await addToken();
    return _makeGetRequest(
      'store/promotions',
      null,
      {'cart_id': cartId},
      (json) => PromotionListResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> addPromoCode(
      BuildContext context, String promoCode, {List<String>? removeCodes}) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    final body = <String, dynamic>{
      "promo_codes": [promoCode],
    };
    if (removeCodes != null && removeCodes.isNotEmpty) {
      body["remove_codes"] = removeCodes;
    }
    return _makePostRequest(
      'store/custom-carts/$cartId/promotions',
      body,
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> removePromoCode(
      BuildContext context, List<String> promoCodes) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makeDeleteRequest(
      'store/custom-carts/$cartId/promotions',
      null,
      {"promo_codes": promoCodes},
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
    return _makeDeleteRequest(
        'store/product-wishlist',
        wishlistId,
        {"product_id": productId},
        (data) => WishlistResponse.fromJson(data),
        context);
  }

  Future<CartResponse> updateAddress(
      BuildContext context, CheckOut.ShippingAddress address) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/carts/$cartId',
      {"shipping_address": address, "billing_address": address},
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> updateCart(
      BuildContext context, int qty, String cartItemId) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/custom-carts/$cartId/line-items/$cartItemId',
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
      'store/custom-carts/$cartId/line-items/$cartItemId',
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

  Future<String?> initiateIciciPayment(BuildContext context) async {
    await setPublishableKey();
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    final response = await _dio.post(
      'store/place-order/$cartId',
      data: {"payment_provider_id": "pp_icici_icici"},
    );
    if (response.statusCode == 200) {
      return response.data?['icici_redirect_url'] as String?;
    }
    throw Exception('Failed to initiate ICICI payment');
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
  Future<OrderHistoryResponse> getOrderHistory(
      BuildContext context, int limit, int offset) async {
    await addToken();
    return _makeGetRequest<OrderHistoryResponse>(
      'store/orders?order=-created_at&fields=+subtotal,+tax_total,+total,+payment_collections.payments.*,+cart.shipping_address.*,',
      null,
      {'limit': limit, 'offset': offset},
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
    final response = await _makePostRequest(
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
    await AppErrorReporter.instance.syncCustomer(response.customer);
    await AppErrorReporter.instance.addBreadcrumb('customer_profile_updated');
    return response;
  }

  Future<ShippingResponse> getShippingInfo(BuildContext context) async {
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makeGetRequest<ShippingResponse>(
      'store/shipping-options',
      null,
      {"cart_id": cartId},
      (json) => ShippingResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> updateShippingMethod(
      BuildContext context, String optionId) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/carts/$cartId/shipping-methods',
      {"option_id": optionId},
      (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<PaymentMethodResponse> updatePaymentMethod(BuildContext context,
      String paymentProviderId, CartResponse cartResponse) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/update-payment-method/$cartId',
      {"payment_provider_id": paymentProviderId},
      (json) => PaymentMethodResponse.fromJson(json),
      context,
    );
  }

  Future<PlaceOrderResponse> completeCart(BuildContext context) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/custom-carts/$cartId/complete',
      null,
      (json) => PlaceOrderResponse.fromJson(json),
      context,
    );
  }

  Future<PublicDetailsResponse> getPublicDetails() async {
    return _makeGetRequest<PublicDetailsResponse>(
      'public/details',
      null,
      null,
      (json) => PublicDetailsResponse.fromJson(json),
      null,
    );
  }

  Future<bool> getCouponListVisibility() async {
    return _makeGetRequest<bool>(
      'store/web/global_settings',
      null,
      null,
      (json) {
        final value = json['globalSettings']?['coupon_list_enabled'];

        if (value is bool) {
          return value;
        }

        if (value is String) {
          final normalized = value.trim().toLowerCase();
          if (['false', '0', 'off', 'no'].contains(normalized)) {
            return false;
          }
          if (['true', '1', 'on', 'yes'].contains(normalized)) {
            return true;
          }
        }

        return true;
      },
      null,
    );
  }

  Future<dynamic> uploadImage(BuildContext context, File file) async {
    await addToken();
    return _uploadFile(
      file: file,
      apiUrl: 'store/uploads',
      fromJson: (json) => json, // Return the response as JSON
      context: context,
    );
  }

  Future<NeftTransactionResponse> getNEFTTransaction(
      BuildContext context, String? orderID) async {
    await addToken();
    return _makeGetRequest<NeftTransactionResponse>(
      'store/neft-payment-images',
      orderID,
      null,
      (json) => NeftTransactionResponse.fromJson(json),
      null,
    );
  }

  Future<dynamic> submitNEFTTransaction(
      BuildContext context, Map<String, dynamic> payload) async {
    await addToken();
    return _makePostRequest(
      '/store/neft-payment-images',
      payload,
      (json) => ProductInfoResponse.fromJson(json),
      context,
    );
  }

  Future<StoreContentResponse> getStoreContent(BuildContext context) async {
    return _makeGetRequest<StoreContentResponse>(
      '/store/content',
      null,
      null,
      (json) => StoreContentResponse.fromJson(json),
      null,
    );
  }

  Future<CollectionsResponse> listCollections(BuildContext context) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');

    return _makeGetRequest<CollectionsResponse>(
      'store/collections',
      null,
      null,
      (json) => CollectionsResponse.fromJson(json),
      context,
    );
  }

  Future<FilterCategoryResponse> listCategories(BuildContext context) async {
    return _makeGetRequest<FilterCategoryResponse>(
      'store/product-custom-categories',
      null,
      null,
      (json) => FilterCategoryResponse.fromJson(json),
      context,
    );
  }

  Future<TagsResponse> listTags(BuildContext context) async {
    return _makeGetRequest<TagsResponse>(
      'store/product-tags',
      '?fields=id,value',
      null,
      (json) => TagsResponse.fromJson(json),
      context,
    );
  }

  Future<RelatedProductsResponse> relatedProducts(
      BuildContext context, String productId) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makePostRequest<RelatedProductsResponse>(
      'store/related-product/$productId',
      {"region_id": regionId},
      (json) => RelatedProductsResponse.fromJson(json),
      context,
    );
  }

  Future<CrossSellProductsResponse> crossSellingProducts(
      BuildContext context, String cartId) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makePostRequest<CrossSellProductsResponse>(
      'store/cross-selling-product/$cartId',
      {"region_id": regionId},
      (json) => CrossSellProductsResponse.fromJson(json),
      context,
    );
  }

  Future<UpSellProductsResponse> upSellingProducts(
      BuildContext context, String id) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makePostRequest<UpSellProductsResponse>(
      'store/up-selling-product/$id',
      {"region_id": regionId},
      (json) => UpSellProductsResponse.fromJson(json),
      context,
    );
  }

  Future<AddOnProductsResponse> addOnProducts(
      BuildContext context, String productId) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makePostRequest<AddOnProductsResponse>(
      'store/addon-product/$productId',
      {"region_id": regionId},
      (json) => AddOnProductsResponse.fromJson(json),
      context,
    );
  }

  Future<OrderHistoryIndividualReponse> getIndividualOrderHistory(
      BuildContext context, String orderId) async {
    await addToken();
    return _makeGetRequest<OrderHistoryIndividualReponse>(
      'store/orders/$orderId?fields=+subtotal,+tax_total,+total,+payment_collections.payments.*,+cart.shipping_address.*,+metadata',
      null,
      null,
      (json) => OrderHistoryIndividualReponse.fromJson(json),
      context,
    );
  }

  Future<RegisterResponse> deleteAccount(BuildContext context) async {
    await addToken();
    return _makeDeleteRequest("store/customers/delete", null, null,
        (data) => RegisterResponse.fromJson(data), context);
  }

  Future<CancelOrderResponse> cancelOrder(
      BuildContext context, String orderId) async {
    await addToken();
    return _makePostRequest('store/cancel-order/$orderId', null,
        (data) => CancelOrderResponse.fromJson(data), context);
  }

  Future<OrderDetailResponse> getOrderDetails(
      BuildContext context, String orderId) async {
    await addToken();
    return _makeGetRequest<OrderDetailResponse>(
      'store/order/details/$orderId',
      null,
      null,
      (json) => OrderDetailResponse.fromJson(json),
      context,
    );
  }

  Future<ReturnResponse> getReturnReasons(BuildContext context) async {
    return _makeGetRequest<ReturnResponse>(
      'store/return-reasons',
      null,
      null,
      (json) => ReturnResponse.fromJson(json),
      context,
    );
  }

  Future<ReturnSuccessResponse> processReturn(
      BuildContext context,
      String orderId,
      String cartId,
      String id,
      int quantity,
      String reasonId,
      String note,
      String fullFillId) async {
    return _makePostRequest(
        "store/order/return/$orderId",
        {
          "return_item": {
            "id": id,
            "quantity": quantity,
            "reason_id": reasonId,
            "note": note
          },
          "fulfillment_id": fullFillId,
          "cart_id": cartId
        },
        (data) => ReturnSuccessResponse.fromJson(data),
        context);
  }

  Future<void> addToken() async {
    _dio.options.headers['Authorization'] =
        'Bearer ${await SharedPreferencesUtil().getString('token')}';
  }

  Future<void> setPublishableKey() async {
    String? publishableKey =
        await SharedPreferencesUtil().getString('publishable_key');
    _dio.options.headers["x-publishable-api-key"] = publishableKey ?? "";
  }

  Future<VerifyOtpResponse> loginWithEmail(
      BuildContext context, String email, String password) async {
    String? deviceId = await _updateToken();
    final response = await _makePostRequest(
        "store/customers/email-login",
        {"device_id": deviceId, "email": email, "password": password},
        (data) => VerifyOtpResponse.fromJson(data),
        context);
    await AppErrorReporter.instance.addBreadcrumb(
      'customer_login',
      attributes: {
        'auth_type': 'email',
        'new_user': response.newUser ?? false,
      },
    );
    return response;
  }

  // ==================== WALLET ====================

  Future<WalletResponse> getWalletBalance(BuildContext context) async {
    await addToken();
    return _makeGetRequest("store/wallet", null, null,
        (data) => WalletResponse.fromJson(data), context);
  }

  Future<WalletTransactionsResponse> getWalletTransactions(BuildContext context,
      {int limit = 20, int offset = 0, String? type, String? direction}) async {
    await addToken();
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (type != null) params['type'] = type;
    if (direction != null) params['direction'] = direction;

    return _makeGetRequest("store/wallet/transactions", null, params,
        (data) => WalletTransactionsResponse.fromJson(data), context);
  }

  Future<WalletTopUpResponse> initiateWalletTopUp(
      BuildContext context, double amount,
      {String currencyCode = 'inr'}) async {
    await addToken();
    return _makePostRequest(
        "store/wallet/top-up",
        {
          "amount": amount,
          "currency_code": currencyCode,
        },
        (data) => WalletTopUpResponse.fromJson(data),
        context);
  }

  Future<WalletConfirmResponse> confirmWalletTopUp(
      BuildContext context, String razorpayPaymentId, double amount,
      {String currencyCode = 'inr'}) async {
    await addToken();
    return _makePostRequest(
        "store/wallet/top-up/confirm",
        {
          "razorpay_payment_id": razorpayPaymentId,
          "amount": amount,
          "currency_code": currencyCode,
        },
        (data) => WalletConfirmResponse.fromJson(data),
        context);
  }

  Future<WalletSplitResponse> applyWalletSplit(
      BuildContext context, String cartId) async {
    await addToken();
    return _makePostRequest("store/wallet/apply-split", {"cart_id": cartId},
        (data) => WalletSplitResponse.fromJson(data), context);
  }

  Future<dynamic> removeWalletSplit(BuildContext context, String cartId) async {
    await addToken();
    await setPublishableKey();
    try {
      final response = await _dio.delete(
        "store/wallet/apply-split",
        queryParameters: {"cart_id": cartId},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.data ?? {};
    } catch (e) {
      debugPrint('removeWalletSplit error: $e');
      rethrow;
    }
  }

  // ─── Loyalty ──────────────────────────────────────────────

  Future<Response> getLoyaltyAccount() async {
    await addToken();
    await setPublishableKey();
    return _dio.get('/store/loyalty');
  }

  Future<Response> getLoyaltyTransactions({int limit = 20, int offset = 0}) async {
    await addToken();
    await setPublishableKey();
    return _dio.get('/store/loyalty/transactions',
        queryParameters: {'limit': limit, 'offset': offset});
  }

  Future<Response> getLoyaltyPreview(
    num orderTotal, {
    String? orderId,
    String? cartId,
    String? productId,
  }) async {
    await setPublishableKey();
    final params = <String, dynamic>{};
    if (orderId != null && orderId.isNotEmpty) params['order_id'] = orderId;
    // Prefer cart_id when available — backend computes earnable amount server-side
    // (excludes platform_fee + applies earn restriction).
    if (cartId != null && cartId.isNotEmpty) params['cart_id'] = cartId;
    // PDP passes product_id so backend can short-circuit when the merchant
    // has restricted earning to specific products / categories — keeps the
    // "you'll earn …" strip honest with what the order subscriber will do.
    if (productId != null && productId.isNotEmpty) params['product_id'] = productId;
    if (orderTotal > 0) params['order_total'] = orderTotal;
    return _dio.get('/store/loyalty/preview', queryParameters: params);
  }

  Future<Response> redeemLoyaltyPoints(int points) async {
    await addToken();
    await setPublishableKey();
    return _dio.post('/store/loyalty/redeem', data: {'points': points});
  }

  Future<Response> applyLoyaltyCheckout(String cartId, int points) async {
    await addToken();
    await setPublishableKey();
    return _dio.post('/store/loyalty/checkout-apply',
        data: {'cart_id': cartId, 'points': points});
  }

  Future<Response> getLoyaltyCheckoutStatus(String cartId) async {
    await addToken();
    await setPublishableKey();
    return _dio.get('/store/loyalty/checkout-apply',
        queryParameters: {'cart_id': cartId});
  }

  Future<Response> removeLoyaltyCheckout(String cartId) async {
    await addToken();
    await setPublishableKey();
    return _dio.delete('/store/loyalty/checkout-apply',
        data: {'cart_id': cartId});
  }

  Future<Response> getLoyaltyReferral() async {
    await addToken();
    await setPublishableKey();
    return _dio.get('/store/loyalty/referral');
  }

  Future<Response> getLoyaltyReferralHistory({int limit = 20, int offset = 0}) async {
    await addToken();
    await setPublishableKey();
    return _dio.get('/store/loyalty/referral/history',
        queryParameters: {'limit': limit, 'offset': offset});
  }

  Future<Response> applyReferralCode(String identifier) async {
    await addToken();
    await setPublishableKey();
    // Send via `referral_identifier` (new) — backend accepts unique code OR phone.
    return _dio.post('/store/loyalty/referral/apply',
        data: {'referral_identifier': identifier.trim()});
  }

  /// Public endpoint — no auth required. Accepts EITHER a unique code OR a
  /// phone number (when admin has enabled phone-as-referral mode).
  Future<Response> validateReferralCode(String identifier) async {
    await setPublishableKey();
    final raw = identifier.trim();
    // Pass via the new `identifier` param. Backend uppercases code lookups
    // internally and tries phone matching when the input has enough digits.
    return _dio.get('/store/loyalty/referral/validate',
        queryParameters: {'identifier': raw});
  }

  // GET /store/delivery/free-delivery-info — cart-scoped progress banner data.
  // Returns null on any failure so the widget hides silently rather than
  // breaking the cart UI.
  Future<Map<String, dynamic>?> getFreeDeliveryInfo(
    BuildContext context,
    String cartId,
  ) async {
    try {
      await addToken();
      return _makeGetRequest<Map<String, dynamic>>(
        'store/delivery/free-delivery-info',
        null,
        {'cart_id': cartId},
        (json) => Map<String, dynamic>.from(json as Map),
        context,
      );
    } catch (_) {
      return null;
    }
  }
}
