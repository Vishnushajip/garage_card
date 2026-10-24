import 'package:garage_card/features/shared/models/appointment_model.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class MerchantDashboardState {
  const MerchantDashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.totalActiveJobs = 0,
    this.jobsAwaitingInspection = 0,
    this.estimatesAwaitingApproval = 0,
    this.jobsInProgress = 0,
    this.vehiclesReady = 0,
    this.totalUnpaidAmount = 0.0,
    this.recentJobs = const [],
    this.recentCustomers = const [],
    this.pendingEstimates = const [],
    this.unpaidInvoices = const [],
    this.appointments = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final int totalActiveJobs;
  final int jobsAwaitingInspection;
  final int estimatesAwaitingApproval;
  final int jobsInProgress;
  final int vehiclesReady;
  final double totalUnpaidAmount;
  final List<ServiceJobModel> recentJobs;
  final List<CustomerModel> recentCustomers;
  final List<EstimateModel> pendingEstimates;
  final List<InvoiceModel> unpaidInvoices;
  final List<AppointmentModel> appointments;

  MerchantDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? totalActiveJobs,
    int? jobsAwaitingInspection,
    int? estimatesAwaitingApproval,
    int? jobsInProgress,
    int? vehiclesReady,
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
      totalActiveJobs: totalActiveJobs ?? this.totalActiveJobs,
      jobsAwaitingInspection:
          jobsAwaitingInspection ?? this.jobsAwaitingInspection,
      estimatesAwaitingApproval:
          estimatesAwaitingApproval ?? this.estimatesAwaitingApproval,
      jobsInProgress: jobsInProgress ?? this.jobsInProgress,
      vehiclesReady: vehiclesReady ?? this.vehiclesReady,
      totalUnpaidAmount: totalUnpaidAmount ?? this.totalUnpaidAmount,
      recentJobs: recentJobs ?? this.recentJobs,
      recentCustomers: recentCustomers ?? this.recentCustomers,
      pendingEstimates: pendingEstimates ?? this.pendingEstimates,
      unpaidInvoices: unpaidInvoices ?? this.unpaidInvoices,
      appointments: appointments ?? this.appointments,
    );
  }
}
