import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../l10n/app_localizations.dart';
import 'payment_method_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    if (invoiceProvider.customerInfo != null) {
      _nameController.text = invoiceProvider.customerInfo!.name;
      _mobileController.text = invoiceProvider.customerInfo!.mobileNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _saveCustomerDetails() {
    if (_formKey.currentState!.validate()) {
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      invoiceProvider.setCustomerInfo(
        _nameController.text.trim(),
        _mobileController.text.trim(),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaymentMethodScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.customerDetails,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Info card
              Card(
                color: AppColors.primaryLight.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.customerDetails,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              'This information is only used for invoice generation and will not be saved to the database.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Customer name field
              Text(
                '${localizations.customerName} *',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              CustomTextField(
                controller: _nameController,
                labelText: localizations.customerName,
                hintText: 'Enter customer full name', // TODO: Add to localizations
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.fieldRequired;
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters long'; // TODO: Add to localizations
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSizes.lg),

              // Mobile number field
              Text(
                '${localizations.mobileNumber} *',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              CustomTextField(
                controller: _mobileController,
                labelText: localizations.mobileNumber,
                hintText: 'Enter 10-digit mobile number', // TODO: Add to localizations
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.fieldRequired;
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                    return localizations.invalidPhone;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSizes.xl),

              // Invoice summary
              Consumer<InvoiceProvider>(
                builder: (context, invoiceProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Text(
                                'Invoice Summary', // TODO: Add to localizations
                                style: AppTextStyles.h6.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Items (${invoiceProvider.selectedProducts.length})', // TODO: Add to localizations  
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                '₹${invoiceProvider.subtotal.toStringAsFixed(2)}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                          
                          if (invoiceProvider.calculatedDiscountAmount > 0) ...[
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Discount',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  '-₹${invoiceProvider.calculatedDiscountAmount.toStringAsFixed(2)}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          const Divider(),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${invoiceProvider.totalAmount.toStringAsFixed(2)}',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
      bottomNavigationBar: SafeArea(child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveCustomerDetails,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
            child: Text('${localizations.next} - ${localizations.paymentMethod}'),
          ),
        ),
      ),
      ),
    );
  }
}