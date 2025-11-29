import 'package:dio/dio.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  /// Get all users with filtering and pagination
  Future<ApiResponse<Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 20,
    String search = '',
    String subscriptionStatus = 'all',
    String accountStatus = 'all',
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/users',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
          'subscriptionStatus': subscriptionStatus,
          'accountStatus': accountStatus,
        },
      );

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get detailed information about a specific user
  Future<ApiResponse<Map<String, dynamic>>> getUserDetails(String userId) async {
    try {
      final response = await _apiService.get('/admin/users/$userId');
      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update user's account status
  Future<ApiResponse<Map<String, dynamic>>> updateAccountStatus({
    required String userId,
    required String accountStatus,
  }) async {
    try {
      final response = await _apiService.put(
        '/admin/users/$userId/account-status',
        data: {'account_status': accountStatus},
      );

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Deactivate user account
  Future<ApiResponse<Map<String, dynamic>>> deactivateAccount({
    required String userId,
    String? reason,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (reason != null) {
        data['reason'] = reason;
      }
      
      final response = await _apiService.post(
        '/admin/users/$userId/deactivate',
        data: data,
      );

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Activate user account
  Future<ApiResponse<Map<String, dynamic>>> activateAccount({
    required String userId,
  }) async {
    try {
      final response = await _apiService.post('/admin/users/$userId/activate');
      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get admin dashboard statistics
  Future<ApiResponse<Map<String, dynamic>>> getAdminStats() async {
    try {
      final response = await _apiService.get('/admin/stats');
      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Modify user subscription (extend or reduce)
  Future<ApiResponse<Map<String, dynamic>>> modifySubscription({
    required String userId,
    required int days,
    required bool isExtend,
  }) async {
    try {
      final response = await _apiService.post(
        '/admin/users/$userId/modify-subscription',
        data: {
          'days': days,
          'action': isExtend ? 'extend' : 'reduce',
        },
      );

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
