class ApiEndpoints {
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // Account Endpoints
  static const String accountBalance = '/account/balance';
  static const String accountDetails = '/account/details';
  static const String transactionHistory = '/account/transactions';

  // Transfer Endpoints
  static const String transfer = '/transfer';
  static const String verifyAccount = '/transfer/verify-account';

  // Airtime Endpoints
  static const String purchaseAirtime = '/airtime/purchase';

  // Bills Endpoints
  static const String payBills = '/bills/pay';
  static const String getBillCategories = '/bills/categories';

  // zAI Endpoints
  static const String zaiChat = '/zai/chat';
  static const String zaiHistory = '/zai/history';
}

