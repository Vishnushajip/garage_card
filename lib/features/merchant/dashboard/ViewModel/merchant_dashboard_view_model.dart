import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/appointment_model.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_dashboard_state.dart';

class MerchantDashboardViewModel extends Notifier<MerchantDashboardState> {
  @override
  MerchantDashboardState build() {
    Future.microtask(_loadDashboardMetrics);
    return const MerchantDashboardState(isLoading: true);
  }

  Future<void> _loadDashboardMetrics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = ref.read(authViewModelProvider).userProfile;
      final repo = ref.read(garageRepositoryProvider);

      GarageModel? garage;
      if (user?.garageId != null && user!.garageId!.isNotEmpty) {
        garage = await repo.getGarageDetails(user.garageId!);
      } else if (user != null) {
        garage = await repo.getGarageByOwnerUid(user.uid);
      }

      if (garage == null) {
        state = state.copyWith(
          isLoading: false,
          garage: null,
          totalActiveJobs: 0,
          jobsAwaitingInspection: 0,
          estimatesAwaitingApproval: 0,
          jobsInProgress: 0,
          vehiclesReady: 0,
          totalCompletedJobs: 0,
          totalClientsCount: 0,
          totalRevenue: 0.0,
          totalUnpaidAmount: 0.0,
          recentJobs: const [],
          recentCustomers: const [],
          pendingEstimates: const [],
          unpaidInvoices: const [],
          appointments: const [],
        );
        return;
      }

      final garageId = garage.id;

      final results = await Future.wait([
        repo.getServiceJobs(garageId: garageId),
        repo.getCustomers(garageId: garageId),
        repo.getEstimates(garageId: garageId),
        repo.getInvoices(garageId: garageId),
        repo.getAppointments(garageId: garageId),
      ]);

      final jobs = results[0] as List<ServiceJobModel>;
      final customers = results[1] as List<CustomerModel>;
      final estimates = results[2] as List<EstimateModel>;
      final invoices = results[3] as List<InvoiceModel>;
      final appointments = results[4] as List<AppointmentModel>;

      final activeJobs = jobs.where((j) => j.status != 'completed').toList();
      final completedJobs = jobs
          .where((j) => j.status == 'completed' || j.status == 'closed')
          .length;
      final awaitingInspection = jobs
          .where((j) => j.status == 'inspectionPending')
          .length;
      final awaitingEstimate = estimates
          .where((e) => e.status == 'sent')
          .length;
      final inProgress = jobs.where((j) => j.status == 'inProgress').length;
      final readyForCollection = jobs
          .where((j) => j.status == 'readyForCollection')
          .length;

      final unpaidInvoices = invoices.where((i) => !i.isPaid).toList();
      final totalUnpaid = unpaidInvoices.fold<double>(
        0.0,
        (sum, item) => sum + item.balanceDue,
      );
      final totalRevenue = invoices.fold<double>(
        0.0,
        (sum, item) => sum + item.paidAmount,
      );

      state = state.copyWith(
        isLoading: false,
        garage: garage,
        totalActiveJobs: activeJobs.length,
        totalCompletedJobs: completedJobs,
        totalClientsCount: customers.length,
        totalRevenue: totalRevenue,
        jobsAwaitingInspection: awaitingInspection,
        estimatesAwaitingApproval: awaitingEstimate,
        jobsInProgress: inProgress,
        vehiclesReady: readyForCollection,
        totalUnpaidAmount: totalUnpaid,
        recentJobs: jobs.take(5).toList(),
        recentCustomers: customers.take(4).toList(),
        pendingEstimates: estimates.where((e) => e.isPending).toList(),
        unpaidInvoices: unpaidInvoices,
        appointments: appointments,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadDashboardMetrics();
  }
}

final merchantDashboardViewModelProvider =
    NotifierProvider<MerchantDashboardViewModel, MerchantDashboardState>(
      MerchantDashboardViewModel.new,
    );
