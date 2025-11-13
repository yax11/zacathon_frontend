class AppConstants {
  // API Configuration
  static const String baseUrl =
      'https://personalize-production-8a33.up.railway.app'; // Default fallback URL
  static const String apiVersion = '/api/v1';
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String isLoggedInKey = 'is_logged_in';

  // App Information
  static const String appName = 'Zenith AI';
  static const String appVersion = '1.0.0';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;

  // Currency
  static const String currency = '₦';
  static const String currencyCode = 'NGN';
}
