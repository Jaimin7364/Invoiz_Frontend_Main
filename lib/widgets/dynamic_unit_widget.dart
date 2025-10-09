import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import '../utils/unit_system.dart';
import '../widgets/custom_text_field.dart';

class DynamicUnitWidget extends StatefulWidget {
  final String selectedUnit;
  final TextEditingController unitController;
  final TextEditingController? capacityController;
  final TextEditingController? capacityUnitController;
  final Function(String) onUnitChanged;
  final String? Function(String?)? validator;

  const DynamicUnitWidget({
    super.key,
    required this.selectedUnit,
    required this.unitController,
    this.capacityController,
    this.capacityUnitController,
    required this.onUnitChanged,
    this.validator,
  });

  @override
  State<DynamicUnitWidget> createState() => _DynamicUnitWidgetState();
}

class _DynamicUnitWidgetState extends State<DynamicUnitWidget> {
  String _selectedUnit = 'piece';

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.selectedUnit;
  }

  @override
  Widget build(BuildContext context) {
    final requiresCapacity = UnitSystem.requiresCapacityInput(_selectedUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Unit Selection Dropdown
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedUnit,
            decoration: const InputDecoration(
              labelText: 'Unit Type',
              prefixIcon: Icon(Icons.straighten),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
            ),
            items: UnitSystem.getAllUnits().map((unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Row(
                  children: [
                    Icon(
                      _getIconData(UnitSystem.getUnitIcon(unit)),
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(UnitSystem.getDisplayName(unit)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newUnit) {
              if (newUnit != null) {
                setState(() {
                  _selectedUnit = newUnit;
                  widget.unitController.text = newUnit;
                });
                widget.onUnitChanged(newUnit);
              }
            },
            validator: widget.validator,
          ),
        ),
        
        if (requiresCapacity) ...[
          const SizedBox(height: AppSizes.md),
          _buildCapacityFields(),
        ],
        
        const SizedBox(height: AppSizes.md),
        _buildUnitInfo(),
      ],
    );
  }

  Widget _buildCapacityFields() {
    switch (_selectedUnit.toLowerCase()) {
      case 'bottle':
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: widget.capacityController!,
                labelText: 'Bottle Capacity',
                hintText: 'e.g., 500',
                prefixIcon: Icons.local_drink,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bottle capacity';
                  }
                  final capacity = double.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'Please enter valid capacity';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: widget.capacityUnitController?.text.isEmpty == true 
                    ? 'milliliter' 
                    : widget.capacityUnitController?.text ?? 'milliliter',
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.sm,
                  ),
                ),
                items: ['milliliter', 'liter'].map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(UnitSystem.getDisplayName(unit)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    widget.capacityUnitController?.text = value;
                  }
                },
              ),
            ),
          ],
        );
        
      case 'box':
      case 'packet':
        return CustomTextField(
          controller: widget.capacityController!,
          labelText: 'Items per ${_selectedUnit.substring(0, 1).toUpperCase()}${_selectedUnit.substring(1)}',
          hintText: 'e.g., 12',
          prefixIcon: Icons.inventory_2,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter items per $_selectedUnit';
            }
            final items = int.tryParse(value);
            if (items == null || items <= 0) {
              return 'Please enter valid number of items';
            }
            return null;
          },
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUnitInfo() {
    final unitCategory = UnitSystem.getUnitCategory(_selectedUnit);
    if (unitCategory == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconData(unitCategory.icon),
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                '${unitCategory.name} Unit',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _buildUnitDescription(),
        ],
      ),
    );
  }

  Widget _buildUnitDescription() {
    switch (_selectedUnit.toLowerCase()) {
      case 'piece':
        return const Text(
          'Count individual items. Stock will be tracked by number of pieces.',
          style: AppTextStyles.bodySmall,
        );
        
      case 'kilogram':
      case 'gram':
        return const Text(
          'Weight-based unit. You can track total weight and convert between kg/g.',
          style: AppTextStyles.bodySmall,
        );
        
      case 'liter':
      case 'milliliter':
        return const Text(
          'Volume-based unit. Perfect for liquids and bulk materials.',
          style: AppTextStyles.bodySmall,
        );
        
      case 'meter':
      case 'centimeter':
        return const Text(
          'Length-based unit. Ideal for materials sold by length (cables, fabric, etc.).',
          style: AppTextStyles.bodySmall,
        );
        
      case 'bottle':
        return const Text(
          'Container unit. Define bottle capacity to track total volume automatically.',
          style: AppTextStyles.bodySmall,
        );
        
      case 'box':
      case 'packet':
        return const Text(
          'Package unit. Define items per package to track individual items automatically.',
          style: AppTextStyles.bodySmall,
        );
        
      case 'dozen':
        return const Text(
          'Count by dozens (12 pieces each). Stock will show both dozens and individual pieces.',
          style: AppTextStyles.bodySmall,
        );
        
      case 'pair':
        return const Text(
          'Count by pairs (2 pieces each). Stock will show both pairs and individual pieces.',
          style: AppTextStyles.bodySmall,
        );
        
      default:
        return Text(
          'Selected unit: ${UnitSystem.getDisplayName(_selectedUnit)}',
          style: AppTextStyles.bodySmall,
        );
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'inventory': return Icons.inventory;
      case 'scale': return Icons.scale;
      case 'water_drop': return Icons.water_drop;
      case 'straighten': return Icons.straighten;
      case 'local_drink': return Icons.local_drink;
      case 'inventory_2': return Icons.inventory_2;
      default: return Icons.category;
    }
  }
}