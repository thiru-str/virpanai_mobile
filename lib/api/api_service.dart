import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/address_list_response.dart';
import 'package:waioz/model/collection_response.dart';
import 'package:waioz/model/duplicate_response_model.dart';
import 'package:waioz/model/filter_category_response.dart';
import 'package:waioz/model/related_products_response.dart';
import 'package:waioz/model/store_content_response.dart';
import 'package:waioz/model/customer_response.dart';
import 'package:waioz/model/delete_response.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/model/neft_transaction_response.dart';
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
import 'package:waioz/model/verify_otp_response.dart';
import 'package:waioz/model/wishlist_reponse.dart';
import 'package:waioz/ui/cart_response.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_logger.dart';
import 'package:waioz/utility/page_route_utils.dart';
import '../model/order_history_individual_reponse.dart';
import '../model/pin_code_response.dart';
import '../model/refresh_token_response.dart';
import '../utility/app_utils.dart';
import '../utility/shared_preferences_util.dart';
import 'package:waioz/model/check_out_shipping_address_model.dart' as CheckOut;

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Configure Dio
    _dio.options.baseUrl = AppConfig.baseUrl;
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
      await setPublishableKey();

      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$endpoint');
      AppLogger.print('API Params:', '${data ?? {}}');

      final response = await _dio.post(endpoint, data: data ?? {},options: Options(
        validateStatus: (status) {
          // Accept status codes 400-499 as valid responses for handling errors manually
          return status != null && status < 500;
        },
      ));
      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 401) {
        await _handleLogout(context, response.data['error']);
        throw Exception('Unauthorized: ${response.data['error']}');
      } else {
        AppLogger.print('error message:', response.data['message'] ??'');
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
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
      BuildContext? context) async {
    try {
      await setPublishableKey();
      // Combine endpoint and dynamic path
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath'
          : endpoint;

      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.print('API Params:', '${queryParams ?? {}}');

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
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 400) {
        AppUtils.showToast(response.data['message'] ?? 'An error occurred');
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else if (response.statusCode == 401) {
        await _handleLogout(context!, response.data['error']);
        throw Exception('Unauthorized: ${response.data['error']}');
      }  else {
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
      await setPublishableKey();
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath' // Append dynamic path if provided
          : endpoint;
      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.print('API Params:', '${queryParams ?? {}}');

      // Make the DELETE request
      final response =
          await _dio.delete(fullEndpoint, data: queryParams,options: Options(
            validateStatus: (status) {
              // Accept status codes 400-499 as valid responses for handling errors manually
              return status != null && status < 500;
            },
          ));

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

  Future<T> _uploadFile<T>({
    required File file,
    required String apiUrl,
    required T Function(Map<String, dynamic>) fromJson,
    required BuildContext context,
  }) async {
    try {
      // Prepare FormData with the image file
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
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

  Future<SendOtpResponse> sendOtp(BuildContext context, String countryCode,String phone) async {
    return _makePostRequest("store/customers/send-otp", {"country_code":countryCode,"phone": phone},
        (data) => SendOtpResponse.fromJson(data), context);
  }

  Future<VerifyOtpResponse> verifyOtp(
      BuildContext context,String countryCode,String phone, String otp) async {
    String? deviceToken = await _updateToken();
    return _makePostRequest(
        "store/customers/verify-otp",
        {"device_id": deviceToken,"country_code":countryCode,"phone": phone, "otp": otp},
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
    String uploadedToken = await SharedPreferencesUtil().getString('fcm_token_uploaded') ?? '';

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
      String token,String shopName,String state,String city,String postalCode,bool isGST,String gstNo,String gstImage,String shopNameBoardImage,String shopInteriorImage,String shopCounterImage) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    String? deviceId = await SharedPreferencesUtil().getString('fcm_token');
    return _makePostRequest(
        "store/customers",
        {
          "email": email,
          "company_name": shopName,
          "first_name": firstName,
          "last_name": lastName,
          "phone": phone,
          "metadata": {
            "country_code":countryCode,
            "device_id":deviceId,
            "shop_name":shopName,
            "country":"IN",
            "city":city,
            "state":state,
            "postal_code":postalCode,
            "is_gst":isGST,
            "gst_number":gstNo,
            "gst_image":gstImage,
            "shop_name_board_image":shopNameBoardImage,
            "shop_interior_image":shopInteriorImage,
            "shop_counter_image":shopCounterImage
          }
        },
        (data) => RegisterResponse.fromJson(data),
        context);
  }

  Future<RefreshTokenResponse> refreshToken(
      BuildContext context,
      String token,
      ) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    return _makePostRequest(
        "auth/token/refresh",
        null,
        (data) => RefreshTokenResponse.fromJson(data),
        context);
  }

  Future<ProductsResponse> listProducts(
      BuildContext context,
      String categoryId,
      String collectionId,
      String searchString, {
        int offset = 0,
        int limit = 10,
      }) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    final queryParams = <String, dynamic>{};

    if (regionId != null && regionId.isNotEmpty) {
      queryParams['region_id'] = regionId;
    }

    if (categoryId.trim().isNotEmpty) {
      final categories =
      categoryId.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (categories.isNotEmpty) {
        queryParams['category_id[]'] = categories;
      }
    }

    if (collectionId.trim().isNotEmpty) {
      final collections =
      collectionId.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (collections.isNotEmpty) {
        queryParams['collection_id[]'] = collections;
      }
    }


    if (searchString.isNotEmpty) {
      queryParams['q'] = searchString;
    }

    queryParams['offset'] = offset.toString();
    queryParams['limit'] = limit.toString();

    return _makeGetRequest<ProductsResponse>(
      'store/products',
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
      '$productId?fields=+variants.inventory_quantity',
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
    return _makePostRequest<HomePageResponse>(
      'store/get_home_page/v7',
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
      String addressName,
      String latitude,String longitude) async {
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
          "country_code" : "in",
          "metadata":{"latitude":latitude,"longitude":longitude}
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

  Future<CartResponse> addPromoCode(
      BuildContext context,String promoCode) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/carts/$cartId/promotions',
      {"promo_codes": [promoCode]},
          (json) => CartResponse.fromJson(json),
      context,
    );
  }

  Future<CartResponse> removePromoCode(
      BuildContext context,List<String> promoCodes) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makeDeleteRequest(
      'store/carts/$cartId/promotions', null,{"promo_codes": promoCodes},
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
      {"shipping_address": address,"billing_address": address},
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

  Future<OrderHistoryIndividualReponse> getIndividualOrderHistory(BuildContext context,String orderId) async {
    await addToken();
    return _makeGetRequest<OrderHistoryIndividualReponse>(
      'store/orders/$orderId?fields=+subtotal,+tax_total,+total,+payment_collections.payments.*,+cart.shipping_address.*,',
      null,
      null,
          (json) => OrderHistoryIndividualReponse.fromJson(json),
      context,
    );
  }

  Future<OrderHistoryResponse> getOrderHistory(BuildContext context) async {
    await addToken();
    return _makeGetRequest<OrderHistoryResponse>(
      'store/orders?fields=+subtotal,+tax_total,+total,+payment_collections.payments.*,+cart.shipping_address.*,',
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

  Future<ShippingResponse> getShippingInfo(
      BuildContext context) async {
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

  Future<dynamic> updatePaymentMethod(
      BuildContext context, String paymentProviderId,CartResponse cartResponse) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/update-payment-method/$cartId',
      paymentProviderId == 'pp_razorpay_razorpay'?{"payment_provider_id": paymentProviderId,"context":{"extra":cartResponse.cart}}:{"payment_provider_id": paymentProviderId},
          (json) => json,
      context,
    );
  }

  Future<PlaceOrderResponse> completeCart(
      BuildContext context) async {
    await addToken();
    String? cartId = await SharedPreferencesUtil().getString('cart_id');
    return _makePostRequest(
      'store/carts/$cartId/complete',
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

  Future<dynamic> uploadImage(BuildContext context, File file) async {
    await addToken();
    return _uploadFile(
      file: file,
      apiUrl: 'store/uploads',
      fromJson: (json) => json, // Return the response as JSON
      context: context,
    );
  }

  Future<dynamic> uploadDocImages(BuildContext context,String token, File file) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    return _uploadFile(
      file: file,
      apiUrl: 'store/uploads',
      fromJson: (json) => json, // Return the response as JSON
      context: context,
    );
  }

  Future<NeftTransactionResponse> getNEFTTransaction(BuildContext context, String? orderID) async {
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
      'store/content',
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

  Future<FilterCategoryResponse> listCategories(BuildContext context, String parentId) async {
    return _makeGetRequest<FilterCategoryResponse>(
      'store/product-categories',
      null,
      {
        "parent_category_id": parentId,
      },
          (json) => FilterCategoryResponse.fromJson(json),
      context,
    );
  }

  Future<RelatedProductsResponse> relatedProducts(
      BuildContext context, String productId) async {
    String? regionId = await SharedPreferencesUtil().getString('region_id');
    return _makePostRequest<RelatedProductsResponse>(
      'store/related-product/${productId}',
      {"region_id": regionId},
          (json) => RelatedProductsResponse.fromJson(json),
      context,
    );
  }

  Future<PinCodeResponse> pinCodeCheck(BuildContext context, String pinCode) async {
    return _makePostRequest('public/pincode-list', {"pincode":pinCode},
            (data) => PinCodeResponse.fromJson(data), context);
  }

  Future<DuplicateResponse> checkDuplicate(BuildContext context,String email,String phone) async {
    return _makePostRequest('store/customers/check-duplicate', {"email":email,"phone":phone},
            (data) => DuplicateResponse.fromJson(data),context);
  }

  Future<void> addToken() async {
    _dio.options.headers['Authorization'] =
        'Bearer ${await SharedPreferencesUtil().getString('token')}';
  }

  Future<void> setPublishableKey() async {
    String? publishableKey = await SharedPreferencesUtil().getString('publishable_key');
    _dio.options.headers["x-publishable-api-key"] = publishableKey ?? "";
  }


}
