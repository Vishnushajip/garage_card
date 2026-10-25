import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_jobs_state.dart';

class CustomerJobsViewModel extends Notifier<CustomerJobsState> {
  @override
  CustomerJobsState build() {
    _loadJobs();
    return const CustomerJobsState(isLoading: true);
  }

  String? get _currentCustomerId {
    final profile = ref.read(authViewModelProvider).userProfile;
    if (profile != null && profile.uid.isNotEmpty) {
      return profile.uid;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadJobs() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastDocument: null,
      hasMore: true,
    );
    try {
      final uid = _currentCustomerId;
      if (uid == null) {
        state = state.copyWith(
          isLoading: false,
          jobs: [],
          hasMore: false,
          lastDocument: null,
        );
        return;
      }

      final result = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(
            customerId: uid,
            status: state.filterStatus,
            limit: 10,
          );

      state = state.copyWith(
        isLoading: false,
        jobs: result.items,
        hasMore: result.hasMore,
        lastDocument: result.lastDocument,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isFetchingNextPage || !state.hasMore || state.isLoading) {
      return;
    }

    state = state.copyWith(isFetchingNextPage: true);
    try {
      final uid = _currentCustomerId;
      if (uid == null) {
        state = state.copyWith(isFetchingNextPage: false, hasMore: false);
        return;
      }

      final result = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(
            customerId: uid,
            status: state.filterStatus,
            limit: 10,
            lastDocument: state.lastDocument,
          );

      final combined = [...state.jobs, ...result.items];
      state = state.copyWith(
        isFetchingNextPage: false,
        jobs: combined,
        hasMore: result.hasMore,
        lastDocument: result.lastDocument,
      );
    } catch (_) {
      state = state.copyWith(isFetchingNextPage: false);
    }
  }

  Future<void> loadJobDetail(String jobId) async {
    state = state.copyWith(isLoadingDetail: true);
    try {
      final uid = _currentCustomerId;
      final jobs = await ref
          .read(garageRepositoryProvider)
          .getServiceJobs(customerId: uid);
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
