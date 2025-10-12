import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/invoice_provider.dart';
import '../../models/invoice_model.dart';
import '../../widgets/custom_app_bar.dart';
import 'customer_details_screen.dart';

class InvoicePreviewScreen extends StatefulWidget {
  const InvoicePreviewScreen({super.key});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  final TextEditingController _discountController = TextEditingController();
  bool _isPercentageDiscount = false;

  @override
  void initState() {
    super.initState();
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    if (invoiceProvider.discountType == DiscountType.percentage) {
      _isPercentageDiscount = true;
      _discountController.text = invoiceProvider.discountPercentage.toString();
    } else {
      _discountController.text = invoiceProvider.discountAmount.toString();
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _updateDiscount() {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final value = double.tryParse(_discountController.text) ?? 0;
    
    if (_isPercentageDiscount) {
      if (value >= 0 && value <= 100) {
        invoiceProvider.setPercentageDiscount(value);
      }
    } else {
      if (value >= 0) {
        invoiceProvider.setFlatDiscount(value);
      }
    }
  }

  void _navigateToCustomerDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Invoice Preview',
        actions: [
          IconButton(
            onPressed: () {
              final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
              invoiceProvider.clearSelectedProducts();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.clear),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<InvoiceProvider>(
          builder: (context, invoiceProvider, child) {
            if (!invoiceProvider.hasSelectedProducts) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'No products selected',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Go back and select products to create an invoice',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected Products Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Selected Products',
                                    style: AppTextStyles.h6.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.md),
                              
                              // Products list
                              ...invoiceProvider.selectedProductsList.map((selectedProduct) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                                  padding: const EdgeInsets.all(AppSizes.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedProduct.product.name,
                                              style: AppTextStyles.bodyMedium.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: AppSizes.xs),
                                            Text(
                                              'Price: ₹${selectedProduct.product.price.toStringAsFixed(2)} per ${selectedProduct.product.unit}',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSizes.md),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Qty: ${selectedProduct.quantity}',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: AppSizes.xs),
                                          Text(
                                            '₹${selectedProduct.total.toStringAsFixed(2)}',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: AppSizes.sm),
                                      IconButton(
                                        onPressed: () {
                                          invoiceProvider.removeProduct(selectedProduct.product.id!);
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Discount Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.discount,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Discount (Optional)',
                                    style: AppTextStyles.h6.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.md),

                              // Discount type toggle
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text('Flat Amount'),
                                      value: false,
                                      groupValue: _isPercentageDiscount,
                                      onChanged: (value) {
                                        setState(() {
                                          _isPercentageDiscount = value!;
                                          _discountController.clear();
                                        });
                                        invoiceProvider.clearDiscount();
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text('Percentage'),
                                      value: true,
                                      groupValue: _isPercentageDiscount,
                                      onChanged: (value) {
                                        setState(() {
                                          _isPercentageDiscount = value!;
                                          _discountController.clear();
                                        });
                                        invoiceProvider.clearDiscount();
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSizes.md),

                              // Discount input
                              TextField(
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _isPercentageDiscount ? 'Discount Percentage' : 'Discount Amount',
                                  hintText: _isPercentageDiscount ? 'Enter percentage (0-100)' : 'Enter amount',
                                  prefixIcon: Icon(_isPercentageDiscount ? Icons.percent : Icons.currency_rupee),
                                  border: const OutlineInputBorder(),
                                  suffixText: _isPercentageDiscount ? '%' : '₹',
                                ),
                                onChanged: (value) {
                                  _updateDiscount();
                                },
                              ),

                              if (invoiceProvider.calculatedDiscountAmount > 0) ...[
                                const SizedBox(height: AppSizes.sm),
                                Container(
                                  padding: const EdgeInsets.all(AppSizes.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 16,
                                      ),
                                      const SizedBox(width: AppSizes.sm),
                                      Text(
                                        'Discount Applied: ₹${invoiceProvider.calculatedDiscountAmount.toStringAsFixed(2)}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.success,
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
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Invoice Summary
                      Card(
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

                              // Summary rows
                              _buildSummaryRow('Subtotal', '₹${invoiceProvider.subtotal.toStringAsFixed(2)}'),
                              if (invoiceProvider.calculatedDiscountAmount > 0)
                                _buildSummaryRow(
                                  'Discount',
                                  '-₹${invoiceProvider.calculatedDiscountAmount.toStringAsFixed(2)}',
                                  isDiscount: true,
                                ),
                              const Divider(),
                              _buildSummaryRow(
                                'Total Amount',
                                '₹${invoiceProvider.totalAmount.toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom section with next button
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Amount: ₹${invoiceProvider.totalAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToCustomerDetails,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                        ),
                        child: const Text('Next - Customer Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ), // Consumer
    ), // SafeArea
  ); // Scaffold
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  )
                : isDiscount
                    ? AppTextStyles.bodyMedium.copyWith(color: AppColors.error)
                    : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}