import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/reports_service.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';

class ReportsProvider with ChangeNotifier {
  final ReportsService _reportsService = ReportsService();
  AuthProvider? _authProvider;
  
  List<MonthlyReport> _monthlyReports = [];
  List<YearlyReport> _yearlyReports = [];
  bool _isLoading = false;
  String? _error;

  // Set auth provider reference to get current user ID
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Get current user ID
  String? get _currentUserId => _authProvider?.user?.userId;

  List<MonthlyReport> get monthlyReports => _monthlyReports;
  List<YearlyReport> get yearlyReports => _yearlyReports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current year reports
  YearlyReport? get currentYearReport {
    final currentYear = DateTime.now().year;
    return _yearlyReports.firstWhere(
      (report) => report.year == currentYear,
      orElse: () => YearlyReport(
        year: currentYear,
        totalRevenue: 0,
        totalInvestment: 0,
        totalProfit: 0,
        totalInvoices: 0,
      ),
    );
  }

  // Get current month report
  MonthlyReport? get currentMonthReport {
    final now = DateTime.now();
    return _monthlyReports.firstWhere(
      (report) => report.month == now.month && report.year == now.year,
      orElse: () => MonthlyReport(
        month: now.month,
        year: now.year,
        totalRevenue: 0,
        totalInvestment: 0,
        totalProfit: 0,
        totalInvoices: 0,
      ),
    );
  }

  // Get reports for a specific year
  List<MonthlyReport> getMonthlyReportsForYear(int year) {
    return _monthlyReports
        .where((report) => report.year == year)
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  // Get available years
  List<int> get availableYears {
    final years = _yearlyReports.map((report) => report.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return years;
  }

  // Load all reports
  Future<void> loadReports() async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    try {
      _monthlyReports = await _reportsService.loadMonthlyReports(userId);
      _yearlyReports = await _reportsService.loadYearlyReports(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load reports: $e';
      print('Error loading reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update reports when a new invoice is created
  Future<void> updateReportsWithInvoice(
    Invoice invoice,
    List<Product> products,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }
    
    try {
      await _reportsService.updateReportsWithInvoice(invoice, products, userId);
      await loadReports(); // Reload to get updated data
    } catch (e) {
      _error = 'Failed to update reports: $e';
      print('Error updating reports: $e');
      notifyListeners();
    }
  }

  // Recalculate all reports from scratch
  Future<void> recalculateReports(
    List<Invoice> allInvoices,
    List<Product> allProducts,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    try {
      await _reportsService.recalculateAllReports(allInvoices, allProducts, userId);
      await loadReports();
      _error = null;
    } catch (e) {
      _error = 'Failed to recalculate reports: $e';
      print('Error recalculating reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clean up old data (call this periodically)
  Future<void> cleanupOldData() async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      await _reportsService.cleanupOldData(userId);
      await loadReports();
    } catch (e) {
      print('Error cleaning up old data: $e');
    }
  }

  // Get profit margin percentage
  double getProfitMargin(double revenue, double investment) {
    if (investment > 0) {
      return ((revenue - investment) / investment) * 100;
    }
    return 0;
  }

  // Get report for specific month and year
  MonthlyReport? getMonthlyReport(int month, int year) {
    try {
      return _monthlyReports.firstWhere(
        (report) => report.month == month && report.year == year,
      );
    } catch (e) {
      return null;
    }
  }

  // Get report for specific year
  YearlyReport? getYearlyReport(int year) {
    try {
      return _yearlyReports.firstWhere(
        (report) => report.year == year,
      );
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Calculate growth percentage
  double calculateGrowth(double current, double previous) {
    if (previous > 0) {
      return ((current - previous) / previous) * 100;
    }
    return current > 0 ? 100 : 0;
  }

  // Get month-over-month growth for current month
  double getCurrentMonthGrowth() {
    final now = DateTime.now();
    final currentMonth = getMonthlyReport(now.month, now.year);
    final previousMonth = now.month > 1 
        ? getMonthlyReport(now.month - 1, now.year)
        : getMonthlyReport(12, now.year - 1);
    
    if (currentMonth != null && previousMonth != null) {
      return calculateGrowth(currentMonth.totalRevenue, previousMonth.totalRevenue);
    }
    return 0;
  }

  // Get year-over-year growth for current year
  double getCurrentYearGrowth() {
    final currentYear = DateTime.now().year;
    final currentYearReport = getYearlyReport(currentYear);
    final previousYearReport = getYearlyReport(currentYear - 1);
    
    if (currentYearReport != null && previousYearReport != null) {
      return calculateGrowth(currentYearReport.totalRevenue, previousYearReport.totalRevenue);
    }
    return 0;
  }
}