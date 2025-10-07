import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Register user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'mobile_number': mobileNumber,
          'password': password,
        },
      );

      return ApiService.handleResponse(
        response,
        (data) => data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Verify OTP
  Future<ApiResponse<User>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data['success'] == true) {
          // Save token and user data
          final token = data['data']['token'];
          await _storageService.saveToken(token);
          
          // Return user data
          final user = User.fromJson(data['data']['user']);
          await _storageService.saveUser(user);
          
          return ApiResponse.success(user);
        } else {
          return ApiResponse.error(data['message'] ?? 'OTP verification failed');
        }
      } else {
        return ApiResponse.error('Request failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Resend OTP
  Future<ApiResponse<bool>> resendOTP({required String email}) async {
    try {
      final response = await _apiService.post(
        '/auth/resend-otp',
        data: {'email': email},
      );

      return ApiService.handleSimpleResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Login user
  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data['success'] == true) {
          // Save token and user data
          final token = data['data']['token'];
          await _storageService.saveToken(token);
          
          // Return user data
          final user = User.fromJson(data['data']['user']);
          await _storageService.saveUser(user);
          
          return ApiResponse.success(user);
        } else {
          return ApiResponse.error(data['message'] ?? 'Login failed');
        }
      } else {
        return ApiResponse.error('Request failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Get current user
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');

      return ApiService.handleResponse(
        response,
        (data) => User.fromJson(data['user']),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

    // Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiService.post('/auth/logout');
      
      // Clear stored data regardless of API response
      await _storageService.clearUserData();
      
      return ApiService.handleSimpleResponse(response);
    } on DioException catch (e) {
      // Clear stored data even if logout fails
      await _storageService.clearUserData();
      
      throw ApiException.fromDioError(e);
    }
  }

  // Register business
  Future<ApiResponse<Map<String, dynamic>>> registerBusiness(Map<String, dynamic> businessData) async {
    try {
      final response = await _apiService.post('/business/register', data: businessData);
      
      return ApiResponse.success(
        response.data['data'] as Map<String, dynamic>,
        response.data['message'] as String?,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  // Get stored user
  Future<User?> getStoredUser() async {
    return await _storageService.getUser();
  }

  // Clear all stored data
  Future<void> clearStoredData() async {
    await _storageService.clearUserData();
  }
}