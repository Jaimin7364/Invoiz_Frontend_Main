import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';
import '../subscription/subscription_plans_screen.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  State<BusinessRegistrationScreen> createState() => _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState extends State<BusinessRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  final _upiController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Business Registration',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Register Your Business',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Please provide your business details to complete the registration process.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Business Information Section
              _buildSectionTitle('Business Information'),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _businessNameController,
                labelText: 'Business Name',
                hintText: 'Enter your business name',
                prefixIcon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Business Description',
                hintText: 'Describe your business (Optional)',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.lg),

              // Address Section
              _buildSectionTitle('Business Address'),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _streetController,
                labelText: 'Street Address',
                hintText: 'Enter your street address',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      labelText: 'City',
                      hintText: 'Enter city',
                      prefixIcon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      labelText: 'State',
                      hintText: 'Enter state',
                      prefixIcon: Icons.map,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _postalCodeController,
                labelText: 'Postal Code',
                hintText: 'Enter postal code',
                prefixIcon: Icons.local_post_office,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter postal code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // Contact Information Section
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Business Phone',
                hintText: 'Enter business phone number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _emailController,
                labelText: 'Business Email',
                hintText: 'Enter business email (Optional)',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // Business Details Section
              _buildSectionTitle('Business Details'),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _gstController,
                labelText: 'GST Number',
                hintText: 'Enter GST number (Optional)',
                prefixIcon: Icons.receipt_long,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(value)) {
                      return 'Please enter valid GST number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _upiController,
                labelText: 'UPI ID',
                hintText: 'Enter UPI ID (Optional)',
                prefixIcon: Icons.payment,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+$').hasMatch(value)) {
                      return 'Please enter valid UPI ID';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.xl),

              // Register Button
              LoadingButton(
                onPressed: _isLoading ? null : _registerBusiness,
                isLoading: _isLoading,
                text: 'Register Business',
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

  Future<void> _registerBusiness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final businessData = {
        'businessName': _businessNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'postalCode': _postalCodeController.text.trim(),
        },
        'contactInfo': {
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
        },
        'gstNumber': _gstController.text.trim(),
        'upiId': _upiController.text.trim(),
      };

      await authProvider.registerBusiness(businessData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business registered successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SubscriptionPlansScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register business: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}