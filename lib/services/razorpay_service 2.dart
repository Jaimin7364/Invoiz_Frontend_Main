import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/subscription_model.dart';
import 'api_service.dart';

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  late Razorpay _razorpay;
  ApiService? _apiService;

  // Live Razorpay credentials
  static const String _razorpayLiveKey = 'rzp_live_RQWzfr7G9SM0f9';

  // Callbacks
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  void initialize() {
    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      _apiService = ApiService();
      
      if (kDebugMode) {
        print('✅ Razorpay service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Razorpay service: $e');
      }
    }
  }

  void dispose() {
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (kDebugMode) {
      print('Payment Success: ${response.paymentId}');
    }
    _onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('Payment Error: ${response.code} - ${response.message}');
    }
    _onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print('External Wallet: ${response.walletName}');
    }
    _onExternalWallet?.call(response);
  }

  Future<ApiResponse<Map<String, dynamic>>> createSubscriptionOrder({
    required String planType,
  }) async {
    try {
      final response = await _apiService!.post(
        '/subscription/create-order',
        data: {
          'plan_type': planType,
        },
      );

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String planType,
  }) async {
    try {
      final response = await _apiService!.post(
        '/subscription/verify-payment',
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'plan_type': planType,
        },
      );

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<List<SubscriptionPlan>>> getSubscriptionPlans() async {
    try {
      final response = await _apiService!.get('/subscription/plans');

      final plansData = response.data['data']['plans'] as List;
      final plans = plansData
          .map((planJson) => SubscriptionPlan.fromJson(planJson))
          .toList();

      return ApiResponse.success(plans);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  void openCheckout({
    required String orderId,
    required double amount,
    required String currency,
    required String userEmail,
    required String userPhone,
    required String userName,
    required String description,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    // Set callbacks
    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;
    _onExternalWallet = onExternalWallet;

    if (kDebugMode) {
      print('=== Razorpay Checkout Debug Info ===');
      print('Order ID: $orderId');
      print('Amount: $amount');
      print('Currency: $currency');
      print('User Email: $userEmail');
      print('User Phone: $userPhone');
      print('User Name: $userName');
      print('Description: $description');
      print('Razorpay Key: $_razorpayLiveKey');
    }

    // Format phone number (ensure it's 10 digits)
    String formattedPhone = userPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedPhone.length > 10) {
      formattedPhone = formattedPhone.substring(formattedPhone.length - 10);
    }

    var options = {
      'key': _razorpayLiveKey, // Use live key directly
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Invoiz',
      'description': description,
      'order_id': orderId,
      'prefill': {
        'contact': formattedPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#2E7D32',
      },
      'external': {
        'wallets': ['paytm', 'phonepe', 'gpay', 'amazon_pay']
      },
      'modal': {
        'ondismiss': () {
          if (kDebugMode) {
            print('Payment modal dismissed');
          }
        }
      },
      'notes': {
        'platform': 'flutter',
        'app': 'invoiz',
      }
    };

    if (kDebugMode) {
      print('=== Razorpay Options ===');
      print('Options: $options');
      print('=========================');
    }

    try {
      if (kDebugMode) {
        print('Calling _razorpay.open()...');
      }
      _razorpay.open(options);
      if (kDebugMode) {
        print('_razorpay.open() called successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening Razorpay: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      _onPaymentError?.call(PaymentFailureResponse(
        500,
        'Failed to open payment gateway',
        {'error': e.toString()},
      ));
    }
  }

  // Helper method to format amount for display
  static String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Helper method to format currency
  static String formatCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }
}

// Payment status enum
enum PaymentStatus {
  pending,
  success,
  failed,
  cancelled,
}

// Payment result class
class PaymentResult {
  final PaymentStatus status;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
  final Map<String, dynamic>? subscriptionData;

  PaymentResult({
    required this.status,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
    this.subscriptionData,
  });

  bool get isSuccess => status == PaymentStatus.success;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isCancelled => status == PaymentStatus.cancelled;
}