import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart';

class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.businessDetails,
        actions: [
          IconButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.getCurrentUser();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Business details refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: localizations.refreshBusinessDetails,
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final business = user?.businessInfo;

          if (business == null) {
            return _buildNoBusinessState(context, localizations);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Overview Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              color: AppColors.primary,
                              size: AppSizes.iconLg,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    business.businessName,
                                    style: AppTextStyles.h5.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    business.businessType,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                color: business.verificationStatus == 'Verified'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                                border: Border.all(
                                  color: business.verificationStatus == 'Verified'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    business.verificationStatus == 'Verified'
                                        ? Icons.verified
                                        : Icons.pending,
                                    color: business.verificationStatus == 'Verified'
                                        ? Colors.green
                                        : Colors.orange,
                                    size: AppSizes.iconSm,
                                  ),
                                  const SizedBox(width: AppSizes.xs),
                                  Text(
                                    business.verificationStatus,
                                    style: TextStyle(
                                      color: business.verificationStatus == 'Verified'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Business Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Information',
                          style: AppTextStyles.h6,
                        ),
                        const SizedBox(height: AppSizes.md),
                        _buildDetailRow('Business ID', business.businessId),
                        _buildDetailRow('Business Name', business.businessName),
                        _buildDetailRow('Business Type', business.businessType),
                        _buildDetailRow('Status', business.businessStatus),
                        if (business.gstNumber != null)
                          _buildDetailRow('GST Number', business.gstNumber!),
                        _buildDetailRow('UPI ID', business.upiId),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Address Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Address',
                          style: AppTextStyles.h6,
                        ),
                        const SizedBox(height: AppSizes.md),
                        _buildDetailRow('Street', business.businessAddress.street),
                        _buildDetailRow('City', business.businessAddress.city),
                        _buildDetailRow('State', business.businessAddress.state),
                        _buildDetailRow('Pincode', business.businessAddress.pincode),
                        _buildDetailRow('Country', business.businessAddress.country),
                        const SizedBox(height: AppSizes.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            business.fullAddress,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Contact Details Card
                if (business.contactDetails != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Details',
                            style: AppTextStyles.h6,
                          ),
                          const SizedBox(height: AppSizes.md),
                          if (business.contactDetails!.phone != null)
                            _buildDetailRow('Phone', business.contactDetails!.phone!),
                          if (business.contactDetails!.email != null)
                            _buildDetailRow('Email', business.contactDetails!.email!),
                          if (business.contactDetails!.website != null)
                            _buildDetailRow('Website', business.contactDetails!.website!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],

                // Action Buttons
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit business feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Business Details'),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Business verification feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.verified_user),
                            label: const Text('Request Verification'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoBusinessState(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              localizations.noBusinessRegistered,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              localizations.registerBusinessToAccessFeatures,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Business registration feature coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_business),
                label: const Text('Register Business'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}