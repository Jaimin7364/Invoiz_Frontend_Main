import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'subscription_plans_screen.dart';

class SubscriptionStatusScreen extends StatelessWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Subscription Status',
        actions: [
          IconButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.getCurrentUser();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription data refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh subscription data',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final subscription = user?.subscription;

          if (subscription == null) {
            return _buildNoSubscriptionState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscription Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_membership,
                              color: AppColors.primary,
                              size: AppSizes.iconLg,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Text(
                              'Subscription Status',
                              style: AppTextStyles.h5.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.lg),
                        
                        // Plan Name
                        Text(
                          subscription.planDisplayName,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSizes.md),
                        
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: subscription.isActive 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                            border: Border.all(
                              color: subscription.isActive 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                subscription.isActive 
                                    ? Icons.check_circle 
                                    : Icons.warning,
                                color: subscription.isActive 
                                    ? Colors.green 
                                    : Colors.red,
                                size: AppSizes.iconSm,
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Text(
                                subscription.status?.toUpperCase() ?? 'UNKNOWN',
                                style: TextStyle(
                                  color: subscription.isActive 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSizes.md),
                
                // Subscription Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Plan Type',
                          subscription.planDisplayName,
                        ),
                        _buildDetailRow(
                          'Start Date',
                          subscription.startDate != null
                              ? _formatDate(subscription.startDate!)
                              : 'Not available',
                        ),
                        _buildDetailRow(
                          'End Date',
                          subscription.endDate != null
                              ? _formatDate(subscription.endDate!)
                              : 'Not available',
                        ),
                        _buildDetailRow(
                          'Days Remaining',
                          '${subscription.daysRemaining} ${subscription.daysRemaining == 1 ? 'day' : 'days'}',
                          valueColor: subscription.daysRemaining <= 3 
                              ? Colors.red 
                              : subscription.daysRemaining <= 7 
                                  ? Colors.orange 
                                  : Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSizes.md),
                
                // Progress Indicator
                if (subscription.isActive) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subscription Progress',
                            style: AppTextStyles.h6,
                          ),
                          const SizedBox(height: AppSizes.md),
                          LinearProgressIndicator(
                            value: subscription.subscriptionProgress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              subscription.subscriptionProgress > 0.8 
                                  ? Colors.red 
                                  : subscription.subscriptionProgress > 0.6 
                                      ? Colors.orange 
                                      : Colors.green,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            '${(subscription.subscriptionProgress * 100).toStringAsFixed(1)}% used',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                
                // Action Buttons
                if (subscription.isActive) ...[
                  if (subscription.daysRemaining <= 7) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionPlansScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Renew Subscription'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionPlansScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Subscribe Now'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoSubscriptionState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'No Active Subscription',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Subscribe to a plan to access all features',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Choose a Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}