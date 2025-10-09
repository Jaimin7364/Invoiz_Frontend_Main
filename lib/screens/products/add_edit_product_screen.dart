import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/dynamic_unit_widget.dart';
import '../../utils/unit_system.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _unitController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _skuController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _unitCapacityController = TextEditingController();
  final _capacityUnitController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _unitController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    _taxRateController.dispose();
    _stockQuantityController.dispose();
    _minimumStockController.dispose();
    _expiryDateController.dispose();
    _unitCapacityController.dispose();
    _capacityUnitController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _categoryController.text = product.category;
      _brandController.text = product.brand ?? '';
      _priceController.text = product.price.toString();
      _costController.text = product.cost.toString();
      _unitController.text = product.unit;
      _weightController.text = product.weight ?? '';
      _dimensionsController.text = product.dimensions ?? '';
      _barcodeController.text = product.barcode ?? '';
      _skuController.text = product.sku ?? '';
      _taxRateController.text = product.taxRate.toString();
      _stockQuantityController.text = product.stockQuantity.toString();
      _minimumStockController.text = product.minimumStock.toString();
      _expiryDateController.text = product.expiryDate != null 
          ? '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}'
          : '';
      _unitCapacityController.text = product.unitCapacity?.toString() ?? '';
      _capacityUnitController.text = product.capacityUnit ?? '';
      _isActive = product.isActive;

    } else {
      _unitController.text = 'piece';
      _taxRateController.text = '0';
      _costController.text = '0';
      _stockQuantityController.text = '0';
      _minimumStockController.text = '0';
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // Parse expiry date if provided
      DateTime? expiryDate;
      if (_expiryDateController.text.trim().isNotEmpty) {
        try {
          final parts = _expiryDateController.text.split('/');
          if (parts.length == 3) {
            expiryDate = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          }
        } catch (e) {
          // Invalid date format, keep null
        }
      }

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text),
        cost: double.parse(_costController.text),
        unit: _unitController.text.trim(),
        sku: _skuController.text.trim().isEmpty 
            ? null 
            : _skuController.text.trim(),
        brand: _brandController.text.trim().isEmpty 
            ? null 
            : _brandController.text.trim(),
        weight: _weightController.text.trim().isEmpty 
            ? null 
            : _weightController.text.trim(),
        dimensions: _dimensionsController.text.trim().isEmpty 
            ? null 
            : _dimensionsController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty 
            ? null 
            : _barcodeController.text.trim(),
        expiryDate: expiryDate,
        unitCapacity: _unitCapacityController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_unitCapacityController.text),
        capacityUnit: _capacityUnitController.text.trim().isEmpty 
            ? null 
            : _capacityUnitController.text.trim(),
        taxRate: double.parse(_taxRateController.text),
        stockQuantity: int.parse(_stockQuantityController.text),
        minimumStock: int.parse(_minimumStockController.text),
        isActive: _isActive,
        businessId: authProvider.user?.businessId ?? '',
        userId: authProvider.user?.userId ?? '',
      );

      bool success;
      if (widget.product != null) {
        success = await productProvider.updateProduct(widget.product!.id!, product);
      } else {
        success = await productProvider.createProduct(product);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product != null 
                ? 'Product updated successfully' 
                : 'Product created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.error ?? 'Failed to save product'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.product != null ? 'Edit Product' : 'Add Product',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: AppSizes.md),
              
              CustomTextField(
                controller: _nameController,
                labelText: 'Product Name',
                hintText: 'Enter product name',
                prefixIcon: Icons.inventory_2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  if (value.trim().length > 100) {
                    return 'Product name cannot exceed 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description (Optional)',
                hintText: 'Enter product description',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Description cannot exceed 500 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Category with dropdown
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return CustomTextField(
                    controller: _categoryController,
                    labelText: 'Category',
                    hintText: 'Enter or select category',
                    prefixIcon: Icons.category,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter category';
                      }
                      if (value.trim().length > 50) {
                        return 'Category cannot exceed 50 characters';
                      }
                      return null;
                    },
                    suffixIcon: productProvider.categories.isNotEmpty 
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (value) {
                              _categoryController.text = value;
                            },
                            itemBuilder: (context) => productProvider.categories
                                .map((category) => PopupMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(height: AppSizes.md),

              CustomTextField(
                controller: _brandController,
                labelText: 'Brand (Optional)',
                hintText: 'Enter product brand',
                prefixIcon: Icons.branding_watermark,
                validator: (value) {
                  if (value != null && value.length > 50) {
                    return 'Brand cannot exceed 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // Pricing Section
              _buildSectionTitle('Pricing'),
              const SizedBox(height: AppSizes.md),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: 'Selling Price',
                      hintText: '0.00',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter selling price';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'Please enter valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _costController,
                      labelText: 'Cost Price (Optional)',
                      hintText: '0.00',
                      prefixIcon: Icons.money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final cost = double.tryParse(value);
                          if (cost == null || cost < 0) {
                            return 'Please enter valid cost';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              DynamicUnitWidget(
                selectedUnit: _unitController.text.isEmpty ? 'piece' : _unitController.text,
                unitController: _unitController,
                capacityController: _unitCapacityController,
                capacityUnitController: _capacityUnitController,
                onUnitChanged: (String newUnit) {
                  setState(() {
                    _unitController.text = newUnit;
                    // Clear capacity fields when unit changes
                    if (!UnitSystem.requiresCapacityInput(newUnit)) {
                      _unitCapacityController.clear();
                      _capacityUnitController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _taxRateController,
                      labelText: 'Tax Rate (%)',
                      hintText: '0',
                      prefixIcon: Icons.percent,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final taxRate = double.tryParse(value);
                          if (taxRate == null || taxRate < 0 || taxRate > 100) {
                            return 'Tax rate must be between 0-100';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _weightController,
                      labelText: 'Weight (Optional)',
                      hintText: 'e.g., 500g, 1.5kg',
                      prefixIcon: Icons.fitness_center,
                      validator: (value) {
                        if (value != null && value.length > 20) {
                          return 'Weight cannot exceed 20 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _dimensionsController,
                      labelText: 'Dimensions (Optional)',
                      hintText: 'L x W x H',
                      prefixIcon: Icons.aspect_ratio,
                      validator: (value) {
                        if (value != null && value.length > 30) {
                          return 'Dimensions cannot exceed 30 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // Inventory Section
              _buildSectionTitle('Inventory'),
              const SizedBox(height: AppSizes.md),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockQuantityController,
                      labelText: 'Stock Quantity',
                      hintText: '0',
                      prefixIcon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock < 0) {
                          return 'Please enter valid stock quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _minimumStockController,
                      labelText: 'Minimum Stock',
                      hintText: '0',
                      prefixIcon: Icons.warning,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter minimum stock';
                        }
                        final minStock = int.tryParse(value);
                        if (minStock == null || minStock < 0) {
                          return 'Please enter valid minimum stock';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              CustomTextField(
                controller: _skuController,
                labelText: 'SKU (Optional)',
                hintText: 'Stock Keeping Unit',
                prefixIcon: Icons.qr_code,
                validator: (value) {
                  if (value != null && value.length > 50) {
                    return 'SKU cannot exceed 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _barcodeController,
                      labelText: 'Barcode (Optional)',
                      hintText: 'Product barcode',
                      prefixIcon: Icons.qr_code_scanner,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.length > 20) {
                          return 'Barcode cannot exceed 20 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          _expiryDateController.text = 
                              '${picked.day}/${picked.month}/${picked.year}';
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _expiryDateController,
                          labelText: 'Expiry Date (Optional)',
                          hintText: 'DD/MM/YYYY',
                          prefixIcon: Icons.date_range,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              // Basic date format validation
                              if (!RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(value)) {
                                return 'Please enter valid date (DD/MM/YYYY)';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // Status Section
              _buildSectionTitle('Status'),
              const SizedBox(height: AppSizes.md),

              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Product is available for sale'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: AppSizes.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  onPressed: _saveProduct,
                  isLoading: _isLoading,
                  text: widget.product != null ? 'Update Product' : 'Create Product',
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h5.copyWith(
        color: AppColors.primary,
      ),
    );
  }
}