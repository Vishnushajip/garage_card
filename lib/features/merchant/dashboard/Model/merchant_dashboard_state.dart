import 'package:garage_card/features/shared/models/appointment_model.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class MerchantDashboardState {
  const MerchantDashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.garage,
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

  MerchantDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    GarageModel? garage,
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
