class Invoice {
  final String? id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final CustomerInfo customer;
  final List<InvoiceItem> items;
  final double subtotal;
  final double discountAmount;
  final DiscountType discountType;
  final double discountPercentage;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? businessId;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customer,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0,
    this.discountType = DiscountType.flat,
    this.discountPercentage = 0,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.businessId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] ?? json['id'],
      invoiceNumber: json['invoiceNumber'] ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate'] ?? DateTime.now().toIso8601String()),
      customer: CustomerInfo.fromJson(json['customer'] ?? {}),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => InvoiceItem.fromJson(item))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      discountType: DiscountType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['discountType'] ?? 'flat'),
        orElse: () => DiscountType.flat,
      ),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == (json['paymentMethod'] ?? 'cash'),
        orElse: () => PaymentMethod.cash,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['paymentStatus'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      businessId: json['businessId'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'customer': customer.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'discountType': discountType.toString().split('.').last,
      'discountPercentage': discountPercentage,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      if (businessId != null) 'businessId': businessId,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    CustomerInfo? customer,
    List<InvoiceItem>? items,
    double? subtotal,
    double? discountAmount,
    DiscountType? discountType,
    double? discountPercentage,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? businessId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType ?? this.discountType,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InvoiceItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;
  final double total;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'piece',
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'total': total,
    };
  }

  InvoiceItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? unit,
    double? total,
  }) {
    return InvoiceItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      total: total ?? this.total,
    );
  }
}

class CustomerInfo {
  final String name;
  final String mobileNumber;

  CustomerInfo({
    required this.name,
    required this.mobileNumber,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobileNumber': mobileNumber,
    };
  }

  CustomerInfo copyWith({
    String? name,
    String? mobileNumber,
  }) {
    return CustomerInfo(
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }
}

enum DiscountType { flat, percentage }

enum PaymentMethod { cash, online }

enum PaymentStatus { pending, completed, failed }

// Helper class for building invoices
class InvoiceBuilder {
  String _invoiceNumber = '';
  DateTime _invoiceDate = DateTime.now();
  CustomerInfo? _customer;
  List<InvoiceItem> _items = [];
  double _discountAmount = 0;
  DiscountType _discountType = DiscountType.flat;
  double _discountPercentage = 0;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  InvoiceBuilder setInvoiceNumber(String invoiceNumber) {
    _invoiceNumber = invoiceNumber;
    return this;
  }

  InvoiceBuilder setInvoiceDate(DateTime invoiceDate) {
    _invoiceDate = invoiceDate;
    return this;
  }

  InvoiceBuilder setCustomer(CustomerInfo customer) {
    _customer = customer;
    return this;
  }

  InvoiceBuilder addItem(InvoiceItem item) {
    _items.add(item);
    return this;
  }

  InvoiceBuilder setItems(List<InvoiceItem> items) {
    _items = items;
    return this;
  }

  InvoiceBuilder setDiscount(double amount, DiscountType type) {
    _discountAmount = amount;
    _discountType = type;
    return this;
  }

  InvoiceBuilder setDiscountPercentage(double percentage) {
    _discountPercentage = percentage;
    _discountType = DiscountType.percentage;
    return this;
  }

  InvoiceBuilder setPaymentMethod(PaymentMethod paymentMethod) {
    _paymentMethod = paymentMethod;
    return this;
  }

  Invoice build() {
    if (_customer == null) {
      throw Exception('Customer information is required');
    }
    if (_items.isEmpty) {
      throw Exception('At least one item is required');
    }

    final subtotal = _items.fold<double>(0, (sum, item) => sum + item.total);
    double discountAmount = _discountAmount;
    
    if (_discountType == DiscountType.percentage) {
      discountAmount = (subtotal * _discountPercentage) / 100;
    }

    final totalAmount = subtotal - discountAmount;

    return Invoice(
      invoiceNumber: _invoiceNumber,
      invoiceDate: _invoiceDate,
      customer: _customer!,
      items: _items,
      subtotal: subtotal,
      discountAmount: discountAmount,
      discountType: _discountType,
      discountPercentage: _discountPercentage,
      totalAmount: totalAmount,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}