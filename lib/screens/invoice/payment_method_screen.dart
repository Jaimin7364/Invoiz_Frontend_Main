import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/invoice_model.dart';
import '../../widgets/custom_app_bar.dart';
import 'invoice_final_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  void _generateInvoice() async {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    invoiceProvider.setPaymentMethod(_selectedPaymentMethod);
    
    final invoice = await invoiceProvider.createInvoice();
    if (invoice != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceFinalScreen(invoice: invoice),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.error ?? 'Failed to create invoice'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Payment Method',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment method selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'Select Payment Method',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Cash payment option
                    _buildPaymentMethodTile(
                      method: PaymentMethod.cash,
                      title: 'Cash Payment',
                      subtitle: 'Customer will pay in cash',
                      icon: Icons.money,
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Online payment option
                    _buildPaymentMethodTile(
                      method: PaymentMethod.online,
                      title: 'Online Payment (UPI)',
                      subtitle: 'Generate QR code for UPI payment',
                      icon: Icons.qr_code_2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // Customer details summary
            Consumer<InvoiceProvider>(
              builder: (context, invoiceProvider, child) {
                if (invoiceProvider.customerInfo == null) {
                  return const SizedBox();
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Text(
                              'Customer Details',
                              style: AppTextStyles.h6.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),
                        
                        Row(
                          children: [
                            Text(
                              'Name: ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              invoiceProvider.customerInfo!.name,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        
                        Row(
                          children: [
                            Text(
                              'Mobile: ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              invoiceProvider.customerInfo!.mobileNumber,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSizes.md),

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
                              'Invoice Summary',
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
                              'Items (${invoiceProvider.selectedProducts.length})',
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

            const SizedBox(height: AppSizes.md),

            // UPI information (shown only for online payment)
            if (_selectedPaymentMethod == PaymentMethod.online)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final business = authProvider.user?.businessInfo;
                  if (business?.upiId == null || business!.upiId.isEmpty) {
                    return Card(
                      color: AppColors.warning.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UPI ID Required',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.xs),
                                  Text(
                                    'Please add your UPI ID in business settings to enable online payments.',
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
                    );
                  }

                  return Card(
                    color: AppColors.success.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UPI ID Configured',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.xs),
                                Text(
                                  'QR code will be generated for: ${business.upiId}',
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
                  );
                },
              ),
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: Consumer<InvoiceProvider>(
          builder: (context, invoiceProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: invoiceProvider.isLoading ? null : _generateInvoice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
                child: invoiceProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _selectedPaymentMethod == PaymentMethod.cash
                            ? 'Generate Invoice'
                            : 'Generate Invoice with QR Code',
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}