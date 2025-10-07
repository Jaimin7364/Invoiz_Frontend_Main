import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  bool get hasActiveSubscription => _user?.hasActiveSubscription ?? false;
  bool get isSubscriptionExpired => _user?.isSubscriptionExpired ?? true;

  // Initialize provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _storageService.initialize();
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _authService.getStoredUser();
        if (_user != null) {
          // Refresh user data from server
          await getCurrentUser();
        }
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    }
    _setLoading(false);
  }

  // Register user
  Future<bool> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        fullName: fullName,
        email: email,
        mobileNumber: mobileNumber,
        password: password,
      );

      if (response.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.verifyOTP(
        email: email,
        otp: otp,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        _isLoggedIn = true;
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'OTP verification failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Resend OTP
  Future<bool> resendOTP({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.resendOTP(email: email);

      if (response.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to resend OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to resend OTP: $e');
      _setLoading(false);
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        _isLoggedIn = true;
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Get current user
  Future<void> getCurrentUser() async {
    if (!_isLoggedIn) return;

    try {
      final response = await _authService.getCurrentUser();
      if (response.isSuccess && response.data != null) {
        _user = response.data;
        await _storageService.saveUser(_user!);
        notifyListeners();
      }
    } catch (e) {
      print('Failed to get current user: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      print('Logout error: $e');
    }
    
    _user = null;
    _isLoggedIn = false;
    await _authService.clearStoredData();
    notifyListeners();
    _setLoading(false);
  }

  // Update user data
  void updateUser(User updatedUser) {
    _user = updatedUser;
    _storageService.saveUser(updatedUser);
    notifyListeners();
  }

  // Check subscription status
  bool requiresSubscription() {
    return !hasActiveSubscription;
  }

  // Register business
  Future<bool> registerBusiness(Map<String, dynamic> businessData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.registerBusiness(businessData);

      if (response.isSuccess && response.data != null) {
        // Update user with business information
        if (_user != null && response.data!.containsKey('businessId')) {
          _user = _user!.copyWith(businessId: response.data!['businessId']);
        }
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Business registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Business registration failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Refresh user data from server
  Future<void> refreshUser() async {
    try {
      if (_user == null) return;
      
      final storedUser = await _authService.getStoredUser();
      if (storedUser != null) {
        _user = storedUser;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}