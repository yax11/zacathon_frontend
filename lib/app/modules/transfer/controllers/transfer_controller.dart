import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api/api_client.dart' show ApiClient, ApiException;
import '../../../data/services/api/api_endpoints.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_constants.dart';

class TransferController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ApiClient _apiClient = ApiClient();

  final isLoading = false.obs;
  final isVerifyingAccount = false.obs;
  final accounts = <AccountModel>[].obs;
  final verifiedAccountName = ''.obs;
  final verifiedBankName = ''.obs;
  final verifiedBankCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserAccounts();
  }

  Future<void> loadUserAccounts() async {
    try {
      isLoading.value = true;
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        accounts.value = user.accounts;
      }
    } catch (e) {
      print('Error loading user accounts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> verifyAccount({
    required String accountNumber,
  }) async {
    try {
      isVerifyingAccount.value = true;
      verifiedAccountName.value = '';
      verifiedBankName.value = '';
      verifiedBankCode.value = '';

      // Get user's phone number
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found. Please login again.',
        };
      }

      // Get base URL for logging
      String baseUrl;
      try {
        baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
      } catch (e) {
        baseUrl = AppConstants.baseUrl;
      }
      final apiBaseUrl = baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
      final fullUrl = '$apiBaseUrl${ApiEndpoints.accountVerification}';

      // Log API request
      print('=== Account Verification Request ===');
      print('Method: POST');
      print('Full URL: $fullUrl');
      print('Request Data: {phoneNumber: ${user.phoneNumber}, accountNumber: $accountNumber}');
      print('===================================');

      final response = await _apiClient.post(
        ApiEndpoints.accountVerification,
        data: {
          'phoneNumber': user.phoneNumber,
          'accountNumber': accountNumber,
        },
      );

      // Log API response
      print('=== Account Verification Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('====================================');

      if (response.statusCode == 200) {
        final data = response.data;
        final success = data['success'] ?? false;

        if (success && data['data'] != null) {
          final accountData = data['data'];
          verifiedAccountName.value = accountData['account_name'] ?? '';
          verifiedBankName.value = accountData['bank_name'] ?? '';
          verifiedBankCode.value = accountData['bank_code'] ?? '';

          return {
            'success': true,
            'accountName': verifiedAccountName.value,
            'bankName': verifiedBankName.value,
            'bankCode': verifiedBankCode.value,
            'message': data['ai_message'] ?? 'Account verified',
          };
        }
      }

      // Clear verified account on failure
      clearVerifiedAccount();
      return {
        'success': false,
        'message': 'Account verification failed',
      };
    } on ApiException catch (e) {
      print('=== Account Verification Exception ===');
      print('Message: ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('=====================================');
      // Clear verified account on exception
      clearVerifiedAccount();
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      print('=== Account Verification Error ===');
      print('Error: ${e.toString()}');
      print('==================================');
      // Clear verified account on error
      clearVerifiedAccount();
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    } finally {
      isVerifyingAccount.value = false;
    }
  }

  Future<Map<String, dynamic>> manualTransfer({
    required String sourceAccountNumber,
    required String receiverAccountNumber,
    required String amount,
  }) async {
    try {
      isLoading.value = true;

      // Get user's phone number
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found. Please login again.',
        };
      }

      // Get base URL for logging
      String baseUrl;
      try {
        baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
      } catch (e) {
        baseUrl = AppConstants.baseUrl;
      }
      final apiBaseUrl = baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
      final fullUrl = '$apiBaseUrl${ApiEndpoints.manualTransfer}';

      // Log API request
      print('=== Manual Transfer Request ===');
      print('Method: POST');
      print('Full URL: $fullUrl');
      print('Request Data: {phoneNumber: ${user.phoneNumber}, sourceAccountNumber: $sourceAccountNumber, receiverAccountNumber: $receiverAccountNumber, amount: $amount}');
      print('==============================');

      final response = await _apiClient.post(
        ApiEndpoints.manualTransfer,
        data: {
          'phoneNumber': user.phoneNumber,
          'sourceAccountNumber': sourceAccountNumber,
          'receiverAccountNumber': receiverAccountNumber,
          'amount': double.parse(amount),
        },
      );

      // Log API response
      print('=== Manual Transfer Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('================================');

      if (response.statusCode == 200) {
        final data = response.data;
        final success = data['success'] ?? false;

        if (success) {
          return {
            'success': true,
            'message': data['response'] ?? data['message'] ?? 'Transfer initiated',
            'transactionId': data['transactionId'],
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? response.data['error'] ?? 'Transfer initiation failed',
      };
    } on ApiException catch (e) {
      print('=== Manual Transfer Exception ===');
      print('Message: ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('=================================');
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      print('=== Manual Transfer Error ===');
      print('Error: ${e.toString()}');
      print('============================');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> verifyTransaction({
    required String transactionId,
    required String pin,
  }) async {
    try {
      isLoading.value = true;

      // Get user's phone number
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found. Please login again.',
        };
      }

      // Get base URL for logging
      String baseUrl;
      try {
        baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
      } catch (e) {
        baseUrl = AppConstants.baseUrl;
      }
      final apiBaseUrl = baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
      final fullUrl = '$apiBaseUrl${ApiEndpoints.verifyTransaction}';

      // Log API request
      print('=== Verify Transaction Request ===');
      print('Method: POST');
      print('Full URL: $fullUrl');
      print('Request Data: {phoneNumber: ${user.phoneNumber}, transactionId: $transactionId, pin: ***}');
      print('==================================');

      final response = await _apiClient.post(
        ApiEndpoints.verifyTransaction,
        data: {
          'phoneNumber': user.phoneNumber,
          'transactionId': transactionId,
          'pin': pin,
        },
      );

      // Log API response
      print('=== Verify Transaction Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('===================================');

      if (response.statusCode == 200) {
        final data = response.data;
        final success = data['success'] ?? false;

        if (success) {
          return {
            'success': true,
            'message': data['response'] ?? data['message'] ?? 'Transaction verified successfully',
          };
        }
      }

      // Handle 404 or other errors
      final errorMessage = response.data['message'] ?? 
                          response.data['error'] ?? 
                          'Transaction verification failed';
      
      return {
        'success': false,
        'message': errorMessage,
        'isExpired': response.statusCode == 404 || errorMessage.toLowerCase().contains('expired'),
      };
    } on ApiException catch (e) {
      print('=== Verify Transaction Exception ===');
      print('Message: ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('====================================');
      return {
        'success': false,
        'message': e.message,
        'isExpired': e.statusCode == 404 || e.message.toLowerCase().contains('expired'),
      };
    } catch (e) {
      print('=== Verify Transaction Error ===');
      print('Error: ${e.toString()}');
      print('================================');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    } finally {
      isLoading.value = false;
    }
  }

  void clearVerifiedAccount() {
    verifiedAccountName.value = '';
    verifiedBankName.value = '';
    verifiedBankCode.value = '';
  }
}

