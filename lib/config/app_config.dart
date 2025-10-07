class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:5000/api';
  static const String socketUrl = 'http://localhost:5000';
  
  // API Endpoints
  static const String authEndpoint = '$baseUrl/auth';
  static const String businessEndpoint = '$baseUrl/business';
  static const String subscriptionEndpoint = '$baseUrl/subscription';
  static const String userEndpoint = '$baseUrl/user';
  
  // Razorpay Configuration
  static const String razorpayKeyId = 'your_razorpay_key_id'; // Will be fetched from API
  
  // App Configuration
  static const String appName = 'Invoiz';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String businessKey = 'business_data';
  static const String onboardingKey = 'onboarding_completed';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpResendTime = 60; // seconds
  
  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'basic': {
      'name': 'Basic Plan',
      'price': 100,
      'duration': '1 month',
      'color': 0xFF4CAF50,
    },
    'pro': {
      'name': 'Pro Plan',
      'price': 549,
      'duration': '6 months',
      'color': 0xFF2196F3,
    },
    'premium': {
      'name': 'Premium Plan',
      'price': 999,
      'duration': '12 months',
      'color': 0xFF9C27B0,
    },
    'enterprise': {
      'name': 'Enterprise Plan',
      'price': 2499,
      'duration': '36 months',
      'color': 0xFFFF9800,
    },
  };
}