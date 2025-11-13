import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class ApiClient {
  late Dio _dio;
  final GetStorage _storage = GetStorage();

  ApiClient() {
    // Try to get BASE_URL from environment, fallback to constant
    String baseUrl;
    try {
      baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
    } catch (e) {
      // If dotenv is not loaded, use constant
      baseUrl = AppConstants.baseUrl;
    }
    // Append /api to base URL for all endpoints
    final apiBaseUrl = baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token and redirect to login
            _storage.remove(AppConstants.tokenKey);
            _storage.remove(AppConstants.isLoggedInKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      // Handle Dio-specific errors gracefully
      if (e.response != null) {
        // Server responded with error status
        throw ApiException(
          message: e.response?.data['message'] ??
              e.response?.data['error'] ??
              'An error occurred',
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data,
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 0,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );
      } else {
        throw ApiException(
          message: 'An unexpected error occurred: ${e.message}',
          statusCode: 0,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
