import 'business_model.dart';

class User {
  final String userId;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String role;
  final String accountStatus;
  final bool emailVerified;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final SubscriptionInfo? subscription;
  final String? businessId;
  final Business? businessInfo;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.role,
    required this.accountStatus,
    required this.emailVerified,
    this.lastLogin,
    required this.createdAt,
    this.subscription,
    this.businessId,
    this.businessInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      role: json['role'] ?? '',
      accountStatus: json['account_status'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      subscription: json['subscription_info'] != null 
          ? SubscriptionInfo.fromJson(json['subscription_info']) 
          : null,
      businessId: json['business_id'],
      businessInfo: json['business_info'] != null 
          ? Business.fromJson(json['business_info']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'mobile_number': mobileNumber,
      'role': role,
      'account_status': accountStatus,
      'email_verified': emailVerified,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'subscription_info': subscription?.toJson(),
      'business_id': businessId,
      'business_info': businessInfo?.toJson(),
    };
  }

  User copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? mobileNumber,
    String? role,
    String? accountStatus,
    bool? emailVerified,
    DateTime? lastLogin,
    DateTime? createdAt,
    SubscriptionInfo? subscription,
    String? businessId,
    Business? businessInfo,
  }) {
    return User(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      subscription: subscription ?? this.subscription,
      businessId: businessId ?? this.businessId,
      businessInfo: businessInfo ?? this.businessInfo,
    );
  }

  bool get hasActiveSubscription => 
      subscription != null && 
      subscription!.status == 'active' && 
      subscription!.daysRemaining > 0;

  bool get isSubscriptionExpired => 
      subscription == null || 
      subscription!.status != 'active' || 
      subscription!.daysRemaining <= 0;

  bool get hasBusiness => businessInfo != null && businessId != null;
  
  bool get isBusinessVerified => 
      hasBusiness && businessInfo!.verificationStatus == 'Verified';
}

class SubscriptionInfo {
  final String? planType;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? _staticDaysRemaining; // Keep for backward compatibility

  SubscriptionInfo({
    this.planType,
    this.status,
    this.startDate,
    this.endDate,
    int daysRemaining = 0,
  }) : _staticDaysRemaining = daysRemaining;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      planType: json['plan_type'],
      status: json['status'],
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_type': planType,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'days_remaining': daysRemaining,
    };
  }

  /// Dynamic calculation of days remaining based on current date and end date
  int get daysRemaining {
    if (endDate == null) return _staticDaysRemaining ?? 0;
    
    final now = DateTime.now();
    // Set to start of current day for accurate comparison
    final currentDayStart = DateTime(now.year, now.month, now.day);
    
    // Calculate difference from start of current day to end date
    final difference = endDate!.difference(currentDayStart);
    
    // Return the number of complete days remaining
    // If subscription ends today, it's 0 days remaining
    return difference.inDays >= 0 ? difference.inDays : 0;
  }

  /// Get the total duration of the subscription in days
  int get totalSubscriptionDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  /// Get the number of days used so far
  int get daysUsed {
    if (startDate == null) return 0;
    
    final now = DateTime.now();
    final startOfDay = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final difference = now.difference(startOfDay);
    
    return difference.inDays >= 0 ? difference.inDays + 1 : 0;
  }

  /// Get subscription progress as a percentage (0.0 to 1.0)
  double get subscriptionProgress {
    final total = totalSubscriptionDays;
    if (total <= 0) return 0.0;
    
    final used = daysUsed;
    return (used / total).clamp(0.0, 1.0);
  }

  String get planDisplayName {
    switch (planType) {
      case 'basic':
        return 'Basic Plan';
      case 'pro':
        return 'Pro Plan';
      case 'premium':
        return 'Premium Plan';
      case 'enterprise':
        return 'Enterprise Plan';
      default:
        return 'No Plan';
    }
  }

  bool get isActive => status == 'active' && daysRemaining > 0;
  bool get isExpired => status == 'expired' || daysRemaining <= 0;
  bool get isCancelled => status == 'cancelled';

  /// Helper method to format remaining time in a user-friendly way
  String get remainingTimeFormatted {
    final days = daysRemaining;
    if (days <= 0) return 'Expired';
    if (days == 1) return '1 day';
    if (days < 30) return '$days days';
    
    final months = (days / 30).floor();
    final remainingDays = days % 30;
    
    if (months == 1 && remainingDays == 0) return '1 month';
    if (months == 1) return '1 month, $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
    if (remainingDays == 0) return '$months months';
    return '$months months, $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
  }
}