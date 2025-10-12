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

  // Razorpay credentials - for now use live key for testing
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
      print('🎉 Payment Success: ${response.paymentId}');
      print('🎉 Order ID: ${response.orderId}');
      print('🎉 Signature: ${response.signature}');
    }
    _onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('❌ Payment Error: ${response.code} - ${response.message}');
      print('❌ Error data: ${response.error}');
    }
    _onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print('💳 External Wallet: ${response.walletName}');
    }
    _onExternalWallet?.call(response);
  }

  // Simple test payment to check if Razorpay works
  void testSimplePayment() {
    if (kDebugMode) {
      print('🧪 Testing simple Razorpay payment...');
      print('🧪 Razorpay instance: $_razorpay');
    }

    try {
      // Very basic options for testing
      var options = {
        'key': _razorpayLiveKey,
        'amount': 100, // ₹1 in paise (test amount)
        'name': 'Test Payment',
        'description': 'Testing Razorpay integration',
        'prefill': {
          'contact': '9999999999',
          'email': 'test@example.com'
        }
      };

      if (kDebugMode) {
        print('🧪 About to call _razorpay.open()...');
        print('🧪 Options: $options');
      }

      // Add a small delay to ensure everything is initialized
      Future.delayed(Duration(milliseconds: 100), () {
        try {
          _razorpay.open(options);
          if (kDebugMode) {
            print('🧪 _razorpay.open() called successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error in delayed call: $e');
          }
        }
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Test payment failed: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    }
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
      if (kDebugMode) {
        print('🔍 RazorpayService: Starting payment verification...');
        print('  - Order ID: $orderId');
        print('  - Payment ID: $paymentId');
        print('  - Signature: $signature');
        print('  - Plan Type: $planType');
      }

      // Use the enhanced verification endpoint
      final response = await _apiService!.post(
        '/subscription/verify-payment-v2',
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'plan_type': planType,
        },
      );

      if (kDebugMode) {
        print('✅ RazorpayService: Payment verification successful');
        print('  - Response: ${response.data}');
      }

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ RazorpayService: Payment verification failed');
        print('  - Status Code: ${e.response?.statusCode}');
        print('  - Response Data: ${e.response?.data}');
        print('  - Error Message: ${e.message}');
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ RazorpayService: Unexpected error during verification');
        print('  - Error: $e');
      }
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPaymentByOrder({
    required String orderId,
    String? planType,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 RazorpayService: verify by order...');
        print('  - Order ID: $orderId');
        print('  - Plan Type: $planType');
      }

      final response = await _apiService!.post(
        '/subscription/verify-by-order',
        data: {
          'razorpay_order_id': orderId,
          if (planType != null) 'plan_type': planType,
        },
      );

      if (kDebugMode) {
        print('✅ verify-by-order successful: ${response.data}');
      }

      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ verify-by-order failed: ${e.response?.data}');
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> checkPaymentStatus({
    String? transactionId,
    String? razorpayOrderId,
  }) async {
    try {
      final response = await _apiService!.post(
        '/subscription/check-payment-status',
        data: {
          if (transactionId != null) 'transaction_id': transactionId,
          if (razorpayOrderId != null) 'razorpay_order_id': razorpayOrderId,
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
    String? keyId,
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

    if (kIsWeb) {
      // For web, show a message that payment should be done on mobile
      if (kDebugMode) {
        print('🌐 Web payments not supported in this build. Please use mobile app.');
      }
      _onPaymentError?.call(PaymentFailureResponse(
        500,
        'Web payments not supported. Please use the mobile app for payments.',
        {'error': 'Web payments not implemented'},
      ));
    } else {
      // Use mobile implementation
      var options = {
        // Prefer server-provided key if available; fallback to default
        'key': keyId ?? _razorpayLiveKey,
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
  }
}