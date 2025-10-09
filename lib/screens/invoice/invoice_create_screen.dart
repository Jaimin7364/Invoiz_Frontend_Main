import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'invoice_preview_screen.dart';

class InvoiceCreateScreen extends StatefulWidget {
  const InvoiceCreateScreen({super.key});

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
      _setupStockUpdateCallback();
    });
  }

  void _setupStockUpdateCallback() {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Set up callback for stock updates
    invoiceProvider.setStockUpdateCallback((stockUpdates) {
      productProvider.updateProductStockAfterInvoice(stockUpdates);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    // Always reload products to ensure we get the latest user-specific products
    // Load user's products with high limit to get all products for invoice creation
    await productProvider.getProducts(page: 1, limit: 100);
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  void _showQuantityDialog(Product product) {
    final TextEditingController quantityController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price: ₹${product.price.toStringAsFixed(2)}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              if (quantity > 0) {
                final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
                invoiceProvider.addProduct(product, quantity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to invoice'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InvoicePreviewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Create Invoice',
        actions: [
          IconButton(
            onPressed: _refreshProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Products',
          ),
          Consumer<InvoiceProvider>(
            builder: (context, invoiceProvider, child) {
              if (invoiceProvider.hasSelectedProducts) {
                return IconButton(
                  onPressed: _navigateToPreview,
                  icon: const Icon(Icons.preview),
                  tooltip: 'Preview Invoice',
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected products summary
          Consumer<InvoiceProvider>(
            builder: (context, invoiceProvider, child) {
              if (!invoiceProvider.hasSelectedProducts) {
                return const SizedBox();
              }

              return Container(
                padding: const EdgeInsets.all(AppSizes.md),
                margin: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'Selected Products (${invoiceProvider.selectedProducts.length})',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total: ₹${invoiceProvider.subtotal.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: invoiceProvider.selectedProductsList.length,
                        itemBuilder: (context, index) {
                          final selectedProduct = invoiceProvider.selectedProductsList[index];
                          return Container(
                            margin: const EdgeInsets.only(right: AppSizes.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${selectedProduct.product.name} (${selectedProduct.quantity})',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                GestureDetector(
                                  onTap: () {
                                    invoiceProvider.removeProduct(selectedProduct.product.id!);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Search bar and product count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                
                // Product count indicator
                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    if (productProvider.products.isNotEmpty) {
                      final filteredCount = _searchController.text.isNotEmpty
                          ? productProvider.products.where((product) {
                              final query = _searchController.text.toLowerCase();
                              return product.name.toLowerCase().contains(query) ||
                                  product.category.toLowerCase().contains(query) ||
                                  (product.description?.toLowerCase().contains(query) ?? false);
                            }).length
                          : productProvider.products.length;
                      
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: AppSizes.sm),
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? 'Showing $filteredCount of ${productProvider.products.length} products'
                              : '${productProvider.products.length} products in your account',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Products list
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading && productProvider.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (productProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'Failed to load your products',
                          style: AppTextStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          productProvider.error!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        ElevatedButton(
                          onPressed: _refreshProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'No products in your account',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Add some products to your account first to create invoices',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to add products screen
                            Navigator.pop(context); // Go back to dashboard
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Products'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter products based on search
                var filteredProducts = productProvider.products;
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  filteredProducts = productProvider.products.where((product) {
                    return product.name.toLowerCase().contains(query) ||
                        product.category.toLowerCase().contains(query) ||
                        (product.description?.toLowerCase().contains(query) ?? false);
                  }).toList();
                }

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'No products found',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Try searching with different keywords from your product inventory',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.md),
                        child: InvoiceProductCard(
                          product: product,
                          onTap: () => _showQuantityDialog(product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          if (!invoiceProvider.hasSelectedProducts) {
            return const SizedBox();
          }

          return FloatingActionButton.extended(
            onPressed: _navigateToPreview,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          );
        },
      ),
    );
  }
}

class InvoiceProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const InvoiceProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              // Product icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  _getProductIcon(product.category),
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: AppSizes.md),
              
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      product.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' per ${product.unit}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Stock info and add button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: product.stockQuantity > 0 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                    ),
                    child: Text(
                      'Stock: ${product.stockQuantity}',
                      style: AppTextStyles.caption.copyWith(
                        color: product.stockQuantity > 0 
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ElevatedButton(
                    onPressed: product.stockQuantity > 0 ? onTap : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(60, 36),
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    ),
                    child: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'clothing':
      case 'fashion':
        return Icons.checkroom;
      case 'food':
        return Icons.restaurant;
      case 'beverages':
        return Icons.local_drink;
      case 'books':
      case 'education':
        return Icons.menu_book;
      case 'health':
      case 'medicine':
        return Icons.local_pharmacy;
      case 'home':
      case 'furniture':
        return Icons.home;
      case 'sports':
        return Icons.sports_soccer;
      case 'beauty':
      case 'cosmetics':
        return Icons.face;
      case 'automotive':
        return Icons.directions_car;
      case 'toys':
        return Icons.toys;
      default:
        return Icons.inventory_2;
    }
  }
}