class Product {
  final String? id;
  final String name;
  final String? description;
  final String category;
  final double price;
  final double cost;
  final String unit;
  final String? sku;
  final String? brand;
  final String? weight;
  final String? dimensions;
  final String? barcode;
  final DateTime? expiryDate;
  final double? unitCapacity; // For bottles, boxes, packets - defines how much they contain
  final String? capacityUnit; // Unit for the capacity (ml for bottles, pcs for boxes)
  final double taxRate;
  final bool isActive;
  final int stockQuantity;
  final int minimumStock;
  final String? businessId;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Virtual properties
  double get profitMargin {
    if (cost > 0) {
      return ((price - cost) / cost * 100);
    }
    return 0;
  }

  double get taxAmount => price * taxRate / 100;

  double get priceIncludingTax => price + taxAmount;

  bool get isLowStock => stockQuantity <= minimumStock;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.cost = 0,
    this.unit = 'piece',
    this.sku,
    this.brand,
    this.weight,
    this.dimensions,
    this.barcode,
    this.expiryDate,
    this.unitCapacity,
    this.capacityUnit,
    this.taxRate = 0,
    this.isActive = true,
    this.stockQuantity = 0,
    this.minimumStock = 0,
    this.businessId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'piece',
      sku: json['sku'],
      brand: json['brand'],
      weight: json['weight'],
      dimensions: json['dimensions'],
      barcode: json['barcode'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      unitCapacity: json['unitCapacity']?.toDouble(),
      capacityUnit: json['capacityUnit'],
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      minimumStock: json['minimumStock'] ?? 0,
      businessId: json['businessId'],
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'cost': cost,
      'unit': unit,
      'sku': sku,
      'brand': brand,
      'weight': weight,
      'dimensions': dimensions,
      'barcode': barcode,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      'unitCapacity': unitCapacity,
      'capacityUnit': capacityUnit,
      'taxRate': taxRate,
      'isActive': isActive,
      'stockQuantity': stockQuantity,
      'minimumStock': minimumStock,
      'businessId': businessId,
      'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    double? cost,
    String? unit,
    String? sku,
    String? brand,
    String? weight,
    String? dimensions,
    String? barcode,
    DateTime? expiryDate,
    double? unitCapacity,
    String? capacityUnit,
    double? taxRate,
    bool? isActive,
    int? stockQuantity,
    int? minimumStock,
    String? businessId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      unit: unit ?? this.unit,
      sku: sku ?? this.sku,
      brand: brand ?? this.brand,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      barcode: barcode ?? this.barcode,
      expiryDate: expiryDate ?? this.expiryDate,
      unitCapacity: unitCapacity ?? this.unitCapacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      taxRate: taxRate ?? this.taxRate,
      isActive: isActive ?? this.isActive,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minimumStock: minimumStock ?? this.minimumStock,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, category: $category, price: $price, stockQuantity: $stockQuantity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ProductListResponse {
  final List<Product> products;
  final ProductPagination pagination;

  ProductListResponse({
    required this.products,
    required this.pagination,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
      pagination: ProductPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class ProductPagination {
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final bool hasNextPage;
  final bool hasPrevPage;

  ProductPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalProducts,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory ProductPagination.fromJson(Map<String, dynamic> json) {
    return ProductPagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalProducts: json['totalProducts'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}