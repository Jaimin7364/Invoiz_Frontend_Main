class ReportData {
  final double totalRevenue;
  final double totalInvestment;
  final double totalProfit;
  final int totalInvoices;
  final DateTime period;

  ReportData({
    required this.totalRevenue,
    required this.totalInvestment,
    required this.totalProfit,
    required this.totalInvoices,
    required this.period,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalInvestment': totalInvestment,
      'totalProfit': totalProfit,
      'totalInvoices': totalInvoices,
      'period': period.toIso8601String(),
    };
  }

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      totalInvestment: (json['totalInvestment'] ?? 0.0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0.0).toDouble(),
      totalInvoices: json['totalInvoices'] ?? 0,
      period: DateTime.parse(json['period']),
    );
  }

  ReportData copyWith({
    double? totalRevenue,
    double? totalInvestment,
    double? totalProfit,
    int? totalInvoices,
    DateTime? period,
  }) {
    return ReportData(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalInvestment: totalInvestment ?? this.totalInvestment,
      totalProfit: totalProfit ?? this.totalProfit,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      period: period ?? this.period,
    );
  }
}

class MonthlyReport extends ReportData {
  final int month;
  final int year;

  MonthlyReport({
    required this.month,
    required this.year,
    required double totalRevenue,
    required double totalInvestment,
    required double totalProfit,
    required int totalInvoices,
  }) : super(
          totalRevenue: totalRevenue,
          totalInvestment: totalInvestment,
          totalProfit: totalProfit,
          totalInvoices: totalInvoices,
          period: DateTime(year, month),
        );

  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'month': month,
      'year': year,
    };
  }

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    final reportData = ReportData.fromJson(json);
    return MonthlyReport(
      month: json['month'],
      year: json['year'],
      totalRevenue: reportData.totalRevenue,
      totalInvestment: reportData.totalInvestment,
      totalProfit: reportData.totalProfit,
      totalInvoices: reportData.totalInvoices,
    );
  }
}

class YearlyReport extends ReportData {
  final int year;

  YearlyReport({
    required this.year,
    required double totalRevenue,
    required double totalInvestment,
    required double totalProfit,
    required int totalInvoices,
  }) : super(
          totalRevenue: totalRevenue,
          totalInvestment: totalInvestment,
          totalProfit: totalProfit,
          totalInvoices: totalInvoices,
          period: DateTime(year),
        );

  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'year': year,
    };
  }

  factory YearlyReport.fromJson(Map<String, dynamic> json) {
    final reportData = ReportData.fromJson(json);
    return YearlyReport(
      year: json['year'],
      totalRevenue: reportData.totalRevenue,
      totalInvestment: reportData.totalInvestment,
      totalProfit: reportData.totalProfit,
      totalInvoices: reportData.totalInvoices,
    );
  }
}