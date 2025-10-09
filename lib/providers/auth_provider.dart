import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../config/app_config.dart';
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
  int get subscriptionDaysRemaining => _user?.subscription?.daysRemaining ?? 0;
  bool get shouldShowSubscriptionWarning => 
      hasActiveSubscription && subscriptionDaysRemaining <= AppConfig.subscriptionWarningDays;

  // Initialize provider
  Future<void> initialize() async {
    // Schedule the loading state update for the next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLoading(true);
    });
    
    try {
      await _storageService.initialize();
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        // Check if token is expired (client-side check)
        final isTokenExpired = await _storageService.isTokenExpired();
        if (isTokenExpired) {
          // Token is expired, clear data and set as not logged in
          await _authService.clearStoredData();
          _isLoggedIn = false;
          _user = null;
        } else {
          _user = await _authService.getStoredUser();
          if (_user != null) {
            // Refresh user data from server
            await getCurrentUser();
          }
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
      print('AuthProvider: Fetching current user data...');
      final response = await _authService.getCurrentUser();
      if (response.isSuccess && response.data != null) {
        _user = response.data;
        await _storageService.saveUser(_user!);
        
        print('AuthProvider: User data updated successfully');
        print('  - Subscription: ${_user!.subscription != null ? 'exists' : 'null'}');
        if (_user!.subscription != null) {
          print('  - Plan: ${_user!.subscription!.planType}');
          print('  - Status: ${_user!.subscription!.status}');
          print('  - Days remaining: ${_user!.subscription!.daysRemaining}');
        }
        
        notifyListeners();
      } else {
        print('AuthProvider: Failed to get current user - ${response.error}');
      }
    } catch (e) {
      print('AuthProvider: Error getting current user: $e');
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

  // Force refresh subscription status from server
  Future<void> refreshSubscriptionStatus() async {
    if (!_isLoggedIn || _user == null) return;
    
    try {
      // Refresh user data which includes subscription info
      await getCurrentUser();
    } catch (e) {
      print('Error refreshing subscription status: $e');
    }
  }

  // Update subscription after successful payment
  void updateSubscription(Map<String, dynamic> subscriptionData) {
    if (_user != null) {
      final subscription = SubscriptionInfo.fromJson(subscriptionData);
      _user = _user!.copyWith(subscription: subscription);
      _storageService.saveUser(_user!);
      notifyListeners();
    }
  }

  // FOR TESTING ONLY - Simulate expired subscription
  void simulateExpiredSubscription() {
    if (_user != null) {
      final expiredSubscription = SubscriptionInfo(
        planType: 'basic',
        status: 'expired',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        daysRemaining: 0,
      );
      _user = _user!.copyWith(subscription: expiredSubscription);
      notifyListeners();
    }
  }

  // FOR TESTING ONLY - Reset token timestamp to simulate fresh login
  Future<void> resetTokenTimestamp() async {
    await _storageService.saveTokenTimestamp();
    print('Token timestamp reset to current time');
  }

  // FOR TESTING ONLY - Simulate subscription with specific dates
  void simulateSubscription({
    required String planType,
    required DateTime startDate,
    required DateTime endDate,
    String status = 'active',
  }) {
    if (_user != null) {
      final subscription = SubscriptionInfo(
        planType: planType,
        status: status,
        startDate: startDate,
        endDate: endDate,
        daysRemaining: 0, // Will be calculated dynamically
      );
      _user = _user!.copyWith(subscription: subscription);
      notifyListeners();
      
      print('Simulated subscription:');
      print('  Plan: $planType');
      print('  Start: ${startDate.day}/${startDate.month}/${startDate.year}');
      print('  End: ${endDate.day}/${endDate.month}/${endDate.year}');
      print('  Days remaining: ${subscription.daysRemaining}');
    }
  }

  // Check if token is valid (not expired)
  Future<bool> isTokenValid() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;
      
      // Check client-side expiry
      final isExpired = await _storageService.isTokenExpired();
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  // Get token expiry information
  Future<Map<String, dynamic>> getTokenInfo() async {
    try {
      final timestamp = await _storageService.getTokenTimestamp();
      if (timestamp == null) {
        return {
          'isValid': false,
          'message': 'No token timestamp found'
        };
      }

      final tokenAge = DateTime.now().difference(timestamp);
      final daysRemaining = AppConfig.tokenLifetimeDays - tokenAge.inDays;
      final isExpired = daysRemaining <= 0;

      return {
        'isValid': !isExpired,
        'tokenAge': tokenAge.inDays,
        'daysRemaining': daysRemaining,
        'expiryDate': timestamp.add(const Duration(days: AppConfig.tokenLifetimeDays)),
        'isExpired': isExpired,
      };
    } catch (e) {
      return {
        'isValid': false,
        'message': 'Error checking token: $e'
      };
    }
  }

  // Register business
  Future<bool> registerBusiness(Map<String, dynamic> businessData) async {
    _setLoading(true);
    _clearError();

    try {
      print('AuthProvider: Registering business with data: $businessData');
      final response = await _authService.registerBusiness(businessData);
      print('AuthProvider: Business registration response success: ${response.isSuccess}, data: ${response.data}');

      if (response.isSuccess && response.data != null) {
        // Update user with business information
        if (_user != null) {
          final businessId = response.data!['business_id'] ?? response.data!['businessId'];
          print('AuthProvider: Received business_id: $businessId');
          if (businessId != null) {
            _user = _user!.copyWith(businessId: businessId);
            
            // Refresh user data to get the complete business info
            print('AuthProvider: Refreshing user data after business registration...');
            await getCurrentUser();
            print('AuthProvider: User data after refresh - Business ID: ${_user?.businessId}, Business Info: ${_user?.businessInfo != null}');
          }
        }
        _setLoading(false);
        return true;
      } else {
        print('AuthProvider: Business registration failed: ${response.error}');
        _setError(response.error ?? 'Business registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('AuthProvider: Business registration exception: ${e.toString()}');
      _setError('Business registration failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Refresh user data from server
  Future<void> refreshUser() async {
    try {
      print('AuthProvider: Refreshing user data from server...');
      await getCurrentUser();
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Wait for subscription to be active after payment
  Future<bool> waitForActiveSubscription({int maxAttempts = 5, Duration delay = const Duration(seconds: 2)}) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      print('AuthProvider: Checking subscription status (attempt $attempt/$maxAttempts)...');
      
      await getCurrentUser();
      
      if (hasActiveSubscription && !isSubscriptionExpired) {
        print('AuthProvider: Active subscription found!');
        return true;
      }
      
      if (attempt < maxAttempts) {
        print('AuthProvider: No active subscription yet, waiting ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }
    
    print('AuthProvider: Failed to detect active subscription after $maxAttempts attempts');
    return false;
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

  // Public method to clear loading state if needed
  void clearLoading() {
    _setLoading(false);
  }

  @override
  void dispose() {
    super.dispose();
  }
}