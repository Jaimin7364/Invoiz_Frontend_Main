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
    );
  }

  bool get hasActiveSubscription => 
      subscription != null && subscription!.status == 'active';

  bool get isSubscriptionExpired => 
      subscription == null || subscription!.daysRemaining <= 0;
}

class SubscriptionInfo {
  final String? planType;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int daysRemaining;

  SubscriptionInfo({
    this.planType,
    this.status,
    this.startDate,
    this.endDate,
    this.daysRemaining = 0,
  });

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
}