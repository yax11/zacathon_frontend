import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import 'package:get_storage/get_storage.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final GetStorage _storage = GetStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
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
        'message': response.data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
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

  UserModel? getCurrentUser() {
    final userData = _storage.read(AppConstants.userKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}

