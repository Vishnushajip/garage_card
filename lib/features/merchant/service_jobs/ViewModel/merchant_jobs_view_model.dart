import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_jobs_state.dart';

class MerchantJobsViewModel extends Notifier<MerchantJobsState> {
  @override
  MerchantJobsState build() {
    Future.microtask(_loadJobs);
    return const MerchantJobsState(isLoading: true);
  }

  Future<void> _loadJobs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getServiceJobs(
            garageId: 'garage_demo_1',
            status: state.filterStatus,
            search: state.searchQuery,
          );
      state = state.copyWith(isLoading: false, jobs: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectJob(String jobId) async {
    state = state.copyWith(isLoading: true);
    try {
      final jobs = await ref
          .read(garageRepositoryProvider)
          .getServiceJobs(garageId: 'garage_demo_1');
      final job = jobs.cast<ServiceJobModel?>().firstWhere(
        (j) => j?.id == jobId,
        orElse: () => null,
      );
      final history = await ref
          .read(garageRepositoryProvider)
          .getJobHistory(jobId);

      state = state.copyWith(
        isLoading: false,
        selectedJob: job,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateStatus({
    required String jobId,
    required String newStatus,
    required String notes,
  }) async {
    state = state.copyWith(isUpdatingStatus: true, errorMessage: null);
    try {
      await ref
          .read(garageRepositoryProvider)
          .updateJobStatus(
            jobId: jobId,
            newStatus: newStatus,
            notes: notes,
            updatedBy: 'Staff',
          );
      await selectJob(jobId);
      await _loadJobs();
      state = state.copyWith(isUpdatingStatus: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> createJob({
    required String customerName,
    required String vehicleDisplay,
    required String complaint,
    required int odometerReading,
    required String technicianName,
  }) async {
    state = state.copyWith(isCreatingJob: true, errorMessage: null);
    try {
      final newJob = ServiceJobModel(
        id: '',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_1',
        vehicleId: 'veh_1',
        jobNumber: 'JOB-2026-${DateTime.now().millisecondsSinceEpoch % 1000}',
        status: 'received',
        odometerReading: odometerReading,
        complaints: [complaint],
        technicianName: technicianName,
        customerName: customerName,
        vehicleDisplay: vehicleDisplay,
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(garageRepositoryProvider)
          .createServiceJob(newJob);
      state = state.copyWith(
        isCreatingJob: false,
        jobs: [created, ...state.jobs],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isCreatingJob: false, errorMessage: e.toString());
      return false;
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _loadJobs();
  }

  void filterByStatus(String? status) {
    state = state.copyWith(filterStatus: status);
    _loadJobs();
  }

  Future<void> refresh() async {
    await _loadJobs();
    if (state.selectedJob != null) {
      await selectJob(state.selectedJob!.id);
    }
  }
}

final merchantJobsViewModelProvider =
    NotifierProvider<MerchantJobsViewModel, MerchantJobsState>(
      MerchantJobsViewModel.new,
    );
