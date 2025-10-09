import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Callback for notifying product stock updates
  Function(List<Map<String, dynamic>>)? onStockUpdated;

  // Current invoice being created
  Invoice? _currentInvoice;
  
  // Selected products for invoice
  final Map<String, SelectedProduct> _selectedProducts = {};
  
  // Customer info
  CustomerInfo? _customerInfo;
  
  // Discount settings
  double _discountAmount = 0;
  DiscountType _discountType = DiscountType.flat;
  double _discountPercentage = 0;
  
  // Payment method
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  
  // Loading and error states
  bool _isLoading = false;
  String? _error;
  
  // Invoice list
  List<Invoice> _invoices = [];

  // Set stock update callback
  void setStockUpdateCallback(Function(List<Map<String, dynamic>>) callback) {
    onStockUpdated = callback;
  }

  // Getters
  Invoice? get currentInvoice => _currentInvoice;
  Map<String, SelectedProduct> get selectedProducts => Map.unmodifiable(_selectedProducts);
  CustomerInfo? get customerInfo => _customerInfo;
  double get discountAmount => _discountAmount;
  DiscountType get discountType => _discountType;
  double get discountPercentage => _discountPercentage;
  PaymentMethod get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Invoice> get invoices => List.unmodifiable(_invoices);

  // Computed properties
  List<SelectedProduct> get selectedProductsList => _selectedProducts.values.toList();
  
  double get subtotal {
    return _selectedProducts.values.fold(0.0, (sum, product) => sum + product.total);
  }
  
  double get calculatedDiscountAmount {
    if (_discountType == DiscountType.percentage) {
      return (subtotal * _discountPercentage) / 100;
    }
    return _discountAmount;
  }
  
  double get totalAmount {
    return subtotal - calculatedDiscountAmount;
  }
  
  bool get hasSelectedProducts => _selectedProducts.isNotEmpty;
  bool get hasCustomerInfo => _customerInfo != null;
  bool get canCreateInvoice => hasSelectedProducts && hasCustomerInfo;

  // Invoice number generation
  String generateInvoiceNumber() {
    final now = DateTime.now();
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Product selection methods
  void addProduct(Product product, int quantity) {
    final productId = product.id!;
    final total = product.price * quantity;
    
    _selectedProducts[productId] = SelectedProduct(
      product: product,
      quantity: quantity,
      total: total,
    );
    
    notifyListeners();
  }

  void updateProductQuantity(String productId, int quantity) {
    if (_selectedProducts.containsKey(productId)) {
      final selectedProduct = _selectedProducts[productId]!;
      final total = selectedProduct.product.price * quantity;
      
      _selectedProducts[productId] = selectedProduct.copyWith(
        quantity: quantity,
        total: total,
      );
      
      notifyListeners();
    }
  }

  void removeProduct(String productId) {
    _selectedProducts.remove(productId);
    notifyListeners();
  }

  void clearSelectedProducts() {
    _selectedProducts.clear();
    notifyListeners();
  }

  // Customer info methods
  void setCustomerInfo(String name, String mobileNumber) {
    _customerInfo = CustomerInfo(
      name: name,
      mobileNumber: mobileNumber,
    );
    notifyListeners();
  }

  void clearCustomerInfo() {
    _customerInfo = null;
    notifyListeners();
  }

  // Discount methods
  void setFlatDiscount(double amount) {
    _discountType = DiscountType.flat;
    _discountAmount = amount;
    _discountPercentage = 0;
    notifyListeners();
  }

  void setPercentageDiscount(double percentage) {
    _discountType = DiscountType.percentage;
    _discountPercentage = percentage;
    _discountAmount = 0;
    notifyListeners();
  }

  void clearDiscount() {
    _discountAmount = 0;
    _discountPercentage = 0;
    _discountType = DiscountType.flat;
    notifyListeners();
  }

  // Payment method
  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  // Create invoice
  Future<Invoice?> createInvoice() async {
    if (!canCreateInvoice) {
      _setError('Cannot create invoice: missing products or customer info');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      // Convert selected products to invoice items
      final invoiceItems = _selectedProducts.values.map((selectedProduct) {
        return {
          'productId': selectedProduct.product.id!,
          'productName': selectedProduct.product.name,
          'price': selectedProduct.product.price,
          'quantity': selectedProduct.quantity,
          'unit': selectedProduct.product.unit,
          'total': selectedProduct.total,
        };
      }).toList();

      // Prepare invoice data for API
      final invoiceData = {
        'items': invoiceItems,
        'customerInfo': {
          'name': _customerInfo!.name,
          'mobileNumber': _customerInfo!.mobileNumber,
        },
        'totalAmount': totalAmount,
        'paymentMethod': _paymentMethod.toString().split('.').last,
        'discountAmount': calculatedDiscountAmount,
        'discountType': _discountType.toString().split('.').last,
      };

      // Call API to create invoice and update stock
      final response = await _apiService.post('/invoices/create', data: invoiceData);

      if (response.data['success'] == true) {
        final invoiceData = response.data['data']['invoice'];
        final stockUpdates = response.data['data']['stockUpdates'] as List<dynamic>;

        // Create invoice object from response
        final invoice = Invoice(
          invoiceNumber: invoiceData['invoiceNumber'],
          invoiceDate: DateTime.parse(invoiceData['invoiceDate']),
          customer: _customerInfo!,
          items: _selectedProducts.values.map((selectedProduct) {
            return InvoiceItem(
              productId: selectedProduct.product.id!,
              productName: selectedProduct.product.name,
              price: selectedProduct.product.price,
              quantity: selectedProduct.quantity,
              unit: selectedProduct.product.unit,
              total: selectedProduct.total,
            );
          }).toList(),
          subtotal: subtotal,
          discountAmount: calculatedDiscountAmount,
          discountType: _discountType,
          discountPercentage: _discountPercentage,
          totalAmount: totalAmount,
          paymentMethod: _paymentMethod,
          paymentStatus: PaymentStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Store invoice
        _currentInvoice = invoice;
        _invoices.insert(0, invoice);

        // Notify about stock updates
        if (onStockUpdated != null) {
          onStockUpdated!(stockUpdates.cast<Map<String, dynamic>>());
        }

        // Notify listeners about stock updates so ProductProvider can refresh
        notifyListeners();

        // Show success message with stock update info
        final updatedProducts = stockUpdates.map((update) => 
          '${update['productName']}: ${update['oldStock']} → ${update['newStock']}'
        ).join(', ');
        
        debugPrint('Invoice created successfully! Stock updated for: $updatedProducts');

        return invoice;
      } else {
        _setError(response.data['message'] ?? 'Failed to create invoice');
        return null;
      }
    } catch (e) {
      if (e.toString().contains('Insufficient stock')) {
        _setError('Some products don\'t have enough stock. Please check quantities and try again.');
      } else {
        _setError('Failed to create invoice: ${e.toString()}');
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Reset invoice creation process
  void resetInvoiceCreation() {
    _currentInvoice = null;
    _selectedProducts.clear();
    _customerInfo = null;
    _discountAmount = 0;
    _discountPercentage = 0;
    _discountType = DiscountType.flat;
    _paymentMethod = PaymentMethod.cash;
    _clearError();
    notifyListeners();
  }

  // Get invoice by ID
  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  // Load invoices (placeholder for API integration)
  Future<void> loadInvoices() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement API call to load invoices
      // final response = await _apiService.get('/invoices');
      // if (response.data['success'] == true) {
      //   _invoices = (response.data['data'] as List)
      //       .map((item) => Invoice.fromJson(item))
      //       .toList();
      // }
    } catch (e) {
      _setError('Failed to load invoices: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Clear all data (useful for logout)
  void clearData() {
    _currentInvoice = null;
    _selectedProducts.clear();
    _customerInfo = null;
    _discountAmount = 0;
    _discountPercentage = 0;
    _discountType = DiscountType.flat;
    _paymentMethod = PaymentMethod.cash;
    _isLoading = false;
    _error = null;
    _invoices.clear();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

// Helper class for selected products
class SelectedProduct {
  final Product product;
  final int quantity;
  final double total;

  SelectedProduct({
    required this.product,
    required this.quantity,
    required this.total,
  });

  SelectedProduct copyWith({
    Product? product,
    int? quantity,
    double? total,
  }) {
    return SelectedProduct(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }

  @override
  String toString() {
    return 'SelectedProduct{product: ${product.name}, quantity: $quantity, total: $total}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedProduct &&
        other.product.id == product.id &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(product.id, quantity);
}