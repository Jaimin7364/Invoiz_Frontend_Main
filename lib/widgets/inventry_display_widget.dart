import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/product_model.dart';
import '../utils/unit_system.dart';

class InventoryDisplayWidget extends StatelessWidget {
  final Product product;
  final bool showActions;
  final VoidCallback? onStockUpdate;

  const InventoryDisplayWidget({
    super.key,
    required this.product,
    this.showActions = false,
    this.onStockUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getUnitIcon(product.unit),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Inventory Information',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          
          _buildInventoryDetails(),
          
          if (product.isLowStock) ...[
            const SizedBox(height: AppSizes.md),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      'Low stock alert! Current stock is below minimum level.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (showActions) ...[
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onStockUpdate,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Stock'),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onStockUpdate,
                    icon: const Icon(Icons.remove),
                    label: const Text('Remove Stock'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInventoryDetails() {
    return Column(
      children: [
        _buildInfoRow(
          'Current Stock', 
          _formatCurrentStock(),
          isLowStock: product.isLowStock,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildInfoRow('Minimum Stock', _formatMinimumStock()),
        
        if (product.unitCapacity != null && product.capacityUnit != null) ...[
          const SizedBox(height: AppSizes.sm),
          _buildInfoRow(
            'Unit Capacity', 
            '${product.unitCapacity} ${UnitSystem.getDisplayName(product.capacityUnit!)}',
          ),
          const SizedBox(height: AppSizes.sm),
          _buildInfoRow(
            'Total Capacity',
            _formatTotalCapacity(),
          ),
        ],
        
        if (product.sku != null && product.sku!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sm),
          _buildInfoRow('SKU', product.sku!),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLowStock = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isLowStock ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            if (isLowStock) ...[
              const SizedBox(width: AppSizes.xs),
              Icon(
                Icons.warning,
                color: AppColors.error,
                size: 16,
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatCurrentStock() {
    if (product.unitCapacity != null && product.capacityUnit != null) {
      return '${product.stockQuantity} ${UnitSystem.getDisplayName(product.unit)}';
    }
    
    switch (product.unit.toLowerCase()) {
      case 'dozen':
        final pieces = product.stockQuantity * 12;
        return '${product.stockQuantity} dozen ($pieces pieces)';
      case 'pair':
        final pieces = product.stockQuantity * 2;
        return '${product.stockQuantity} pairs ($pieces pieces)';
      default:
        return '${product.stockQuantity} ${UnitSystem.getDisplayName(product.unit)}';
    }
  }

  String _formatMinimumStock() {
    if (product.unitCapacity != null && product.capacityUnit != null) {
      return '${product.minimumStock} ${UnitSystem.getDisplayName(product.unit)}';
    }
    
    switch (product.unit.toLowerCase()) {
      case 'dozen':
        final pieces = product.minimumStock * 12;
        return '${product.minimumStock} dozen ($pieces pieces)';
      case 'pair':
        final pieces = product.minimumStock * 2;
        return '${product.minimumStock} pairs ($pieces pieces)';
      default:
        return '${product.minimumStock} ${UnitSystem.getDisplayName(product.unit)}';
    }
  }

  String _formatTotalCapacity() {
    if (product.unitCapacity == null || product.capacityUnit == null) {
      return 'N/A';
    }
    
    final totalCapacity = product.stockQuantity * product.unitCapacity!;
    return '${totalCapacity.toStringAsFixed(totalCapacity == totalCapacity.toInt() ? 0 : 1)} ${UnitSystem.getDisplayName(product.capacityUnit!)}';
  }

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
}