import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: _product),
      ),
    ).then((result) {
      if (result == true) {
        Navigator.pop(context, true);
      }
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${_product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              final success = await productProvider.deleteProduct(_product.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context, true);
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

  void _showStockUpdateDialog() {
    final TextEditingController quantityController = TextEditingController();
    String operation = 'set';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Stock: ${_product.stockQuantity}'),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                value: operation,
                decoration: const InputDecoration(
                  labelText: 'Operation',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'set', child: Text('Set to')),
                  DropdownMenuItem(value: 'add', child: Text('Add')),
                  DropdownMenuItem(value: 'subtract', child: Text('Subtract')),
                ],
                onChanged: (value) {
                  setState(() {
                    operation = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text);
                if (quantity == null || quantity < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid quantity'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                final success = await productProvider.updateStock(_product.id!, quantity, operation);
                
                if (success) {
                  // Refresh the product data
                  final updatedProduct = productProvider.products
                      .firstWhere((p) => p.id == _product.id);
                  setState(() {
                    _product = updatedProduct;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stock updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(productProvider.error ?? 'Failed to update stock'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _product.name,
        showBackButton: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              onPressed: _navigateToEdit,
              tooltip: 'Edit Product',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteDialog();
                    break;
                }
              },
              icon: const Icon(
                Icons.more_vert_outlined,
                color: AppColors.error,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.xs),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const Text(
                          'Delete Product',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Product Header with improved design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: BoxDecoration(
                gradient: _getProductGradient(_product.category),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: _getProductColor(_product.category).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced product icon with animation effect
                      Hero(
                        tag: 'product_icon_${_product.id}',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                            border: Border.all(
                              color: AppColors.surface.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getProductIcon(_product.category),
                            size: 40,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.lg),
                      
                      // Product name and details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _product.name,
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            
                            // Price badge with enhanced styling
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(
                                  color: AppColors.surface.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.currency_rupee,
                                    color: AppColors.textOnPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSizes.xs),
                                  Text(
                                    _product.price.toStringAsFixed(2),
                                    style: AppTextStyles.h5.copyWith(
                                      color: AppColors.textOnPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' / ${_product.unit}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textOnPrimary.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            
                            // Category and SKU chips
                            Wrap(
                              spacing: AppSizes.sm,
                              runSpacing: AppSizes.xs,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.sm,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                                    border: Border.all(
                                      color: AppColors.surface.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        size: 14,
                                        color: AppColors.textOnPrimary,
                                      ),
                                      const SizedBox(width: AppSizes.xs),
                                      Text(
                                        _product.category,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textOnPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_product.sku != null && _product.sku!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.sm,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                                      border: Border.all(
                                        color: AppColors.surface.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.qr_code_2_outlined,
                                          size: 14,
                                          color: AppColors.textOnPrimary,
                                        ),
                                        const SizedBox(width: AppSizes.xs),
                                        Text(
                                          _product.sku!,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textOnPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Status indicators with improved design
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: _product.isActive 
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            border: Border.all(
                              color: _product.isActive 
                                  ? AppColors.success.withOpacity(0.5)
                                  : AppColors.warning.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _product.isActive 
                                    ? Icons.check_circle_outline
                                    : Icons.pause_circle_outline,
                                color: AppColors.textOnPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Text(
                                _product.isActive ? 'Active' : 'Inactive',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_product.isLowStock) ...[
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_outlined,
                                  color: AppColors.textOnPrimary,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Text(
                                  'Low Stock',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Product description with enhanced styling
                  if (_product.description != null && _product.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: AppColors.surface.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: AppColors.textOnPrimary.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Text(
                                'Description',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textOnPrimary.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            _product.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary.withOpacity(0.95),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Enhanced Price Information Section
            _buildEnhancedInfoSection(
              'Price Information',
              Icons.attach_money_outlined,
              AppColors.success,
              [
                _buildInfoRow('Selling Price', '₹${_product.price.toStringAsFixed(2)}'),
                if (_product.cost > 0)
                  _buildInfoRow('Cost Price', '₹${_product.cost.toStringAsFixed(2)}'),
                if (_product.cost > 0)
                  _buildInfoRow('Profit Margin', '${_product.profitMargin.toStringAsFixed(2)}%'),
                if (_product.taxRate > 0) ...[
                  _buildInfoRow('Tax Rate', '${_product.taxRate.toStringAsFixed(2)}%'),
                  _buildInfoRow('Tax Amount', '₹${_product.taxAmount.toStringAsFixed(2)}'),
                  _buildInfoRow('Price (Inc. Tax)', '₹${_product.priceIncludingTax.toStringAsFixed(2)}'),
                ],
                _buildInfoRow('Unit', _product.unit),
                if (_product.brand != null && _product.brand!.isNotEmpty)
                  _buildInfoRow('Brand', _product.brand!),
                if (_product.weight != null && _product.weight!.isNotEmpty)
                  _buildInfoRow('Weight', _product.weight!),
                if (_product.dimensions != null && _product.dimensions!.isNotEmpty)
                  _buildInfoRow('Dimensions', _product.dimensions!),
              ],
            ),
            const SizedBox(height: AppSizes.xl),

            // Enhanced Inventory Information
            _buildEnhancedInventoryWidget(),
            
            // Additional Product Information
            if (_product.barcode != null && _product.barcode!.isNotEmpty ||
                _product.expiryDate != null) ...[
              const SizedBox(height: AppSizes.xl),
              _buildEnhancedInfoSection(
                'Additional Information',
                Icons.info_outline,
                AppColors.info,
                [
                  if (_product.barcode != null && _product.barcode!.isNotEmpty)
                    _buildInfoRow('Barcode', _product.barcode!),
                  if (_product.expiryDate != null)
                    _buildInfoRow(
                      'Expiry Date', 
                      '${_product.expiryDate!.day}/${_product.expiryDate!.month}/${_product.expiryDate!.year}',
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSizes.xl),

            // Enhanced Stock Management
            _buildEnhancedStockManagement(),
            const SizedBox(height: AppSizes.xl),

            // Enhanced Meta Information
            _buildEnhancedInfoSection(
              'Metadata',
              Icons.schedule_outlined,
              AppColors.textSecondary,
              [
                if (_product.createdAt != null)
                  _buildInfoRow(
                    'Created',
                    '${_product.createdAt!.day}/${_product.createdAt!.month}/${_product.createdAt!.year}',
                  ),
                if (_product.updatedAt != null)
                  _buildInfoRow(
                    'Last Updated',
                    '${_product.updatedAt!.day}/${_product.updatedAt!.month}/${_product.updatedAt!.year}',
                  ),
              ],
            ),
            
            // Bottom spacing for better scrolling
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoSection(
    String title, 
    IconData icon, 
    Color accentColor, 
    List<Widget> children
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with icon and gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLg),
                topRight: Radius.circular(AppSizes.radiusLg),
              ),
              border: Border(
                bottom: BorderSide(
                  color: accentColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content with improved spacing
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInventoryWidget() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withOpacity(0.1),
                  AppColors.info.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLg),
                topRight: Radius.circular(AppSizes.radiusLg),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.info.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    _getUnitIcon(_product.unit),
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Text(
                  'Inventory Information',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Inventory content
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                _buildInfoRow(
                  'Current Stock', 
                  '${_product.stockQuantity} ${_product.unit}',
                  isHighlighted: _product.isLowStock,
                  highlightColor: AppColors.error,
                ),
                const SizedBox(height: AppSizes.md),
                _buildInfoRow('Minimum Stock', '${_product.minimumStock} ${_product.unit}'),
                
                if (_product.unitCapacity != null && _product.capacityUnit != null) ...[
                  const SizedBox(height: AppSizes.md),
                  _buildInfoRow(
                    'Unit Capacity', 
                    '${_product.unitCapacity} ${_product.capacityUnit}',
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildInfoRow(
                    'Total Capacity',
                    '${(_product.stockQuantity * _product.unitCapacity!).toStringAsFixed(1)} ${_product.capacityUnit}',
                  ),
                ],
                
                // Low stock warning
                if (_product.isLowStock) ...[
                  const SizedBox(height: AppSizes.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.xs),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Icon(
                            Icons.warning_outlined,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Low Stock Alert',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                'Current stock is below minimum level. Consider restocking soon.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStockManagement() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLg),
                topRight: Radius.circular(AppSizes.radiusLg),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Text(
                  'Stock Management',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                // Stock action button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showStockUpdateDialog,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Update Stock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSizes.md),
                
                // Quick stock info
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory,
                              color: _product.isLowStock ? AppColors.error : AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              'In Stock',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${_product.stockQuantity}',
                              style: AppTextStyles.h6.copyWith(
                                color: _product.isLowStock ? AppColors.error : AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.warning_outlined,
                              color: AppColors.warning,
                              size: 24,
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              'Min. Level',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${_product.minimumStock}',
                              style: AppTextStyles.h6.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label, 
    String value, {
    Widget? trailing,
    bool isHighlighted = false,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.sm,
        horizontal: AppSizes.md,
      ),
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? (highlightColor ?? AppColors.primary).withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: isHighlighted 
            ? Border.all(
                color: (highlightColor ?? AppColors.primary).withOpacity(0.2),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isHighlighted 
                    ? (highlightColor ?? AppColors.primary)
                    : AppColors.textSecondary,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isHighlighted 
                          ? (highlightColor ?? AppColors.primary)
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSizes.xs),
                  trailing,
                ],
                if (isHighlighted)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSizes.xs),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: highlightColor ?? AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for unit icons
  IconData _getUnitIcon(String unit) {
    switch (unit.toLowerCase()) {
      case 'kilogram':
      case 'gram':
        return Icons.scale;
      case 'liter':
      case 'milliliter':
        return Icons.water_drop;
      case 'meter':
      case 'centimeter':
        return Icons.straighten;
      case 'bottle':
        return Icons.local_drink;
      case 'box':
      case 'packet':
        return Icons.inventory_2;
      case 'dozen':
      case 'pair':
        return Icons.apps;
      default:
        return Icons.inventory;
    }
  }

  // Helper methods for product styling
  Color _getProductColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return AppColors.info;
      case 'clothing':
      case 'fashion':
        return AppColors.secondary;
      case 'food':
      case 'beverages':
        return AppColors.success;
      case 'books':
      case 'education':
        return AppColors.accent;
      case 'health':
      case 'medicine':
        return const Color(0xFF4CAF50);
      case 'home':
      case 'furniture':
        return AppColors.warning;
      case 'sports':
        return AppColors.primary;
      case 'beauty':
      case 'cosmetics':
        return const Color(0xFFE91E63);
      case 'automotive':
        return const Color(0xFF607D8B);
      case 'toys':
        return const Color(0xFFFF5722);
      default:
        return AppColors.primary;
    }
  }

  LinearGradient _getProductGradient(String category) {
    final color = _getProductColor(category);
    return LinearGradient(
      colors: [color.withOpacity(0.8), color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
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