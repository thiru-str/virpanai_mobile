class AppConstant {
  static const String baseUrl = "https://cartel.waioz.com/";
  static const String x_publishable_api_key =
      "pk_c75b5817e2d0fbd95c46472e3deaccda6cddb11bc8a6c0fccb056a5f2c9211cb";

// api-end-points
  static const String sendOTP = "store/customers/send-otp";
  static const String verifyOTP = "store/customers/verify-otp";
  static const String register = "store/customers";
  static const String products = "store/products";
  static const String product_categories = 'store/product-custom-categories';
  static const String getCustomer = 'store/customers/me';
  static const String getHomePage = 'store/get_home_page/v1';
  static const String customer_Address = "store/customers/me/addresses";
  static const String getAddressList =
      'store/customers/me/addresses?fields=+address_name';
  static const String product_review = 'store/product-reviews';
  static const String product_wishList = 'store/product-wishlist';
  static const String cart = "store/carts";
}



// line no 310
// "store/customers/me/addresses/$addressID"