import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/razorpay_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_button.dart';
import '../home/home_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String? _selectedPlan;
  bool _isLoading = false;
  late RazorpayService _razorpayService;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'basic',
      'name': 'Basic Plan',
      'price': '₹100',
      'duration': 'per month',
      'features': [
        'Basic invoicing',
        'Up to 50 invoices/month',
        'Email support',
        'Basic templates',
      ],
      'popular': false,
    },
    {
      'id': 'pro',
      'name': 'Pro Plan',
      'price': '₹549',
      'duration': 'for 6 months',
      'features': [
        'Advanced invoicing',
        'Unlimited invoices',
        'Priority support',
        'Custom templates',
        'Payment tracking',
        'Expense management',
      ],
      'popular': true,
    },
    {
      'id': 'premium',
      'name': 'Premium Plan',
      'price': '₹999',
      'duration': 'for 12 months',
      'features': [
        'All Pro features',
        'Multi-business support',
        'Advanced analytics',
        'Custom branding',
        'API access',
        'Priority phone support',
      ],
      'popular': false,
    },
    {
      'id': 'enterprise',
      'name': 'Enterprise Plan',
      'price': '₹2,499',
      'duration': 'for 3 years',
      'features': [
        'All Premium features',
        'Dedicated account manager',
        'Custom integrations',
        'White-label solution',
        'Advanced security',
        '24/7 phone support',
      ],
      'popular': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.initialize();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Choose Your Plan',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                Text(
                  'Select a Subscription Plan',
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

      // Verify payment with backend
      final verifyResponse = await _razorpayService.verifyPayment(
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
        planType: _selectedPlan!,
      );

      if (verifyResponse.isSuccess) {
        // Update auth provider with new subscription info
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription activated successfully!'),
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
      } else {
        throw Exception(verifyResponse.error ?? 'Payment verification failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: ${e.toString()}'),
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

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: AppColors.error,
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