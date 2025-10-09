import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/product_model.dart';

class ProductStatisticsWidget extends StatelessWidget {
  final List<Product> products;

  const ProductStatisticsWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStatistics();
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      margin: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Product Overview',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          
          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Products',
                  stats['totalProducts'].toString(),
                  Icons.inventory_2_rounded,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildStatCard(
                  'Categories',
                  stats['totalCategories'].toString(),
                  Icons.category_rounded,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Low Stock',
                  stats['lowStockCount'].toString(),
                  Icons.warning_rounded,
                  AppColors.error,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildStatCard(
                  'Total Value',
                  '₹${stats['totalValue']}',
                  Icons.currency_rupee_rounded,
                  AppColors.success,
                ),
              ),
            ],
          ),
          
          if (stats['topCategories'].isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            Text(
              'Top Categories',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            ...stats['topCategories'].map<Widget>((category) => 
              _buildCategoryBar(category['name'], category['count'], stats['totalProducts']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: AppTextStyles.h6.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String category, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCategoryColor(category),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStatistics() {
    if (products.isEmpty) {
      return {
        'totalProducts': 0,
        'totalCategories': 0,
        'lowStockCount': 0,
        'totalValue': '0.00',
        'topCategories': <Map<String, dynamic>>[],
      };
    }

    final categoryCount = <String, int>{};
    int lowStockCount = 0;
    double totalValue = 0.0;

    for (final product in products) {
      // Count categories
      categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
      
      // Count low stock products
      if (product.isLowStock) {
        lowStockCount++;
      }
      
      // Calculate total inventory value
      totalValue += (product.price * product.stockQuantity);
    }

    // Get top categories (sorted by count)
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedCategories.take(5).map((entry) => {
      'name': entry.key,
      'count': entry.value,
    }).toList();

    return {
      'totalProducts': products.length,
      'totalCategories': categoryCount.length,
      'lowStockCount': lowStockCount,
      'totalValue': totalValue.toStringAsFixed(2),
      'topCategories': topCategories,
    };
  }

  Color _getCategoryColor(String category) {
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
}