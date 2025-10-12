import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/product_provider.dart';

class ProvidersCoordinator {
  static void setupProviderCallbacks(BuildContext context) {
    final invoiceProvider = context.read<InvoiceProvider>();
    final reportsProvider = context.read<ReportsProvider>();
    final productProvider = context.read<ProductProvider>();

    // Set up invoice creation callback for reports
    invoiceProvider.setInvoiceCreatedCallback((invoice) async {
      try {
        // Get all products for calculation
        final products = productProvider.products;
        await reportsProvider.updateReportsWithInvoice(invoice, products);
      } catch (e) {
        debugPrint('Error updating reports with new invoice: $e');
      }
    });

    // Set up stock update callback
    invoiceProvider.setStockUpdateCallback((stockUpdates) {
      // This callback is already being used for product stock updates
      // We can add any additional logic here if needed
    });
  }
}