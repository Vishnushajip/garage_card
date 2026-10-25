enum AnalyticsTimeRange { today, thisWeek, thisMonth, thisYear, custom }

class ChartDataPoint {
  const ChartDataPoint({
    required this.label,
    required this.billed,
    required this.collected,
    required this.cost,
    required this.profit,
  });

  final String label;
  final double billed;
  final double collected;
  final double cost;
  final double profit;
}

class FinancialMetricsModel {
  const FinancialMetricsModel({
    required this.timeRange,
    required this.startDate,
    required this.endDate,
    required this.grossBilled,
    required this.discountAdjustments,
    required this.netBilled,
    required this.totalCollected,
    required this.pendingBalance,
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    required this.netProfit,
    required this.profitMargin,
    required this.isProfit,
    this.chartPoints = const [],
    this.totalJobsCompleted = 0,
    this.totalJobsInProgress = 0,
    this.totalJobsReady = 0,
    this.totalNewJobs = 0,
    this.currencyCode = 'INR',
  });

  final AnalyticsTimeRange timeRange;
  final DateTime startDate;
  final DateTime endDate;
  final double grossBilled;
  final double discountAdjustments;
  final double netBilled;
  final double totalCollected;
  final double pendingBalance;
  final double partsCost;
  final double laborCost;
  final double totalCost;
  final double netProfit;
  final double profitMargin;
  final bool isProfit;
  final List<ChartDataPoint> chartPoints;
  final int totalJobsCompleted;
  final int totalJobsInProgress;
  final int totalJobsReady;
  final int totalNewJobs;
  final String currencyCode;
}
