import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_jobs_state.dart';

class CustomerJobsViewModel extends Notifier<CustomerJobsState> {
  @override
  CustomerJobsState build() {
    _loadJobs();
    return const CustomerJobsState(isLoading: true);
  }

  Future<void> _loadJobs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getServiceJobs(
            customerId: 'cust_demo_1',
            status: state.filterStatus,
          );
      state = state.copyWith(isLoading: false, jobs: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadJobDetail(String jobId) async {
    state = state.copyWith(isLoadingDetail: true);
    try {
      final jobs = await ref
          .read(garageRepositoryProvider)
          .getServiceJobs(customerId: 'cust_demo_1');
      final job = jobs.cast().firstWhere(
        (j) => j.id == jobId,
        orElse: () => null,
      );
      final history = await ref
          .read(garageRepositoryProvider)
          .getJobHistory(jobId);

      state = state.copyWith(
        isLoadingDetail: false,
        selectedJob: job,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingDetail: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setFilter(String? status) async {
    state = state.copyWith(filterStatus: status);
    await _loadJobs();
  }

  Future<void> refresh() async {
    await _loadJobs();
    if (state.selectedJob != null) {
      await loadJobDetail(state.selectedJob!.id);
    }
  }
}

final customerJobsViewModelProvider =
    NotifierProvider<CustomerJobsViewModel, CustomerJobsState>(
      CustomerJobsViewModel.new,
    );
