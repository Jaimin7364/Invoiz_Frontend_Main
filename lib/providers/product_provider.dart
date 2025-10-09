import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  List<String> _categories = [];
  ProductPagination? _pagination;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Product> get products => _products;
  List<String> get categories => _categories;
  ProductPagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get products with filtering and pagination
  Future<void> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      
      final response = await _apiService.get('/products', queryParameters: queryParams);
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final productList = (data['products'] as List<dynamic>)
            .map((item) => Product.fromJson(item))
            .toList();
        
        if (page == 1) {
          _products = productList;
        } else {
          _products.addAll(productList);
        }
        
        _pagination = ProductPagination.fromJson(data['pagination']);
      } else {
        _setError(response.data['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      if (e is DioException) {
        _setError(ApiException.fromDioError(e).message);
      } else {
        _setError('Network error: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }
  
  // Get categories
  Future<void> getCategories() async {
    try {
      final response = await _apiService.get('/products/categories');
      
      if (response.data['success'] == true) {
        _categories = List<String>.from(response.data['data'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      // Categories are not critical, so we don't show error
      debugPrint('Failed to load categories: $e');
    }
  }
  
  // Get low stock products
  Future<List<Product>> getLowStockProducts() async {
    try {
      final response = await _apiService.get('/products/low-stock');
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List<dynamic>)
            .map((item) => Product.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load low stock products: $e');
    }
    return [];
  }
  
  // Get product by ID
  Future<Product?> getProduct(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('/products/$id');
      
      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      } else {
        _setError(response.data['message'] ?? 'Failed to load product');
      }
    } catch (e) {
      if (e is DioException) {
        _setError(ApiException.fromDioError(e).message);
      } else {
        _setError('Network error: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
    return null;
  }
  
  // Create product
  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.post('/products', data: product.toJson());
      
      if (response.data['success'] == true) {
        final newProduct = Product.fromJson(response.data['data']);
        _products.insert(0, newProduct);
        
        // Update categories if new category
        if (!_categories.contains(newProduct.category)) {
          _categories.add(newProduct.category);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.data['message'] ?? 'Failed to create product');
      }
    } catch (e) {
      if (e is DioException) {
        _setError(ApiException.fromDioError(e).message);
      } else {
        _setError('Network error: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
    return false;
  }
  
  // Update product
  Future<bool> updateProduct(String id, Product product) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.put('/products/$id', data: product.toJson());
      
      if (response.data['success'] == true) {
        final updatedProduct = Product.fromJson(response.data['data']);
        final index = _products.indexWhere((p) => p.id == id);
        
        if (index != -1) {
          _products[index] = updatedProduct;
          
          // Update categories if new category
          if (!_categories.contains(updatedProduct.category)) {
            _categories.add(updatedProduct.category);
          }
          
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.data['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      if (e is DioException) {
        _setError(ApiException.fromDioError(e).message);
      } else {
        _setError('Network error: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
    return false;
  }
  
  // Delete product
  Future<bool> deleteProduct(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.delete('/products/$id');
      
      if (response.data['success'] == true) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(response.data['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      if (e is DioException) {
        _setError(ApiException.fromDioError(e).message);
      } else {
        _setError('Network error: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
    return false;
  }
  
  // Update stock
  Future<bool> updateStock(String id, int quantity, String operation) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.post('/products/$id/update-stock', data: {
        'quantity': quantity,
        'operation': operation,
      });
      
      if (response.data['success'] == true) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            stockQuantity: response.data['data']['newStockQuantity'],
          );
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.data['message'] ?? 'Failed to update stock');
      }
    } catch (e) {
      if (e is DioException) {
        _setError(ApiException.fromDioError(e).message);
      } else {
        _setError('Network error: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
    return false;
  }
  
  // Refresh products (useful after stock changes)
  Future<void> refreshProducts() async {
    await getProducts(page: 1);
  }

  // Update local product stock (for immediate UI updates)
  void updateProductStock(String productId, int newStockQuantity) {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      final product = _products[productIndex];
      _products[productIndex] = product.copyWith(stockQuantity: newStockQuantity);
      notifyListeners();
    }
  }

  // Update multiple products stock
  void updateMultipleProductsStock(List<Map<String, dynamic>> stockUpdates) {
    for (final update in stockUpdates) {
      final productId = update['productId'] as String;
      final newStock = update['newStock'] as int;
      updateProductStock(productId, newStock);
    }
  }
  
  // Search products locally
  List<Product> searchProductsLocally(String query) {
    if (query.isEmpty) return _products;
    
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.category.toLowerCase().contains(lowercaseQuery) ||
          (product.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (product.sku?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
  
  // Filter products by category
  List<Product> filterByCategory(String category) {
    if (category.isEmpty) return _products;
    return _products.where((product) => 
        product.category.toLowerCase() == category.toLowerCase()).toList();
  }
  
  // Get products by status
  List<Product> getProductsByStatus({bool? isActive, bool? isLowStock}) {
    return _products.where((product) {
      if (isActive != null && product.isActive != isActive) return false;
      if (isLowStock != null && product.isLowStock != isLowStock) return false;
      return true;
    }).toList();
  }
  
  // Update stock quantities for multiple products after invoice creation
  void updateProductStockAfterInvoice(List<Map<String, dynamic>> stockUpdates) {
    for (var update in stockUpdates) {
      final productId = update['productId'] as String;
      final quantitySold = update['quantitySold'] as int;
      
      // Find and update the product in local list
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final product = _products[index];
        final newStockQuantity = product.stockQuantity - quantitySold;
        
        // Create updated product with new stock quantity
        _products[index] = Product(
          id: product.id,
          name: product.name,
          description: product.description,
          category: product.category,
          price: product.price,
          cost: product.cost,
          unit: product.unit,
          sku: product.sku,
          brand: product.brand,
          weight: product.weight,
          dimensions: product.dimensions,
          barcode: product.barcode,
          expiryDate: product.expiryDate,
          unitCapacity: product.unitCapacity,
          capacityUnit: product.capacityUnit,
          taxRate: product.taxRate,
          isActive: product.isActive,
          stockQuantity: newStockQuantity < 0 ? 0 : newStockQuantity, // Prevent negative quantities
          minimumStock: product.minimumStock,
          businessId: product.businessId,
          userId: product.userId,
          createdAt: product.createdAt,
          updatedAt: product.updatedAt,
        );
      }
    }
    notifyListeners();
  }
  
  // Update single product stock after sale
  void updateSingleProductStockAfterSale(String productId, int quantitySold) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = _products[index];
      final newStockQuantity = product.stockQuantity - quantitySold;
      
      _products[index] = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        category: product.category,
        price: product.price,
        cost: product.cost,
        unit: product.unit,
        sku: product.sku,
        brand: product.brand,
        weight: product.weight,
        dimensions: product.dimensions,
        barcode: product.barcode,
        expiryDate: product.expiryDate,
        unitCapacity: product.unitCapacity,
        capacityUnit: product.capacityUnit,
        taxRate: product.taxRate,
        isActive: product.isActive,
        stockQuantity: newStockQuantity < 0 ? 0 : newStockQuantity,
        minimumStock: product.minimumStock,
        businessId: product.businessId,
        userId: product.userId,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );
      notifyListeners();
    }
  }
  
  // Clear all data
  void clearData() {
    _products.clear();
    _categories.clear();
    _pagination = null;
    _clearError();
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