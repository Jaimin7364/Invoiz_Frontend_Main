import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/razorpay_service.dart';
import '../../services/subscription_guard_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_button.dart';
import '../home/home_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  final bool canGoBack;
  final String? message;
  
  const SubscriptionPlansScreen({
    super.key,
    this.canGoBack = true,
    this.message,
  });

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String? _selectedPlan;
  bool _isLoading = false;
  late RazorpayService _razorpayService;

  List<Map<String, dynamic>> _plans = [];
  bool _loadingPlans = true;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.initialize();
    _loadPlans();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      final plansResp = await _razorpayService.getSubscriptionPlans();
      if (plansResp.isSuccess && plansResp.data != null) {
        setState(() {
          _plans = plansResp.data!.map((p) => {
                'id': p.planId,
                'name': p.name,
                'price': '₹${p.priceInr}',
                'duration': p.durationText,
                'features': p.features,
                'popular': p.planId == 'pro',
              }).toList();
          _loadingPlans = false;
        });
      } else {
        setState(() { _loadingPlans = false; });
      }
    } catch (e) {
      setState(() { _loadingPlans = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isSubscriptionExpired = authProvider.isLoggedIn && 
        (!authProvider.hasActiveSubscription || authProvider.isSubscriptionExpired);
    
    if (_loadingPlans) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: widget.canGoBack && !isSubscriptionExpired,
      onPopInvoked: (didPop) {
        if (!didPop && !widget.canGoBack) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a subscription plan to continue'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: isSubscriptionExpired ? 'Renew Your Plan' : 'Choose Your Plan',
          showBackButton: widget.canGoBack && !isSubscriptionExpired,
        ),
        body: SafeArea(
          child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                // Warning message for expired subscription
                if (widget.message != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    margin: const EdgeInsets.only(bottom: AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            widget.message!,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  isSubscriptionExpired 
                      ? 'Your subscription has expired. Choose a plan to continue.'
                      : 'Select a Subscription Plan',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Choose the plan that best fits your business needs',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Plans List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                final isSelected = _selectedPlan == plan['id'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlan = plan['id'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.05) 
                          : AppColors.surface,
                    ),
                    child: Stack(
                      children: [
                        // Popular badge
                        if (plan['popular'])
                          Positioned(
                            top: AppSizes.sm,
                            right: AppSizes.sm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: Text(
                                'POPULAR',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Plan name and price
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan['name'],
                                        style: AppTextStyles.h5.copyWith(
                                          color: isSelected 
                                              ? AppColors.primary 
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: AppSizes.xs),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: plan['price'],
                                              style: AppTextStyles.h4.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' ${plan['duration']}',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Radio<String>(
                                    value: plan['id'],
                                    groupValue: _selectedPlan,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPlan = value;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.md),
                              
                              // Features
                              ...List.generate(
                                plan['features'].length,
                                (featureIndex) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSizes.xs),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: AppSizes.iconSm,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: AppSizes.sm),
                                      Expanded(
                                        child: Text(
                                          plan['features'][featureIndex],
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom section with continue button
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                if (_selectedPlan != null) ...[
                  Text(
                    'You selected: ${_plans.firstWhere((p) => p['id'] == _selectedPlan)['name']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                LoadingButton(
                  onPressed: _selectedPlan == null || _isLoading 
                      ? null 
                      : _proceedWithSubscription,
                  isLoading: _isLoading,
                  text: _selectedPlan == null 
                      ? 'Select a Plan' 
                      : 'Continue with Payment',
                ),
                const SizedBox(height: AppSizes.sm),
                TextButton(
                  onPressed: _skipSubscription,
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
      ),
    );
  }

  Future<void> _proceedWithSubscription() async {
    if (_selectedPlan == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User not found');
      }

      print('Creating order for plan: $_selectedPlan');

      // Create order
      final orderResponse = await _razorpayService.createSubscriptionOrder(
        planType: _selectedPlan!,
      );

      print('Order response: ${orderResponse.isSuccess}');
      print('Order data: ${orderResponse.data}');

      if (!orderResponse.isSuccess || orderResponse.data == null) {
        throw Exception(orderResponse.error ?? 'Failed to create order');
      }

      final orderData = orderResponse.data!;
      final selectedPlanData = _plans.firstWhere((p) => p['id'] == _selectedPlan);

      print('Opening Razorpay checkout with order ID: ${orderData['order_id']}');
      print('Amount: ${(orderData['amount'] as int) / 100.0}');
      print('Currency: ${orderData['currency'] ?? 'INR'}');

      // Open Razorpay checkout
      _razorpayService.openCheckout(
        orderId: orderData['order_id'],
        amount: (orderData['amount'] as int) / 100.0, // Convert paise to rupees
        currency: orderData['currency'] ?? 'INR',
        userEmail: user.email,
        userPhone: user.mobileNumber,
        userName: user.fullName,
        description: 'Subscription to ${selectedPlanData['name']}',
        keyId: orderData['razorpay_key'],
        onSuccess: (PaymentSuccessResponse response) async {
          print('Payment success: ${response.paymentId}');
          await _handlePaymentSuccess(response, orderData);
        },
        onError: (PaymentFailureResponse response) {
          print('Payment error: ${response.code} - ${response.message}');
          _handlePaymentError(response);
        },
        onExternalWallet: (ExternalWalletResponse response) {
          print('External wallet: ${response.walletName}');
          _handleExternalWallet(response);
        },
      );

    } catch (e) {
      print('Error in _proceedWithSubscription: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse response,
    Map<String, dynamic> orderData,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Starting payment verification...');
      print('Payment ID: ${response.paymentId}');
      print('Order ID: ${response.orderId}');

      // Add a small delay to ensure the payment is processed on Razorpay's end
      await Future.delayed(const Duration(seconds: 1));

      // Resolve orderId (server is source of truth)
      final String safeOrderId = (orderData['order_id'] as String);

      print('Resolved verification params (server-driven):');
      print('  - orderId: $safeOrderId');

      // Verify payment with backend by order only (server will fetch/capture status)
      bool verificationSuccess = false;
      String? errorMessage;
      
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          print('Payment verification attempt $attempt/3...');
          final verifyResponse = await _razorpayService.verifyPaymentByOrder(
            orderId: safeOrderId,
            planType: _selectedPlan!,
          );

          if (verifyResponse.isSuccess) {
            verificationSuccess = true;
            print('Payment verification successful on attempt $attempt');
            break;
          } else {
            errorMessage = verifyResponse.error ?? 'Payment verification failed';
            print('Payment verification failed on attempt $attempt: $errorMessage');
            
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: attempt * 2)); // 2s, 4s delay
            }
          }
        } catch (e) {
          errorMessage = e.toString();
          print('Payment verification error on attempt $attempt: $e');
          
          if (attempt < 3) {
            await Future.delayed(Duration(seconds: attempt * 2)); // 2s, 4s delay
          }
        }
      }

      if (!verificationSuccess) {
        throw Exception(errorMessage ?? 'Payment verification failed after multiple attempts');
      }

      // Update auth provider with new subscription info
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      print('Waiting for subscription to be activated...');
      
      // Wait for the subscription to be active before proceeding
      final hasActiveSubscription = await authProvider.waitForActiveSubscription();
      
      if (mounted) {
        if (hasActiveSubscription) {
          print('Subscription successfully activated!');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Subscription activated successfully!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );

          // Bypass the next subscription check to avoid redirect loop
          SubscriptionGuardService.bypassNextCheck();
          
          // Navigate to home with a small delay for user feedback
          await Future.delayed(const Duration(seconds: 1));
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        } else {
          print('Subscription not yet active, showing pending message...');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💳 Payment successful! Subscription activation in progress...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          
          // Try one more time with extended wait
          print('Attempting extended wait for subscription activation...');
          
          for (int i = 0; i < 3; i++) {
            await Future.delayed(const Duration(seconds: 3));
            await authProvider.getCurrentUser();
            
            if (authProvider.hasActiveSubscription && !authProvider.isSubscriptionExpired) {
              print('Subscription activated after extended wait!');
              
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Subscription successfully activated!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              }
              return;
            }
          }
          
          // If still not active after extended wait, show error but still proceed
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Payment completed but subscription may take a few minutes to activate. Please refresh the app.'),
                backgroundColor: Colors.amber,
                duration: Duration(seconds: 8),
              ),
            );
            
            // Still navigate to home as payment was successful
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      print('Error in payment success handler: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Payment verification failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Trigger manual verification
                _handlePaymentSuccess(response, orderData);
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Payment failed';
      
      // Provide more specific error messages based on the error code
      switch (response.code) {
        case 0:
          errorMessage = 'Payment was cancelled by user';
          break;
        case 1:
          errorMessage = 'Payment failed due to invalid details';
          break;
        case 2:
          errorMessage = 'Network error occurred during payment';
          break;
        default:
          errorMessage = response.message ?? 'Payment failed with unknown error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '❌ $errorMessage',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (response.code != 0) // Don't show retry option for user cancellation
                const Text(
                  'Please try again or contact support if the issue persists.',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 8),
          action: response.code != 0 ? SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _proceedWithSubscription();
            },
          ) : null,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  void _skipSubscription() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Skip Subscription?'),
          content: const Text(
            'You can subscribe later from your profile. Some features may be limited without a subscription.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
  }
}