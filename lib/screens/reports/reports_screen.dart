import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.reports,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'recalculate') {
                _recalculateReports();
              } else if (value == 'cleanup') {
                _cleanupData();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recalculate',
                child: Row(
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 8),
                    Text(localizations.recalculateReports),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cleanup',
                child: Row(
                  children: [
                    const Icon(Icons.cleaning_services),
                    const SizedBox(width: 8),
                    Text(localizations.cleanupOldData),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<ReportsProvider>(
          builder: (context, reportsProvider, child) {
            if (reportsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (reportsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    reportsProvider.error!,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => reportsProvider.loadReports(),
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Cards
              _buildSummaryCards(context, reportsProvider),
              
              // Year Selector
              _buildYearSelector(context, reportsProvider),
              
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: localizations.monthly),
                  Tab(text: localizations.yearly),
                ],
              ),
              
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMonthlyReports(context, reportsProvider),
                    _buildYearlyReports(context, reportsProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ), // Consumer
    ), // SafeArea
  ); // Scaffold
  }

  Widget _buildSummaryCards(BuildContext context, ReportsProvider provider) {
    final localizations = AppLocalizations.of(context)!;
    final currentMonthReport = provider.currentMonthReport;
    final currentYearReport = provider.currentYearReport;
    final monthGrowth = provider.getCurrentMonthGrowth();
    final yearGrowth = provider.getCurrentYearGrowth();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          // Current Month Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${localizations.currentMonth} (${DateFormat('MMMM yyyy').format(DateTime.now())})',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      if (monthGrowth != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: monthGrowth > 0 ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${monthGrowth > 0 ? '+' : ''}${monthGrowth.toStringAsFixed(1)}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    localizations.revenue,
                    currentMonthReport?.totalRevenue ?? 0,
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildSummaryRow(
                    localizations.investment,
                    currentMonthReport?.totalInvestment ?? 0,
                    Icons.trending_down,
                    Colors.orange,
                  ),
                  _buildSummaryRow(
                    localizations.profit,
                    currentMonthReport?.totalProfit ?? 0,
                    Icons.account_balance_wallet,
                    (currentMonthReport?.totalProfit ?? 0) >= 0 ? Colors.green : Colors.red,
                  ),
                  _buildSummaryRow(
                    localizations.invoices,
                    currentMonthReport?.totalInvoices.toDouble() ?? 0,
                    Icons.receipt,
                    AppColors.primary,
                    isCount: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Current Year Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${localizations.currentYear} (${DateTime.now().year})',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      if (yearGrowth != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: yearGrowth > 0 ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${yearGrowth > 0 ? '+' : ''}${yearGrowth.toStringAsFixed(1)}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    localizations.revenue,
                    currentYearReport?.totalRevenue ?? 0,
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildSummaryRow(
                    localizations.investment,
                    currentYearReport?.totalInvestment ?? 0,
                    Icons.trending_down,
                    Colors.orange,
                  ),
                  _buildSummaryRow(
                    localizations.profit,
                    currentYearReport?.totalProfit ?? 0,
                    Icons.account_balance_wallet,
                    (currentYearReport?.totalProfit ?? 0) >= 0 ? Colors.green : Colors.red,
                  ),
                  _buildSummaryRow(
                    localizations.invoices,
                    currentYearReport?.totalInvoices.toDouble() ?? 0,
                    Icons.receipt,
                    AppColors.primary,
                    isCount: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    IconData icon,
    Color color, {
    bool isCount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            isCount 
                ? value.toInt().toString()
                : 'Rs. ${value.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context, ReportsProvider provider) {
    final availableYears = provider.availableYears;
    
    if (availableYears.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.selectYear,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<int>(
              value: availableYears.contains(_selectedYear) ? _selectedYear : availableYears.first,
              isExpanded: true,
              items: availableYears.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (year) {
                if (year != null) {
                  setState(() {
                    _selectedYear = year;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReports(BuildContext context, ReportsProvider provider) {
    final monthlyReports = provider.getMonthlyReportsForYear(_selectedYear);
    
    if (monthlyReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noDataAvailable,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: monthlyReports.length,
      itemBuilder: (context, index) {
        final report = monthlyReports[index];
        return _buildReportCard(context, report);
      },
    );
  }

  Widget _buildYearlyReports(BuildContext context, ReportsProvider provider) {
    final yearlyReports = provider.yearlyReports;
    
    if (yearlyReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noDataAvailable,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: yearlyReports.length,
      itemBuilder: (context, index) {
        final report = yearlyReports[index];
        return _buildReportCard(context, report);
      },
    );
  }

  Widget _buildReportCard(BuildContext context, ReportData report) {
    final localizations = AppLocalizations.of(context)!;
    final profitMargin = report.totalInvestment > 0 
        ? ((report.totalProfit / report.totalInvestment) * 100)
        : 0.0;

    String title;
    if (report is MonthlyReport) {
      title = DateFormat('MMMM yyyy').format(DateTime(report.year, report.month));
    } else if (report is YearlyReport) {
      title = report.year.toString();
    } else {
      title = DateFormat('MMM yyyy').format(report.period);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: profitMargin >= 0 ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${profitMargin.toStringAsFixed(1)}% ${localizations.margin}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    localizations.revenue,
                    report.totalRevenue,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    localizations.investment,
                    report.totalInvestment,
                    Icons.trending_down,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    localizations.profit,
                    report.totalProfit,
                    Icons.account_balance_wallet,
                    report.totalProfit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    localizations.invoices,
                    report.totalInvoices.toDouble(),
                    Icons.receipt,
                    AppColors.primary,
                    isCount: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(
    String label,
    double value,
    IconData icon,
    Color color, {
    bool isCount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isCount 
              ? value.toInt().toString()
              : 'Rs. ${value.toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _recalculateReports() async {
    // This would need access to all invoices and products
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.recalculatingReports),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cleanupData() async {
    final provider = context.read<ReportsProvider>();
    await provider.cleanupOldData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.dataCleanedUp),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}