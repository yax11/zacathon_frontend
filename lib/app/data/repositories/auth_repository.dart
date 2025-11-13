import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../models/user_model.dart';
import '../services/local/secure_storage_service.dart';
import '../../core/constants/app_constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final GetStorage _storage = GetStorage();
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Validates phone number and logs in user
  /// accountNumber: 11-digit account number (e.g., "08012345678")
  /// password: Must be "123456"
  Future<Map<String, dynamic>> login({
    required String accountNumber,
    required String password,
  }) async {
    try {
      // Validate password
      if (password != '123456') {
        return {
          'success': false,
          'message': 'Invalid password',
        };
      }

      // Transform account number: remove first digit and prepend "+234"
      // Input: "08012345678" -> Output: "+2348012345678"
      if (accountNumber.length != 11) {
        return {
          'success': false,
          'message': 'Account number must be 11 digits',
        };
      }

      final phoneNumber = '+234${accountNumber.substring(1)}';

      // Get base URL for logging
      String baseUrl;
      try {
        baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
      } catch (e) {
        baseUrl = AppConstants.baseUrl;
      }
      // Append /api to base URL for logging
      final apiBaseUrl =
          baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
      final fullUrl = '$apiBaseUrl${ApiEndpoints.validatePhoneNumber}';
      final requestData = {'phoneNumber': phoneNumber};

      // Log API request to console
      print('=== API Request ===');
      print('Method: POST');
      print('Full URL: $fullUrl');
      print('Request Data: $requestData');
      print('==================');

      // Call validate-phone-number endpoint
      final response = await _apiClient.post(
        ApiEndpoints.validatePhoneNumber,
        data: requestData,
      );

      // Log API response to console
      print('=== API Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('===================');

      if (response.statusCode == 200) {
        final data = response.data;
        final success = data['success'] ?? false;
        final responseMessage = data['response'] ?? '';
        final userData = data['data'];

        if (success && responseMessage == 'User found' && userData != null) {
          // Parse user data
          final user = UserModel.fromJson(userData);

          // Save user data to secure storage
          await _secureStorage.saveUserData(userData);

          // Save account number (11 digits) for prefilling
          await _secureStorage.saveAccountNumber(accountNumber);

          // Also save to regular storage for backward compatibility
          await _storage.write(AppConstants.userKey, user.toJson());
          await _storage.write(AppConstants.isLoggedInKey, true);

          return {
            'success': true,
            'user': user,
            'message': 'Login successful',
          };
        } else {
          return {
            'success': false,
            'message':
                responseMessage.isNotEmpty ? responseMessage : 'User not found',
          };
        }
      }

      return {
        'success': false,
        'message': 'Login failed. Please try again.',
      };
    } on ApiException catch (e) {
      // Log API exception to console
      print('=== API Exception ===');
      print('Message: ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('Data: ${e.data}');
      print('====================');
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      // Log general exception to console
      print('=== General Exception ===');
      print('Error: ${e.toString()}');
      print('Stack Trace: ${StackTrace.current}');
      print('========================');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Get saved account number for prefilling
  Future<String?> getSavedAccountNumber() async {
    try {
      return await _secureStorage.getAccountNumber();
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['token'] ?? data['access_token'];
        final user = UserModel.fromJson(data['user'] ?? data);

        // Save token and user data
        await _storage.write(AppConstants.tokenKey, token);
        await _storage.write(AppConstants.userKey, user.toJson());
        await _storage.write(AppConstants.isLoggedInKey, true);

        return {
          'success': true,
          'token': token,
          'user': user,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear secure storage
      await _secureStorage.clearAll();

      // Clear regular storage
      await _storage.remove(AppConstants.tokenKey);
      await _storage.remove(AppConstants.userKey);
      await _storage.remove(AppConstants.isLoggedInKey);
    }
  }

  bool isLoggedIn() {
    return _storage.read(AppConstants.isLoggedInKey) ?? false;
  }

  String? getToken() {
    return _storage.read(AppConstants.tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // Try to get from secure storage first
      final secureUserData = await _secureStorage.getUserData();
      if (secureUserData != null) {
        return UserModel.fromJson(secureUserData);
      }

      // Fallback to regular storage
      final userData = _storage.read(AppConstants.userKey);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshUserData() async {
    try {
      final accountNumber = await getSavedAccountNumber();
      if (accountNumber == null || accountNumber.length != 11) {
        return;
      }

      final phoneNumber = '+234${accountNumber.substring(1)}';

      String baseUrl;
      try {
        baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
      } catch (e) {
        baseUrl = AppConstants.baseUrl;
      }
      final apiBaseUrl =
          baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
      final fullUrl = '$apiBaseUrl${ApiEndpoints.validatePhoneNumber}';
      final requestData = {'phoneNumber': phoneNumber};

      final response = await _apiClient.post(
        ApiEndpoints.validatePhoneNumber,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final success = data['success'] ?? false;
        final responseMessage = data['response'] ?? '';
        final userData = data['data'];

        if (success && responseMessage == 'User found' && userData != null) {
          await _secureStorage.saveUserData(userData);
          await _storage.write(AppConstants.userKey, userData);
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }
}
