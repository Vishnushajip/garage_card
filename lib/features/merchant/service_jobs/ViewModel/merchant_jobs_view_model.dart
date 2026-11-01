import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/supplemental_work_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_jobs_state.dart';

class MerchantJobsViewModel extends Notifier<MerchantJobsState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return '';
  }

  @override
  MerchantJobsState build() {
    Future.microtask(_loadJobs);
    return const MerchantJobsState(isLoading: true);
  }

  Future<void> _loadJobs() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastDocument: null,
      hasMore: true,
    );
    try {
      final res = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(
            garageId: _effectiveGarageId(),
            status: state.filterStatus,
            search: state.searchQuery,
            limit: 15,
          );
      state = state.copyWith(
        isLoading: false,
        jobs: res.items,
        hasMore: res.hasMore,
        lastDocument: res.lastDocument,
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
      final res = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(
            garageId: _effectiveGarageId(),
            status: state.filterStatus,
            search: state.searchQuery,
            limit: 15,
            lastDocument: state.lastDocument,
          );
      state = state.copyWith(
        isFetchingNextPage: false,
        jobs: [...state.jobs, ...res.items],
        hasMore: res.hasMore,
        lastDocument: res.lastDocument,
      );
    } catch (_) {
      state = state.copyWith(isFetchingNextPage: false);
    }
  }

  Future<void> selectJob(String jobId) async {
    state = state.copyWith(isLoading: true);
    try {
      final jobs = await ref
          .read(garageRepositoryProvider)
          .getServiceJobs(garageId: _effectiveGarageId());
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

  Future<bool> startRepair({
    required String jobId,
    String? technicianName,
    String? notes,
  }) async {
    state = state.copyWith(isUpdatingStatus: true, errorMessage: null);
    try {
      final user = ref.read(authViewModelProvider).userProfile;
      final staffUid = user?.uid ?? 'Staff';
      await ref
          .read(garageRepositoryProvider)
          .startRepair(
            garageId: _effectiveGarageId(),
            jobId: jobId,
            startedByUid: staffUid,
            technicianName: technicianName,
            notes: notes,
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

  Future<bool> completeRepair({
    required String jobId,
    int? finalOdometer,
    DateTime? nextServiceDue,
    int? nextServiceOdometer,
    String? nextServiceType,
    String? notes,
  }) async {
    state = state.copyWith(isUpdatingStatus: true, errorMessage: null);
    try {
      final user = ref.read(authViewModelProvider).userProfile;
      final staffUid = user?.uid ?? 'Staff';
      await ref
          .read(garageRepositoryProvider)
          .completeRepair(
            garageId: _effectiveGarageId(),
            jobId: jobId,
            completedByUid: staffUid,
            finalOdometer: finalOdometer,
            nextServiceDue: nextServiceDue,
            nextServiceOdometer: nextServiceOdometer,
            nextServiceType: nextServiceType,
            notes: notes,
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
        garageId: _effectiveGarageId(),
        customerId: '',
        vehicleId: '',
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

  Future<bool> verifyGatePass({
    required String jobId,
    required String otp,
  }) async {
    try {
      final garageId = _effectiveGarageId();
      final success = await ref
          .read(garageRepositoryProvider)
          .verifyGatePass(garageId, jobId, otp);
      if (success) {
        await selectJob(jobId);
        await _loadJobs();
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateQcChecklist({
    required String jobId,
    required Map<String, bool> checklist,
    required String inspectorName,
  }) async {
    try {
      final garageId = _effectiveGarageId();
      await ref
          .read(garageRepositoryProvider)
          .updateQcChecklist(
            garageId,
            jobId,
            checklist,
            inspectorName: inspectorName,
          );
      await selectJob(jobId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addSupplementalWork({
    required String jobId,
    required SupplementalWorkItem item,
  }) async {
    try {
      final garageId = _effectiveGarageId();
      await ref
          .read(garageRepositoryProvider)
          .addSupplementalWork(garageId, jobId, item);
      await selectJob(jobId);
      return true;
    } catch (_) {
      return false;
    }
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
