class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://admin.erb-roastery-bakery.com/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String oauthLogin = '/auth/oauth/login'; // ✅ add this
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword =
      '/auth/reset-password'; // ✅ confirm with backend

  static const String sendVerification = '/auth/send-verification';
  static const String verifyOtp = '/auth/verify-phone';

  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String categories = '/categories';
  static const String featured = '/products/featured';

  // Account
  static const String profile = '/account/profile';

  // Offers
  static const String activeOffers = '/offers/active'; // 👈 Add this

  static const String myOrders = '/orders/my-orders';

  static const String userLoyalty = '/users/loyalty'; // ✅ Loyalty endpoint

  // Favorites endpoints
  static const String getFavorites = '/users/favorites';
  static const String addToFavorites = '/users/favorites';
  static const String removeFromFavorites =
      '/users/favorites'; // + /{productId}

  static const String updateProfile = '/users/profile';

//User Addresses
  static const String addresses = '/users/addresses';
  static String deleteAddress(String id) => '/users/addresses/$id';
  static String updateAddress(String id) => '/users/addresses/$id';

  //Payment Card
  static const String paymentMethods = '/payment-methods';
  static String deleteCard(String id) => '/payment-methods/$id';
  static String setDefaultCard(String id) => '/payment-methods/$id/set-default';

  static const String validateCoupon = '/coupons/validate';

  //NOTIFICATIONS
  static const String registerDeviceToken = '/notifications/register-token';
  static const String unregisterDeviceToken =
      '/notifications/unregister-token'; // same path,
}
