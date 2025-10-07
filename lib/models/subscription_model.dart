class SubscriptionPlan {
  final String planId;
  final String name;
  final String description;
  final int priceInr;
  final int durationMonths;
  final List<String> features;
  final bool isActive;
  final int color;

  SubscriptionPlan({
    required this.planId,
    required this.name,
    required this.description,
    required this.priceInr,
    required this.durationMonths,
    required this.features,
    this.isActive = true,
    this.color = 0xFF4CAF50,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      planId: json['plan_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceInr: json['price_inr'] ?? 0,
      durationMonths: json['duration_months'] ?? 1,
      features: List<String>.from(json['features'] ?? []),
      isActive: json['is_active'] ?? true,
      color: json['color'] ?? 0xFF4CAF50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'name': name,
      'description': description,
      'price_inr': priceInr,
      'duration_months': durationMonths,
      'features': features,
      'is_active': isActive,
      'color': color,
    };
  }

  String get durationText {
    if (durationMonths == 1) return '1 month';
    if (durationMonths == 12) return '1 year';
    if (durationMonths == 36) return '3 years';
    return '$durationMonths months';
  }

  String get priceText => '₹$priceInr';

  double get monthlyPrice => priceInr / durationMonths;

  String get monthlyPriceText => '₹${monthlyPrice.toStringAsFixed(0)}/month';

  bool get isPopular => planId == 'pro' || planId == 'premium';

  String get badge {
    switch (planId) {
      case 'basic':
        return 'STARTER';
      case 'pro':
        return 'POPULAR';
      case 'premium':
        return 'BEST VALUE';
      case 'enterprise':
        return 'COMPLETE';
      default:
        return '';
    }
  }
}

class PaymentOrder {
  final String orderId;
  final int amount;
  final String currency;
  final SubscriptionPlan planDetails;
  final String transactionId;
  final String razorpayKey;

  PaymentOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.planDetails,
    required this.transactionId,
    required this.razorpayKey,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['order_id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      planDetails: SubscriptionPlan.fromJson(json['plan_details'] ?? {}),
      transactionId: json['transaction_id'] ?? '',
      razorpayKey: json['razorpay_key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'plan_details': planDetails.toJson(),
      'transaction_id': transactionId,
      'razorpay_key': razorpayKey,
    };
  }

  double get amountInRupees => amount / 100;
}

class PaymentResponse {
  final String paymentId;
  final String orderId;
  final String signature;

  PaymentResponse({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['razorpay_payment_id'] ?? '',
      orderId: json['razorpay_order_id'] ?? '',
      signature: json['razorpay_signature'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
      'razorpay_signature': signature,
    };
  }
}

class SubscriptionTransaction {
  final String transactionId;
  final String planId;
  final double amount;
  final String currency;
  final String status;
  final String? paymentId;
  final DateTime createdAt;

  SubscriptionTransaction({
    required this.transactionId,
    required this.planId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentId,
    required this.createdAt,
  });

  factory SubscriptionTransaction.fromJson(Map<String, dynamic> json) {
    return SubscriptionTransaction(
      transactionId: json['transaction_id'] ?? '',
      planId: json['plan_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? '',
      paymentId: json['razorpay_payment_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'plan_id': planId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'razorpay_payment_id': paymentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Success';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  bool get isSuccessful => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';
}