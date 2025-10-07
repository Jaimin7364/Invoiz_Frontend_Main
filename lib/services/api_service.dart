import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Getter for storage to be accessed by other services
  FlutterSecureStorage get storage => _storage;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('DIO: $object'),
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _storage.read(key: AppConfig.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: AppConfig.tokenKey);
            await _storage.delete(key: AppConfig.userKey);
            // You can add navigation to login screen here
          }
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Handle API response
  static ApiResponse<T> handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse.success(fromJson(data['data']));
        } else {
          return ApiResponse.error(data['message'] ?? 'Unknown error');
        }
      } else {
        return ApiResponse.error('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }

  // Handle API response for list
  static ApiResponse<List<T>> handleListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    String listKey,
  ) {
    try {
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data['success'] == true) {
          final list = (data['data'][listKey] as List)
              .map((item) => fromJson(item))
              .toList();
          return ApiResponse.success(list);
        } else {
          return ApiResponse.error(data['message'] ?? 'Unknown error');
        }
      } else {
        return ApiResponse.error('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }

  // Handle simple response (no data)
  static ApiResponse<bool> handleSimpleResponse(Response response) {
    try {
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse.success(true);
        } else {
          return ApiResponse.error(data['message'] ?? 'Unknown error');
        }
      } else {
        return ApiResponse.error('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }
}

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse.success(this.data, [this.message])
      : isSuccess = true,
        error = null;

  ApiResponse.error(this.error, [this.message])
      : isSuccess = false,
        data = null;

  bool get hasError => !isSuccess;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, [this.statusCode, this.data]);

  @override
  String toString() => 'ApiException: $message';

  static ApiException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Request failed';
        return ApiException(message, statusCode, error.response?.data);
      
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');
      
      case DioExceptionType.connectionError:
        return ApiException('No internet connection. Please check your network.');
      
      default:
        return ApiException('Something went wrong. Please try again.');
    }
  }
}