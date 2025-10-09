import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/product_model.dart';

class EnhancedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isGridView;
  final bool showActions;

  const EnhancedProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isGridView = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          splashColor: _getProductColor(product.category).withOpacity(0.1),
          highlightColor: _getProductColor(product.category).withOpacity(0.05),
          child: isGridView ? _buildGridContent() : _buildListContent(),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          // Enhanced Product Image/Avatar
          Hero(
            tag: 'product_avatar_${product.id}',
            child: _buildProductAvatar(65),
          ),
          const SizedBox(width: AppSizes.lg),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name and Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.h6.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!product.isActive) _buildInactiveChip(),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                
                // Category and SKU with enhanced styling
                _buildCategoryAndSku(),
                const SizedBox(height: AppSizes.md),
                
                // Price and Stock Info with improved layout
                _buildPriceAndStock(),
              ],
            ),
          ),
          
          if (showActions) _buildEnhancedActionMenu(),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProductAvatar(50),
              if (showActions) _buildActionMenu(),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          
          // Product name
          Text(
            product.name,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.xs),
          
          // Category
          _buildCategoryChip(),
          
          const Spacer(),
          
          // Price
          _buildPriceChip(),
          const SizedBox(height: AppSizes.xs),
          
          // Stock info
          _buildStockChip(),
          
          // Status badges
          if (!product.isActive) ...[
            const SizedBox(height: AppSizes.xs),
            _buildInactiveChip(fullWidth: true),
          ],
        ],
      ),
    );
  }

  Widget _buildProductAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: _getProductGradient(product.category),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: _getProductColor(product.category).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getProductIcon(product.category),
              color: AppColors.textOnPrimary,
              size: size * 0.45,
            ),
          ),
          // Status indicator dot
          if (product.isLowStock)
            Positioned(
              top: size * 0.1,
              right: size * 0.1,
              child: Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(size * 0.1),
                  border: Border.all(
                    color: AppColors.textOnPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndSku() {
    return Row(
      children: [
        _buildCategoryChip(),
        if (product.sku != null && product.sku!.isNotEmpty) ...[
          const SizedBox(width: AppSizes.sm),
          Text(
            'SKU: ${product.sku}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryChip() {
    final categoryColor = _getProductColor(product.category);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withOpacity(0.15),
            categoryColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getProductIcon(product.category),
            size: 14,
            color: categoryColor,
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            product.category,
            style: AppTextStyles.caption.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndStock() {
    return Row(
      children: [
        // Price
        _buildPriceChip(),
        const SizedBox(width: AppSizes.sm),
        
        // Stock Info
        _buildStockChip(),
        
        const Spacer(),
      ],
    );
  }

  Widget _buildPriceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.15),
            AppColors.success.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.currency_rupee,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 2),
          Text(
            product.price.toStringAsFixed(2),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockChip() {
    final chipColor = product.isLowStock ? AppColors.error : AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chipColor.withOpacity(0.15),
            chipColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            product.isLowStock 
                ? Icons.warning_rounded
                : Icons.inventory_2_rounded,
            size: 16,
            color: chipColor,
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            '${product.stockQuantity}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: chipColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ' ${product.unit}',
            style: AppTextStyles.caption.copyWith(
              color: chipColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveChip({bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.warning),
      ),
      child: Text(
        'Inactive',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w500,
        ),
        textAlign: fullWidth ? TextAlign.center : null,
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: 20,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit, size: 20),
            title: Text('Edit'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: AppColors.error, size: 20),
            title: Text('Delete'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedActionMenu() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit?.call();
              break;
            case 'delete':
              onDelete?.call();
              break;
          }
        },
        icon: const Icon(
          Icons.more_vert_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  const Text(
                    'Edit Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                      size: 18,
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
    );
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