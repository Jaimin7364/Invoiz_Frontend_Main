import 'package:flutter/material.dart';
import 'package:invoiz_app/widgets/product_statistics_widget.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/enhanced_product_card.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await Future.wait([
      productProvider.getProducts(
        search: _searchController.text,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      ),
      productProvider.getCategories(),
    ]);
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        _loadData();
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedCategory: _selectedCategory,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        categories: Provider.of<ProductProvider>(context, listen: false).categories,
        onApply: (category, sortBy, sortOrder) {
          setState(() {
            _selectedCategory = category;
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          _loadData();
        },
      ),
    );
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditProductScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    ).then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  void _navigateToEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: product),
      ),
    ).then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Products',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadData();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ),

          // Filter Chips
          if (_selectedCategory.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedCategory),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedCategory = '';
                      });
                      _loadData();
                    },
                  ),
                ],
              ),
            ),

          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                // Show statistics if we have products and no search/filter applied
                final showStatistics = productProvider.products.isNotEmpty && 
                                     _searchController.text.isEmpty && 
                                     _selectedCategory.isEmpty;
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
                          productProvider.error!,
                          style: AppTextStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              size: 60,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Text(
                            _searchController.text.isNotEmpty 
                                ? 'No products found'
                                : 'No products yet',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            _searchController.text.isNotEmpty 
                                ? 'Try adjusting your search terms\nor clearing filters'
                                : 'Start building your inventory by\nadding your first product',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.xl),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_searchController.text.isNotEmpty || _selectedCategory.isNotEmpty) ...[
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _selectedCategory = '';
                                    });
                                    _loadData();
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear Filters'),
                                ),
                                const SizedBox(width: AppSizes.md),
                              ],
                              ElevatedButton.icon(
                                onPressed: _navigateToAddProduct,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Product'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.lg,
                                    vertical: AppSizes.md,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          if (_searchController.text.isEmpty && _selectedCategory.isEmpty) ...[
                            const SizedBox(height: AppSizes.xl),
                            
                            // Quick tips
                            Container(
                              padding: const EdgeInsets.all(AppSizes.lg),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(color: AppColors.primaryLight),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Quick Tips',
                                    style: AppTextStyles.h6.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  ...[
                                    'Add product details like SKU, barcode, and descriptions',
                                    'Set up stock levels and low stock alerts',
                                    'Organize products by categories',
                                    'Track costs and profit margins',
                                  ].map((tip) => Padding(
                                    padding: const EdgeInsets.only(bottom: AppSizes.xs),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: AppSizes.sm),
                                        Expanded(
                                          child: Text(
                                            tip,
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: CustomScrollView(
                    slivers: [
                      // Statistics (shown when no search/filter is active)
                      if (showStatistics)
                        SliverToBoxAdapter(
                          child: ProductStatisticsWidget(
                            products: productProvider.products,
                          ),
                        ),
                      
                      // Product Grid/List
                      SliverPadding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        sliver: _isGridView
                            ? _buildSliverGridView(productProvider.products)
                            : _buildSliverListView(productProvider.products),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSliverListView(List<Product> products) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: EnhancedProductCard(
              product: product,
              isGridView: false,
              onTap: () => _navigateToProductDetail(product),
              onEdit: () => _navigateToEditProduct(product),
              onDelete: () => _showDeleteDialog(product),
            ),
          );
        },
        childCount: products.length,
      ),
    );
  }

  Widget _buildSliverGridView(List<Product> products) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return EnhancedProductCard(
            product: product,
            isGridView: true,
            onTap: () => _navigateToProductDetail(product),
            onEdit: () => _navigateToEditProduct(product),
            onDelete: () => _showDeleteDialog(product),
          );
        },
        childCount: products.length,
      ),
    );
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              final success = await productProvider.deleteProduct(product.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(productProvider.error ?? 'Failed to delete product'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }


}

class _FilterDialog extends StatefulWidget {
  final String selectedCategory;
  final String sortBy;
  final String sortOrder;
  final List<String> categories;
  final Function(String category, String sortBy, String sortOrder) onApply;

  const _FilterDialog({
    required this.selectedCategory,
    required this.sortBy,
    required this.sortOrder,
    required this.categories,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String _selectedCategory;
  late String _sortBy;
  late String _sortOrder;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _sortBy = widget.sortBy;
    _sortOrder = widget.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter & Sort'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Filter
            const Text(
              'Category',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppSizes.sm),
            DropdownButtonFormField<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              decoration: const InputDecoration(
                hintText: 'All Categories',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...widget.categories.map((category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? '';
                });
              },
            ),
            const SizedBox(height: AppSizes.lg),

            // Sort Options
            const Text(
              'Sort By',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppSizes.sm),
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'createdAt', child: Text('Date Created')),
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'price', child: Text('Price')),
                DropdownMenuItem(value: 'stockQuantity', child: Text('Stock')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
            const SizedBox(height: AppSizes.md),

            // Sort Order
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Ascending'),
                    value: 'asc',
                    groupValue: _sortOrder,
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Descending'),
                    value: 'desc',
                    groupValue: _sortOrder,
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onApply(_selectedCategory, _sortBy, _sortOrder);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}