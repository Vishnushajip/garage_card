import 'package:garage_card/features/shared/models/job_status_history_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class MerchantJobsState {
  const MerchantJobsState({
    this.jobs = const [],
    this.selectedJob,
    this.history = const [],
    this.isLoading = false,
    this.isUpdatingStatus = false,
    this.isCreatingJob = false,
    this.isFetchingNextPage = false,
    this.hasMore = true,
    this.lastDocument,
    this.errorMessage,
    this.searchQuery = '',
    this.filterStatus,
  });

  final List<ServiceJobModel> jobs;
  final ServiceJobModel? selectedJob;
  final List<JobStatusHistoryModel> history;
  final bool isLoading;
  final bool isUpdatingStatus;
  final bool isCreatingJob;
  final bool isFetchingNextPage;
  final bool hasMore;
  final Object? lastDocument;
  final String? errorMessage;
  final String searchQuery;
  final String? filterStatus;

  MerchantJobsState copyWith({
    List<ServiceJobModel>? jobs,
    ServiceJobModel? selectedJob,
    List<JobStatusHistoryModel>? history,
    bool? isLoading,
    bool? isUpdatingStatus,
    bool? isCreatingJob,
    bool? isFetchingNextPage,
    bool? hasMore,
    Object? lastDocument,
    String? errorMessage,
    String? searchQuery,
    String? filterStatus,
  }) {
    return MerchantJobsState(
      jobs: jobs ?? this.jobs,
      selectedJob: selectedJob ?? this.selectedJob,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isCreatingJob: isCreatingJob ?? this.isCreatingJob,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}
