import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../config/app_theme.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart';
import '../invoice/invoice_create_screen.dart';

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

  void _sendInvoice() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final business = authProvider.user?.businessInfo;
    
    try {
      // Create invoice message for WhatsApp
      final invoiceMessage = _createInvoiceMessage(business);
      
      // Format customer mobile number for WhatsApp
      String customerMobile = widget.invoice.customer.mobileNumber;
      if (customerMobile.startsWith('0')) {
        customerMobile = customerMobile.substring(1);
      }
      if (!customerMobile.startsWith('+91')) {
        customerMobile = '+91$customerMobile';
      }
      
      // Create WhatsApp URL
      final whatsappUrl = 'https://wa.me/$customerMobile?text=${Uri.encodeComponent(invoiceMessage)}';
      
      // Try to launch WhatsApp
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening WhatsApp to send invoice...'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Fallback to share
        await Share.share(
          invoiceMessage,
          subject: 'Invoice ${widget.invoice.invoiceNumber}',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp not available. Using system share...'),
              backgroundColor: AppColors.info,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invoice: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _createInvoiceMessage(businessInfo) {
    final businessName = businessInfo?.businessName ?? 'Business';
    final customerName = widget.invoice.customer.name;
    final invoiceNumber = widget.invoice.invoiceNumber;
    final totalAmount = widget.invoice.totalAmount;
    final invoiceDate = DateFormat('dd/MM/yyyy').format(widget.invoice.invoiceDate);
    
    final itemsList = widget.invoice.items.map((item) => 
      '• ${item.productName} x${item.quantity} = ₹${item.total.toStringAsFixed(2)}'
    ).join('\n');
    
    return '''🧾 *INVOICE* 🧾

Dear $customerName,

Thank you for your purchase from *$businessName*!

📋 *Invoice Details:*
Invoice No: $invoiceNumber
Date: $invoiceDate

🛒 *Items:*
$itemsList

💰 *Total Amount: ₹${totalAmount.toStringAsFixed(2)}*

${widget.invoice.discountAmount > 0 ? '🎯 Discount Applied: ₹${widget.invoice.discountAmount.toStringAsFixed(2)}\n' : ''}

Payment Method: ${widget.invoice.paymentMethod == PaymentMethod.cash ? '💵 Cash' : '💳 Online Payment'}

Thank you for choosing us! 🙏

Best regards,
$businessName''';
  }

  void _printInvoice() async {
    try {
      // Generate PDF for printing
      final pdfBytes = await _generateInvoicePDF();
      
      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Invoice_${widget.invoice.invoiceNumber}',
        format: PdfPageFormat.roll80, // Thermal printer format (80mm width)
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice sent to printer successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print invoice: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateInvoicePDF() async {
    final pdf = pw.Document();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final business = authProvider.user?.businessInfo;
    
    // Load fonts for Gujarati support
    pw.Font? gujaratiFont;
    pw.Font? gujaratiFontBold;
    
    try {
      final gujaratiRegularBytes = await rootBundle.load('assets/fonts/NotoSansGujarati-Regular.ttf');
      gujaratiFont = pw.Font.ttf(gujaratiRegularBytes);
      
      final gujaratiBoldBytes = await rootBundle.load('assets/fonts/NotoSansGujarati-Bold.ttf');
      gujaratiFontBold = pw.Font.ttf(gujaratiBoldBytes);
    } catch (e) {
      print('Error loading Gujarati fonts: $e');
      // Continue with default fonts if Gujarati fonts fail to load
    }
    
    // Helper function to create text style with Gujarati font support
    pw.TextStyle createTextStyle({
      double fontSize = 10,
      bool isBold = false,
      String? text,
    }) {
      // Check if text contains Gujarati characters
      bool hasGujarati = text != null && RegExp(r'[\u0A80-\u0AFF]').hasMatch(text);
      
      if (hasGujarati && gujaratiFont != null) {
        return pw.TextStyle(
          font: isBold && gujaratiFontBold != null ? gujaratiFontBold : gujaratiFont,
          fontSize: fontSize,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        );
      } else {
        return pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        );
      }
    }
    
    // Helper function to create mixed content with proper font handling
    List<pw.InlineSpan> createMixedText(String text, {double fontSize = 10, bool isBold = false}) {
      List<pw.InlineSpan> spans = [];
      
      // Replace rupee symbol with Rs. for better PDF compatibility
      text = text.replaceAll('₹', 'Rs.');
      
      // Split text into Gujarati and non-Gujarati parts
      final gujaratiRegex = RegExp(r'[\u0A80-\u0AFF]+');
      int lastEnd = 0;
      
      for (final match in gujaratiRegex.allMatches(text)) {
        // Add non-Gujarati text before this match
        if (match.start > lastEnd) {
          String nonGujarati = text.substring(lastEnd, match.start);
          if (nonGujarati.isNotEmpty) {
            spans.add(pw.TextSpan(
              text: nonGujarati,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ));
          }
        }
        
        // Add Gujarati text with Gujarati font
        String gujaratiText = text.substring(match.start, match.end);
        spans.add(pw.TextSpan(
          text: gujaratiText,
          style: pw.TextStyle(
            font: isBold && gujaratiFontBold != null ? gujaratiFontBold : gujaratiFont,
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ));
        
        lastEnd = match.end;
      }
      
      // Add remaining non-Gujarati text
      if (lastEnd < text.length) {
        String remaining = text.substring(lastEnd);
        if (remaining.isNotEmpty) {
          spans.add(pw.TextSpan(
            text: remaining,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ));
        }
      }
      
      // If no Gujarati text found, return single span with default font
      if (spans.isEmpty) {
        spans.add(pw.TextSpan(
          text: text,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ));
      }
      
      return spans;
    }
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Business Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: createMixedText(business?.businessName ?? 'Business Name', fontSize: 16, isBold: true),
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    if (business?.businessAddress != null) ...[
                      pw.SizedBox(height: 4),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: createMixedText(business!.businessAddress.fullAddress, fontSize: 10),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                    if (business?.contactDetails?.phone != null) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Phone: ${business!.contactDetails!.phone}',
                        style: createTextStyle(fontSize: 10),
                      ),
                    ],
                    if (business?.gstNumber != null) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'GST: ${business!.gstNumber ?? 'N/A'}',
                        style: createTextStyle(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              
              pw.SizedBox(height: 16),
              pw.Divider(),
              
              // Invoice Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Invoice: ${widget.invoice.invoiceNumber}',
                    style: createTextStyle(),
                  ),
                  pw.Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(widget.invoice.invoiceDate)}',
                    style: createTextStyle(),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 8),
              
              // Customer Details
              pw.Text(
                'Bill To:', 
                style: createTextStyle(isBold: true)
              ),
              pw.RichText(
                text: pw.TextSpan(
                  children: createMixedText(widget.invoice.customer.name),
                ),
              ),
              pw.Text(
                'Mobile: ${widget.invoice.customer.mobileNumber}',
                style: createTextStyle(),
              ),
              
              pw.SizedBox(height: 12),
              pw.Divider(),
              
              // Items
              pw.Text(
                'Items:', 
                style: createTextStyle(isBold: true)
              ),
              pw.SizedBox(height: 4),
              
              ...widget.invoice.items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: createMixedText('${item.productName} x${item.quantity}'),
                        ),
                      ),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: createMixedText('₹${item.total.toStringAsFixed(2)}'),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              
              pw.SizedBox(height: 8),
              pw.Divider(),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal:',
                    style: createTextStyle(),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: createMixedText('₹${widget.invoice.subtotal.toStringAsFixed(2)}'),
                    ),
                  ),
                ],
              ),
              
              if (widget.invoice.discountAmount > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Discount:',
                      style: createTextStyle(),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: createMixedText('-₹${widget.invoice.discountAmount.toStringAsFixed(2)}'),
                      ),
                    ),
                  ],
                ),
              ],
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 2),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: createTextStyle(isBold: true),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: createMixedText('₹${widget.invoice.totalAmount.toStringAsFixed(2)}', isBold: true),
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 12),
              pw.Divider(),
              
              // Payment Method
              pw.Text(
                'Payment: ${widget.invoice.paymentMethod == PaymentMethod.cash ? 'Cash' : 'Online'}',
                style: createTextStyle(),
              ),
              
              pw.SizedBox(height: 16),
              
              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for your business!',
                      style: createTextStyle(isBold: true),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: createTextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  void _createNewInvoice() {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    invoiceProvider.resetInvoiceCreation();
    
    // Navigate to invoice create screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const InvoiceCreateScreen(),
      ),
      (route) => route.isFirst,
    );
  }

  String _generateUpiLink(String upiId, double amount, String invoiceNumber) {
    return 'upi://pay?pa=$upiId&am=${amount.toStringAsFixed(2)}&tn=Invoice%20$invoiceNumber&cu=INR';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.invoiceGenerated,
        actions: [
          IconButton(
            onPressed: _togglePreviewMode,
            icon: Icon(_isPreviewMode ? Icons.fullscreen : Icons.fullscreen_exit),
            tooltip: _isPreviewMode ? localizations.fullScreen : localizations.exitFullScreen,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
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
                      label: Text(localizations.send),
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
                      label: Text(localizations.print),
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
                      _buildCustomerSection(context),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Items table
                      _buildItemsTable(context),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Totals
                      _buildTotalsSection(context),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Payment method and QR code
                      _buildPaymentSection(context),
                      
                      const SizedBox(height: AppSizes.xl),
                      
                      // Footer
                      _buildInvoiceFooter(context),
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
                  child: Text(localizations.createNewInvoice),
                ),
              ),
            ),
          ],
        ],
        ),
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

  Widget _buildCustomerSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.billTo,
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

  Widget _buildItemsTable(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.items,
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

  Widget _buildTotalsSection(BuildContext context) {
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

  Widget _buildPaymentSection(BuildContext context) {
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

  Widget _buildInvoiceFooter(BuildContext context) {
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