import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/language_selector.dart';
import '../../models/user_model.dart';
import '../../l10n/app_localizations.dart';
import '../auth/welcome_screen.dart';
import '../business/business_details_screen.dart';
import '../admin/admin_panel_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.profile,
        showBackButton: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          user?.fullName.split(' ').map((e) => e[0]).take(2).join() ?? 'U',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        user?.fullName ?? 'User Name',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      Text(
                        user?.email ?? 'user@example.com',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.8),
                        ),
                      ),
                      if (user?.hasBusiness == true) ...[
                        const SizedBox(height: AppSizes.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.business,
                                size: AppSizes.iconSm,
                                color: AppColors.textOnPrimary,
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Text(
                                user!.businessInfo!.businessName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Subscription Status Card
                _buildSubscriptionCard(user?.subscription),
                const SizedBox(height: AppSizes.lg),

                // Profile Options
                // Admin Panel Option (only for Admin users)
                if (user?.role == 'Admin') ...[
                  _buildProfileOption(
                    icon: Icons.admin_panel_settings,
                    title: 'Admin Panel',
                    subtitle: 'Manage users and subscriptions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminPanelScreen(),
                        ),
                      );
                    },
                  ),
                  const LanguageSelector(),
                ] else ...[
                  // Show normal user options only for non-admin users
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {
                      _showComingSoon(context);
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.business_outlined,
                    title: localizations.businessDetails,
                    subtitle: user?.businessInfo?.businessName ?? localizations.manageBusinessInformation,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusinessDetailsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.subscriptions_outlined,
                    title: localizations.subscriptionPlans,
                    subtitle: localizations.upgradeOrManageSubscription,
                    onTap: () {
                      Navigator.pushNamed(context, '/subscription-plans');
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences and configurations',
                    onTap: () {
                      _showComingSoon(context);
                    },
                  ),
                  const LanguageSelector(),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      _showComingSoon(context);
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      _showComingSoon(context);
                    },
                  ),
                ],
                const SizedBox(height: AppSizes.lg),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      _showLogoutDialog(context, authProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(localizations.logout),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: AppTextStyles.h6,
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: AppSizes.iconSm,
          color: AppColors.textHint,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionInfo? subscription) {
    if (subscription == null) {
      // No subscription
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.subscriptions_outlined,
                    color: AppColors.warning,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'Subscription Status',
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: AppSizes.iconSm,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'No active subscription',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Subscribe to unlock premium features and enjoy unlimited access to all tools.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Has subscription
    final bool isActive = subscription.isActive;
    final bool isExpired = subscription.isExpired;
    final Color statusColor = isActive 
        ? AppColors.success 
        : isExpired 
            ? AppColors.error 
            : AppColors.warning;
    
    final IconData statusIcon = isActive 
        ? Icons.check_circle_outline 
        : isExpired 
            ? Icons.error_outline 
            : Icons.warning_outlined;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.subscriptions_outlined,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'Subscription Status',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            
            // Plan Name
            Text(
              subscription.planDisplayName,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: AppSizes.iconSm,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    isActive 
                        ? 'Active' 
                        : isExpired 
                            ? 'Expired' 
                            : subscription.status?.toUpperCase() ?? 'INACTIVE',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            
            // Subscription Details
            _buildSubscriptionDetail(
              'Plan Type',
              subscription.planDisplayName,
              Icons.card_membership_outlined,
            ),
            
            if (subscription.startDate != null)
              _buildSubscriptionDetail(
                'Start Date',
                _formatDate(subscription.startDate!),
                Icons.calendar_today_outlined,
              ),
            
            if (subscription.endDate != null)
              _buildSubscriptionDetail(
                'End Date',
                _formatDate(subscription.endDate!),
                Icons.event_outlined,
              ),
            
            _buildSubscriptionDetail(
              'Days Remaining',
              subscription.daysRemaining > 0 
                  ? '${subscription.daysRemaining} days'
                  : 'Expired',
              Icons.schedule_outlined,
              valueColor: subscription.daysRemaining > 7 
                  ? AppColors.success
                  : subscription.daysRemaining > 0
                      ? AppColors.warning
                      : AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetail(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconSm,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Clear all provider data before logout
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
                
                productProvider.clearData();
                invoiceProvider.clearData();
                
                // Logout user
                await authProvider.logout();
                
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}