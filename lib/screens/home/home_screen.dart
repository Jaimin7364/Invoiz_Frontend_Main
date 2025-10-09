import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/subscription_guard_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../subscription/subscription_status_screen.dart';
import 'profile_screen.dart';
import '../products/products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  
  static const List<Widget> _screens = [
    DashboardTab(),
    ProductsTab(),
    ReportsTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _performInitialSubscriptionCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Check subscription when app becomes active (resumed from background)
    if (state == AppLifecycleState.resumed) {
      _performSubscriptionCheck();
    }
  }

  Future<void> _performInitialSubscriptionCheck() async {
    // Small delay to ensure the widget is fully built
    await Future.delayed(const Duration(milliseconds: 500));
    await _performSubscriptionCheck();
  }

  Future<void> _performSubscriptionCheck() async {
    if (mounted) {
      await SubscriptionGuardService.performPeriodicSubscriptionCheck(context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
        showBackButton: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        user?.fullName ?? 'User',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Ready to manage your business today?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Subscription Status
                if (authProvider.requiresSubscription())
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_outlined,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Subscription Required',
                                style: AppTextStyles.h6,
                              ),
                              Text(
                                'Upgrade to access all features',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubscriptionStatusScreen(),
                              ),
                            );
                          },
                          child: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  ),
                
                if (authProvider.requiresSubscription())
                  const SizedBox(height: AppSizes.lg),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.add_box,
                        title: 'Add Product',
                        subtitle: 'New product',
                        color: AppColors.primary,
                        onTap: () {
                          // TODO: Navigate to create product
                          _showComingSoon(context);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.person_add,
                        title: 'Add Customer',
                        subtitle: 'New customer',
                        color: AppColors.secondary,
                        onTap: () {
                          // TODO: Navigate to add customer
                          _showComingSoon(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // Summary Cards
                const Text(
                  'Overview',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Revenue',
                        value: '₹0',
                        icon: Icons.currency_rupee,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Products',
                        value: '0',
                        icon: Icons.inventory_2,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Pending Orders',
                        value: '0',
                        icon: Icons.pending,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppSizes.iconLg,
              color: color,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                icon,
                size: AppSizes.iconSm,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

// Placeholder tabs


class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key});

  @override
   Widget build(BuildContext context) {
    return const ProductsScreen();
  }
}

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Reports',
        showBackButton: false,
      ),
      body: Center(
        child: Text(
          'Reports Screen\nComing Soon!',
          style: AppTextStyles.h4,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}