import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_model.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';

class ReportsService {
  static const String _monthlyReportsKeyPrefix = 'monthly_reports_user_';
  static const String _yearlyReportsKeyPrefix = 'yearly_reports_user_';
  static const int _dataRetentionYears = 3;

  // Get user-specific storage keys
  String _getMonthlyReportsKey(String userId) => '$_monthlyReportsKeyPrefix$userId';
  String _getYearlyReportsKey(String userId) => '$_yearlyReportsKeyPrefix$userId';

  // Get current year and calculate data retention cutoff
  int get _currentYear => DateTime.now().year;
  int get _cutoffYear => _currentYear - _dataRetentionYears + 1;

  // Calculate monthly report for a specific month/year
  Future<MonthlyReport> calculateMonthlyReport(
    int month,
    int year,
    List<Invoice> invoices,
    List<Product> products,
  ) async {
    final monthlyInvoices = invoices.where((invoice) {
      final invoiceDate = invoice.invoiceDate;
      return invoiceDate.year == year && invoiceDate.month == month;
    }).toList();

    double totalRevenue = 0.0;
    double totalInvestment = 0.0;
    int totalInvoicesCount = monthlyInvoices.length;

    // Create a map of product base prices for quick lookup
    Map<String, double> productBasePrices = {};
    for (final product in products) {
      if (product.id != null) {
        productBasePrices[product.id!] = product.cost;
      }
    }

    for (final invoice in monthlyInvoices) {
      totalRevenue += invoice.totalAmount;
      
      // Calculate investment (sum of base prices for all items)
      for (final item in invoice.items) {
        final basePrice = productBasePrices[item.productId] ?? 0.0;
        totalInvestment += basePrice * item.quantity;
      }
    }

    final totalProfit = totalRevenue - totalInvestment;

    return MonthlyReport(
      month: month,
      year: year,
      totalRevenue: totalRevenue,
      totalInvestment: totalInvestment,
      totalProfit: totalProfit,
      totalInvoices: totalInvoicesCount,
    );
  }

  // Calculate yearly report for a specific year
  Future<YearlyReport> calculateYearlyReport(
    int year,
    List<Invoice> invoices,
    List<Product> products,
  ) async {
    final yearlyInvoices = invoices.where((invoice) {
      return invoice.invoiceDate.year == year;
    }).toList();

    double totalRevenue = 0.0;
    double totalInvestment = 0.0;
    int totalInvoicesCount = yearlyInvoices.length;

    // Create a map of product base prices for quick lookup
    Map<String, double> productBasePrices = {};
    for (final product in products) {
      if (product.id != null) {
        productBasePrices[product.id!] = product.cost;
      }
    }

    for (final invoice in yearlyInvoices) {
      totalRevenue += invoice.totalAmount;
      
      // Calculate investment (sum of base prices for all items)
      for (final item in invoice.items) {
        final basePrice = productBasePrices[item.productId] ?? 0.0;
        totalInvestment += basePrice * item.quantity;
      }
    }

    final totalProfit = totalRevenue - totalInvestment;

    return YearlyReport(
      year: year,
      totalRevenue: totalRevenue,
      totalInvestment: totalInvestment,
      totalProfit: totalProfit,
      totalInvoices: totalInvoicesCount,
    );
  }

  // Save monthly reports to local storage
  Future<void> saveMonthlyReports(List<MonthlyReport> reports, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Filter reports to keep only last 3 years
    final filteredReports = reports.where((report) => 
      report.year >= _cutoffYear
    ).toList();
    
    final jsonList = filteredReports.map((report) => report.toJson()).toList();
    await prefs.setString(_getMonthlyReportsKey(userId), jsonEncode(jsonList));
  }

  // Save yearly reports to local storage
  Future<void> saveYearlyReports(List<YearlyReport> reports, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Filter reports to keep only last 3 years
    final filteredReports = reports.where((report) => 
      report.year >= _cutoffYear
    ).toList();
    
    final jsonList = filteredReports.map((report) => report.toJson()).toList();
    await prefs.setString(_getYearlyReportsKey(userId), jsonEncode(jsonList));
  }

  // Load monthly reports from local storage
  Future<List<MonthlyReport>> loadMonthlyReports(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_getMonthlyReportsKey(userId));
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    final reports = jsonList.map((json) => MonthlyReport.fromJson(json)).toList();
    
    // Filter out old data automatically
    final filteredReports = reports.where((report) => 
      report.year >= _cutoffYear
    ).toList();
    
    // If data was filtered, save the cleaned list for this user
    if (filteredReports.length != reports.length) {
      await saveMonthlyReports(filteredReports, userId);
    }
    
    return filteredReports;
  }

  // Load yearly reports from local storage
  Future<List<YearlyReport>> loadYearlyReports(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_getYearlyReportsKey(userId));
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    final reports = jsonList.map((json) => YearlyReport.fromJson(json)).toList();
    
    // Filter out old data automatically
    final filteredReports = reports.where((report) => 
      report.year >= _cutoffYear
    ).toList();
    
    // If data was filtered, save the cleaned list for this user
    if (filteredReports.length != reports.length) {
      await saveYearlyReports(filteredReports, userId);
    }
    
    return filteredReports;
  }

  // Update reports with new invoice data
  Future<void> updateReportsWithInvoice(
    Invoice invoice, 
    List<Product> products,
    String userId,
  ) async {
    final invoiceDate = invoice.invoiceDate;
    final month = invoiceDate.month;
    final year = invoiceDate.year;

    // Load existing reports for this user
    final monthlyReports = await loadMonthlyReports(userId);
    final yearlyReports = await loadYearlyReports(userId);

    // Find or create monthly report
    final existingMonthlyIndex = monthlyReports.indexWhere(
      (report) => report.month == month && report.year == year,
    );

    // Find or create yearly report
    final existingYearlyIndex = yearlyReports.indexWhere(
      (report) => report.year == year,
    );

    // Calculate investment for this invoice
    double invoiceInvestment = 0.0;
    Map<String, double> productBasePrices = {};
    for (final product in products) {
      if (product.id != null) {
        productBasePrices[product.id!] = product.cost;
      }
    }
    
    for (final item in invoice.items) {
      final basePrice = productBasePrices[item.productId] ?? 0.0;
      invoiceInvestment += basePrice * item.quantity;
    }

    final invoiceProfit = invoice.totalAmount - invoiceInvestment;

    // Update monthly report
    if (existingMonthlyIndex >= 0) {
      final existing = monthlyReports[existingMonthlyIndex];
      monthlyReports[existingMonthlyIndex] = MonthlyReport(
        month: month,
        year: year,
        totalRevenue: existing.totalRevenue + invoice.totalAmount,
        totalInvestment: existing.totalInvestment + invoiceInvestment,
        totalProfit: existing.totalProfit + invoiceProfit,
        totalInvoices: existing.totalInvoices + 1,
      );
    } else {
      monthlyReports.add(MonthlyReport(
        month: month,
        year: year,
        totalRevenue: invoice.totalAmount,
        totalInvestment: invoiceInvestment,
        totalProfit: invoiceProfit,
        totalInvoices: 1,
      ));
    }

    // Update yearly report
    if (existingYearlyIndex >= 0) {
      final existing = yearlyReports[existingYearlyIndex];
      yearlyReports[existingYearlyIndex] = YearlyReport(
        year: year,
        totalRevenue: existing.totalRevenue + invoice.totalAmount,
        totalInvestment: existing.totalInvestment + invoiceInvestment,
        totalProfit: existing.totalProfit + invoiceProfit,
        totalInvoices: existing.totalInvoices + 1,
      );
    } else {
      yearlyReports.add(YearlyReport(
        year: year,
        totalRevenue: invoice.totalAmount,
        totalInvestment: invoiceInvestment,
        totalProfit: invoiceProfit,
        totalInvoices: 1,
      ));
    }

    // Save updated reports for this user
    await saveMonthlyReports(monthlyReports, userId);
    await saveYearlyReports(yearlyReports, userId);
  }

  // Recalculate all reports from scratch (useful for data integrity)
  Future<void> recalculateAllReports(
    List<Invoice> allInvoices,
    List<Product> allProducts,
    String userId,
  ) async {
    final monthlyReports = <MonthlyReport>[];
    final yearlyReports = <YearlyReport>[];

    // Get unique year-month combinations from invoices
    final Set<String> monthYearPairs = {};
    final Set<int> years = {};

    for (final invoice in allInvoices) {
      final date = invoice.invoiceDate;
      if (date.year >= _cutoffYear) {
        monthYearPairs.add('${date.year}-${date.month}');
        years.add(date.year);
      }
    }

    // Calculate monthly reports
    for (final pair in monthYearPairs) {
      final parts = pair.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      
      final monthlyReport = await calculateMonthlyReport(
        month, year, allInvoices, allProducts,
      );
      monthlyReports.add(monthlyReport);
    }

    // Calculate yearly reports
    for (final year in years) {
      final yearlyReport = await calculateYearlyReport(
        year, allInvoices, allProducts,
      );
      yearlyReports.add(yearlyReport);
    }

    // Save all reports for this user
    await saveMonthlyReports(monthlyReports, userId);
    await saveYearlyReports(yearlyReports, userId);
  }

  // Clean up old data (run this periodically)
  Future<void> cleanupOldData(String userId) async {
    final monthlyReports = await loadMonthlyReports(userId);
    final yearlyReports = await loadYearlyReports(userId);
    
    // This will automatically filter and save cleaned data for this user
    await saveMonthlyReports(monthlyReports, userId);
    await saveYearlyReports(yearlyReports, userId);
  }
}