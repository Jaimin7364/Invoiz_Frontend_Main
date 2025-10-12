class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://20.244.93.108/api';
  static const String socketUrl = 'http://20.244.93.108';
  
  // API Endpoints
  static const String authEndpoint = '$baseUrl/auth';
  static const String businessEndpoint = '$baseUrl/business';
  static const String subscriptionEndpoint = '$baseUrl/subscription';
  static const String userEndpoint = '$baseUrl/user';
  
  // Razorpay Configuration
  static const String razorpayKeyId = 'rzp_live_RQWzfr7G9SM0f9';
  
  // App Configuration
  static const String appName = 'Invoiz';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String businessKey = 'business_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String subscriptionCheckKey = 'last_subscription_check';
  
  // Subscription Configuration
  static const int subscriptionCheckIntervalHours = 6; // Check every 6 hours
  static const int subscriptionWarningDays = 3; // Warn when 3 days left
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // Token Configuration
  static const int tokenLifetimeDays = 1825; // 5 years (5 * 365 days)
  static const bool autoRefreshToken = false; // Disabled for long-lived tokens
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpResendTime = 60; // seconds
  
  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'basic': {
      'name': 'Basic Plan',
      'price': 1,
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