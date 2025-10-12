import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/subscription_guard_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart';
import '../subscription/subscription_status_screen.dart';
import 'profile_screen.dart';
import '../products/products_screen.dart';
import '../invoice/invoice_create_screen.dart';
import '../reports/reports_screen.dart';

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
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.surface,
          elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: localizations.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: localizations.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
            label: localizations.reports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: localizations.profile,
          ),
        ],
        ),
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load reports data for revenue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ReportsProvider>(context, listen: false).loadReports();
        Provider.of<ProductProvider>(context, listen: false).getProducts(page: 1, limit: 1000); // Get all products for count
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.dashboard,
        showBackButton: false,
      ),
      body: Consumer3<AuthProvider, ReportsProvider, ProductProvider>(
        builder: (context, authProvider, reportsProvider, productProvider, child) {
          final user = authProvider.user;
          final currentMonthReport = reportsProvider.currentMonthReport;
          final totalProducts = productProvider.products.length;
          
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
                        localizations.welcomeBack,
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
                        localizations.readyToManage,
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
                                localizations.upgradeToAccess,
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
                          child: Text(localizations.upgrade),
                        ),
                      ],
                    ),
                  ),
                
                if (authProvider.requiresSubscription())
                  const SizedBox(height: AppSizes.lg),

                // Quick Actions
                Text(
                  localizations.quickActions,
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppSizes.md),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.receipt_long,
                            title: localizations.createInvoice,
                            subtitle: localizations.newInvoice,
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InvoiceCreateScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.inventory_2,
                            title: localizations.viewProducts,
                            subtitle: localizations.manageStock,
                            color: AppColors.success,
                            onTap: () {
                              // Navigate to products tab
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ProductsScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // Summary Cards
                Text(
                  localizations.overview,
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to Reports screen when revenue card is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportsScreen(),
                            ),
                          );
                        },
                        child: _buildSummaryCard(
                          context,
                          title: localizations.totalRevenue,
                          value: '₹${currentMonthReport?.totalRevenue.toStringAsFixed(0) ?? '0'}',
                          icon: Icons.currency_rupee,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to Products screen when products card is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductsScreen(),
                            ),
                          );
                        },
                        child: _buildSummaryCard(
                          context,
                          title: localizations.products,
                          value: totalProducts.toString(),
                          icon: Icons.inventory_2,
                          color: AppColors.secondary,
                        ),
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

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final localizations = AppLocalizations.of(context)!;
    
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
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            localizations.tapToViewDetails,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
    return const ReportsScreen();
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}