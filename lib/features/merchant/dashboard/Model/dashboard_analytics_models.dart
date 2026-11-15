enum DashboardTimeRange {
  today,
  last7Days,
  last30Days,
  last90Days,
  thisYear,
  custom;

  String get label {
    switch (this) {
      case DashboardTimeRange.today:
        return 'Today';
      case DashboardTimeRange.last7Days:
        return 'Last 7 Days';
      case DashboardTimeRange.last30Days:
        return 'Last 30 Days';
      case DashboardTimeRange.last90Days:
        return 'Last 90 Days';
      case DashboardTimeRange.thisYear:
        return 'This Year';
      case DashboardTimeRange.custom:
        return 'Custom';
    }
  }
}

class DashboardChartPoint {
  const DashboardChartPoint({
    required this.date,
    required this.label,
    required this.invoiced,
    required this.collected,
  });

  final DateTime date;
  final String label;
  final double invoiced;
  final double collected;
}

class DashboardFinancialMetrics {
  const DashboardFinancialMetrics({
    this.totalCollected = 0.0,
    this.previousPeriodCollected = 0.0,
    this.collectedGrowthRate,
    this.totalInvoiced = 0.0,
    this.previousPeriodInvoiced = 0.0,
    this.invoicedGrowthRate,
    this.totalOutstanding = 0.0,
    this.overdueOutstanding = 0.0,
    this.revenueToday = 0.0,
    this.revenueThisWeek = 0.0,
    this.revenueThisMonth = 0.0,
    this.paymentMethodBreakdown = const {},
    this.paymentMethodPercentages = const {},
    this.dailyRevenuePoints = const [],
  });

  final double totalCollected;
  final double previousPeriodCollected;
  final double? collectedGrowthRate;
  final double totalInvoiced;
  final double previousPeriodInvoiced;
  final double? invoicedGrowthRate;
  final double totalOutstanding;
  final double overdueOutstanding;
  final double revenueToday;
  final double revenueThisWeek;
  final double revenueThisMonth;
  final Map<String, double> paymentMethodBreakdown;
  final Map<String, double> paymentMethodPercentages;
  final List<DashboardChartPoint> dailyRevenuePoints;
}

class DashboardOperationalMetrics {
  const DashboardOperationalMetrics({
    this.totalJobsReceived = 0,
    this.previousPeriodJobsReceived = 0,
    this.jobsGrowthRate,
    this.jobsInProgress = 0,
    this.jobsAwaitingAssignment = 0,
    this.jobsAwaitingInspection = 0,
    this.estimatesAwaitingApproval = 0,
    this.jobsAwaitingParts = 0,
    this.jobsReadyForPickup = 0,
    this.jobsCompleted = 0,
    this.jobsCancelled = 0,
    this.jobsOverdue = 0,
    this.todayAppointments = 0,
    this.vehiclesCurrentlyUnderService = 0,
    this.statusDistribution = const {},
    this.vehicleTypeDistribution = const {},
    this.serviceCategoryDistribution = const {},
  });

  final int totalJobsReceived;
  final int previousPeriodJobsReceived;
  final double? jobsGrowthRate;
  final int jobsInProgress;
  final int jobsAwaitingAssignment;
  final int jobsAwaitingInspection;
  final int estimatesAwaitingApproval;
  final int jobsAwaitingParts;
  final int jobsReadyForPickup;
  final int jobsCompleted;
  final int jobsCancelled;
  final int jobsOverdue;
  final int todayAppointments;
  final int vehiclesCurrentlyUnderService;
  final Map<String, int> statusDistribution;
  final Map<String, int> vehicleTypeDistribution;
  final Map<String, int> serviceCategoryDistribution;
}

class MechanicPerformanceMetric {
  const MechanicPerformanceMetric({
    required this.mechanicId,
    required this.name,
    this.phone = '',
    this.specialization = '',
    this.isActive = true,
    this.assignedJobsCount = 0,
    this.activeJobsCount = 0,
    this.completedJobsCount = 0,
    this.completionRate = 0.0,
    this.averageCompletionHours,
    this.workloadStatus = 'Available',
  });

  final String mechanicId;
  final String name;
  final String phone;
  final String specialization;
  final bool isActive;
  final int assignedJobsCount;
  final int activeJobsCount;
  final int completedJobsCount;
  final double completionRate;
  final double? averageCompletionHours;
  final String workloadStatus;
}

class TopCustomerMetric {
  const TopCustomerMetric({
    required this.customerId,
    required this.name,
    this.phone = '',
    this.vehicleDisplay = '',
    this.jobCount = 0,
    this.totalSpent = 0.0,
    this.pendingBalance = 0.0,
  });

  final String customerId;
  final String name;
  final String phone;
  final String vehicleDisplay;
  final int jobCount;
  final double totalSpent;
  final double pendingBalance;
}

class CustomerRetentionMetrics {
  const CustomerRetentionMetrics({
    this.totalCustomers = 0,
    this.newCustomersInPeriod = 0,
    this.returningCustomersInPeriod = 0,
    this.repeatCustomerRate = 0.0,
    this.customersWithPendingBalance = 0,
    this.topCustomers = const [],
  });

  final int totalCustomers;
  final int newCustomersInPeriod;
  final int returningCustomersInPeriod;
  final double repeatCustomerRate;
  final int customersWithPendingBalance;
  final List<TopCustomerMetric> topCustomers;
}

class DashboardTransactionItem {
  const DashboardTransactionItem({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    required this.method,
    required this.recordedAt,
    this.isSuccess = true,
  });

  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final String method;
  final DateTime recordedAt;
  final bool isSuccess;
}

enum SmartAlertSeverity { info, warning, danger }

class DashboardSmartAlert {
  const DashboardSmartAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.count = 0,
    required this.actionLabel,
    required this.actionRoute,
  });

  final String id;
  final String title;
  final String message;
  final SmartAlertSeverity severity;
  final int count;
  final String actionLabel;
  final String actionRoute;
}
