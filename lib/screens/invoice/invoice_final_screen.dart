import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/custom_app_bar.dart';

class InvoiceFinalScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceFinalScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoiceFinalScreen> createState() => _InvoiceFinalScreenState();
}

class _InvoiceFinalScreenState extends State<InvoiceFinalScreen> {
  bool _isPreviewMode = true;

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  void _sendInvoice() {
    // TODO: Implement send invoice functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Send invoice functionality will be implemented'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _printInvoice() {
    // TODO: Implement print invoice functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print invoice functionality will be implemented'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _createNewInvoice() {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    invoiceProvider.resetInvoiceCreation();
    
    // Navigate back to the beginning
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _generateUpiLink(String upiId, double amount, String invoiceNumber) {
    return 'upi://pay?pa=$upiId&am=${amount.toStringAsFixed(2)}&tn=Invoice%20$invoiceNumber&cu=INR';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Invoice Generated',
        actions: [
          IconButton(
            onPressed: _togglePreviewMode,
            icon: Icon(_isPreviewMode ? Icons.fullscreen : Icons.fullscreen_exit),
            tooltip: _isPreviewMode ? 'Full Screen' : 'Exit Full Screen',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isPreviewMode) ...[
            // Action buttons
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sendInvoice,
                      icon: const Icon(Icons.send),
                      label: const Text('SEND'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _printInvoice,
                      icon: const Icon(Icons.print),
                      label: const Text('PRINT'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Invoice preview
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildInvoiceHeader(),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Customer details
                      _buildCustomerSection(),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Items table
                      _buildItemsTable(),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Totals
                      _buildTotalsSection(),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Payment method and QR code
                      _buildPaymentSection(),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Footer
                      _buildInvoiceFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (!_isPreviewMode) ...[
            const Divider(),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createNewInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  ),
                  child: const Text('Create New Invoice'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final business = authProvider.user?.businessInfo;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business?.businessName ?? 'Business Name',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      if (business?.businessAddress != null) ...[
                        Text(
                          business!.businessAddress.fullAddress,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                      ],
                      if (business?.contactDetails?.phone != null) ...[
                        Text(
                          'Phone: ${business!.contactDetails!.phone}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (business?.gstNumber != null) ...[
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'GST: ${business!.gstNumber}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Invoice details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'INVOICE',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      widget.invoice.invoiceNumber,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(widget.invoice.invoiceDate)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill To:',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.invoice.customer.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Mobile: ${widget.invoice.customer.mobileNumber}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items:',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        
        // Table header
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusSm),
              topRight: Radius.circular(AppSizes.radiusSm),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Product',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Qty',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Price',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  'Total',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Table rows
        ...widget.invoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;
          
          return Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: isEven ? Colors.transparent : AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'per ${item.unit}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item.quantity}',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '₹${item.total.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalsSection() {
    return Column(
      children: [
        const Divider(),
        
        // Subtotal
        _buildTotalRow('Subtotal', '₹${widget.invoice.subtotal.toStringAsFixed(2)}'),
        
        // Discount
        if (widget.invoice.discountAmount > 0) ...[
          const SizedBox(height: AppSizes.sm),
          _buildTotalRow(
            'Discount (${widget.invoice.discountType == DiscountType.percentage ? '${widget.invoice.discountPercentage}%' : 'Flat'})',
            '-₹${widget.invoice.discountAmount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
        ],
        
        const SizedBox(height: AppSizes.md),
        const Divider(thickness: 2),
        const SizedBox(height: AppSizes.sm),
        
        // Total
        _buildTotalRow(
          'Total Amount',
          '₹${widget.invoice.totalAmount.toStringAsFixed(2)}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.h6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                )
              : isDiscount
                  ? AppTextStyles.bodyMedium.copyWith(color: AppColors.error)
                  : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Information:',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.invoice.paymentMethod == PaymentMethod.cash 
                        ? Icons.money 
                        : Icons.qr_code_2,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'Payment Method: ${widget.invoice.paymentMethod == PaymentMethod.cash ? 'Cash' : 'Online (UPI)'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              // QR Code for online payment
              if (widget.invoice.paymentMethod == PaymentMethod.online) ...[
                const SizedBox(height: AppSizes.lg),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final business = authProvider.user?.businessInfo;
                    if (business?.upiId == null || business!.upiId.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Text(
                                'UPI ID not configured. Please add UPI ID in business settings.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final upiLink = _generateUpiLink(
                      business.upiId,
                      widget.invoice.totalAmount,
                      widget.invoice.invoiceNumber,
                    );

                    return Column(
                      children: [
                        Text(
                          'Scan QR Code to Pay',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: QrImageView(
                              data: upiLink,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppSizes.md),
                        
                        Text(
                          'Amount: ₹${widget.invoice.totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AppSizes.sm),
                        
                        Text(
                          'UPI ID: ${business.upiId}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceFooter() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: AppSizes.md),
        Text(
          'Thank you for your business!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Generated on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}