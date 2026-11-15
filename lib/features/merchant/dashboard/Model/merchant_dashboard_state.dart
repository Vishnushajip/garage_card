import 'package:garage_card/features/shared/models/appointment_model.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import 'dashboard_analytics_models.dart';

class MerchantDashboardState {
  const MerchantDashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.garage,
    this.selectedTimeRange = DashboardTimeRange.last30Days,
    this.customStartDate,
    this.customEndDate,
    this.financialMetrics = const DashboardFinancialMetrics(),
    this.operationalMetrics = const DashboardOperationalMetrics(),
    this.mechanicMetrics = const [],
    this.customerMetrics = const CustomerRetentionMetrics(),
    this.recentTransactions = const [],
    this.smartAlerts = const [],
    this.selectedJobFilter = 'all',
    this.totalActiveJobs = 0,
    this.jobsAwaitingInspection = 0,
    this.estimatesAwaitingApproval = 0,
    this.jobsInProgress = 0,
    this.vehiclesReady = 0,
    this.totalCompletedJobs = 0,
    this.totalClientsCount = 0,
    this.totalRevenue = 0.0,
    this.totalUnpaidAmount = 0.0,
    this.recentJobs = const [],
    this.recentCustomers = const [],
    this.pendingEstimates = const [],
    this.unpaidInvoices = const [],
    this.appointments = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final GarageModel? garage;
  final DashboardTimeRange selectedTimeRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final DashboardFinancialMetrics financialMetrics;
  final DashboardOperationalMetrics operationalMetrics;
  final List<MechanicPerformanceMetric> mechanicMetrics;
  final CustomerRetentionMetrics customerMetrics;
  final List<DashboardTransactionItem> recentTransactions;
  final List<DashboardSmartAlert> smartAlerts;
  final String selectedJobFilter;
  final int totalActiveJobs;
  final int jobsAwaitingInspection;
  final int estimatesAwaitingApproval;
  final int jobsInProgress;
  final int vehiclesReady;
  final int totalCompletedJobs;
  final int totalClientsCount;
  final double totalRevenue;
  final double totalUnpaidAmount;
  final List<ServiceJobModel> recentJobs;
  final List<CustomerModel> recentCustomers;
  final List<EstimateModel> pendingEstimates;
  final List<InvoiceModel> unpaidInvoices;
  final List<AppointmentModel> appointments;

  List<ServiceJobModel> get filteredRecentJobs {
    switch (selectedJobFilter) {
      case 'in_progress':
        return recentJobs.where((j) => j.isActiveRepair).toList();
      case 'pending_assignment':
        return recentJobs
            .where(
              (j) =>
                  j.technicianName.trim().isEmpty &&
                  !j.isCompletedRepair &&
                  !j.isCancelled,
            )
            .toList();
      case 'ready_for_pickup':
        return recentJobs
            .where(
              (j) =>
                  j.status.toLowerCase() == 'readyforcollection' ||
                  j.status.toLowerCase() == 'ready_for_collection',
            )
            .toList();
      case 'completed':
        return recentJobs.where((j) => j.isCompletedRepair).toList();
      case 'overdue':
        final now = DateTime.now();
        return recentJobs
            .where(
              (j) =>
                  !j.isCompletedRepair &&
                  !j.isCancelled &&
                  j.estimatedCompletionDate != null &&
                  j.estimatedCompletionDate!.isBefore(now),
            )
            .toList();
      case 'all':
      default:
        return recentJobs;
    }
  }

  MerchantDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    GarageModel? garage,
    DashboardTimeRange? selectedTimeRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    DashboardFinancialMetrics? financialMetrics,
    DashboardOperationalMetrics? operationalMetrics,
    List<MechanicPerformanceMetric>? mechanicMetrics,
    CustomerRetentionMetrics? customerMetrics,
    List<DashboardTransactionItem>? recentTransactions,
    List<DashboardSmartAlert>? smartAlerts,
    String? selectedJobFilter,
    int? totalActiveJobs,
    int? jobsAwaitingInspection,
    int? estimatesAwaitingApproval,
    int? jobsInProgress,
    int? vehiclesReady,
    int? totalCompletedJobs,
    int? totalClientsCount,
    double? totalRevenue,
    double? totalUnpaidAmount,
    List<ServiceJobModel>? recentJobs,
    List<CustomerModel>? recentCustomers,
    List<EstimateModel>? pendingEstimates,
    List<InvoiceModel>? unpaidInvoices,
    List<AppointmentModel>? appointments,
  }) {
    return MerchantDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      garage: garage ?? this.garage,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      financialMetrics: financialMetrics ?? this.financialMetrics,
      operationalMetrics: operationalMetrics ?? this.operationalMetrics,
      mechanicMetrics: mechanicMetrics ?? this.mechanicMetrics,
      customerMetrics: customerMetrics ?? this.customerMetrics,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      smartAlerts: smartAlerts ?? this.smartAlerts,
      selectedJobFilter: selectedJobFilter ?? this.selectedJobFilter,
      totalActiveJobs: totalActiveJobs ?? this.totalActiveJobs,
      jobsAwaitingInspection:
          jobsAwaitingInspection ?? this.jobsAwaitingInspection,
      estimatesAwaitingApproval:
          estimatesAwaitingApproval ?? this.estimatesAwaitingApproval,
      jobsInProgress: jobsInProgress ?? this.jobsInProgress,
      vehiclesReady: vehiclesReady ?? this.vehiclesReady,
      totalCompletedJobs: totalCompletedJobs ?? this.totalCompletedJobs,
      totalClientsCount: totalClientsCount ?? this.totalClientsCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalUnpaidAmount: totalUnpaidAmount ?? this.totalUnpaidAmount,
      recentJobs: recentJobs ?? this.recentJobs,
      recentCustomers: recentCustomers ?? this.recentCustomers,
      pendingEstimates: pendingEstimates ?? this.pendingEstimates,
      unpaidInvoices: unpaidInvoices ?? this.unpaidInvoices,
      appointments: appointments ?? this.appointments,
    );
  }
}
