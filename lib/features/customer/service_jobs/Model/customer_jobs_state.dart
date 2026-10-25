import 'package:garage_card/features/shared/models/job_status_history_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class CustomerJobsState {
  const CustomerJobsState({
    this.jobs = const [],
    this.selectedJob,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isFetchingNextPage = false,
    this.hasMore = true,
    this.lastDocument,
    this.errorMessage,
    this.filterStatus,
  });

  final List<ServiceJobModel> jobs;
  final ServiceJobModel? selectedJob;
  final List<JobStatusHistoryModel> history;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isFetchingNextPage;
  final bool hasMore;
  final Object? lastDocument;
  final String? errorMessage;
  final String? filterStatus;

  CustomerJobsState copyWith({
    List<ServiceJobModel>? jobs,
    ServiceJobModel? selectedJob,
    List<JobStatusHistoryModel>? history,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isFetchingNextPage,
    bool? hasMore,
    Object? lastDocument,
    String? errorMessage,
    String? filterStatus,
  }) {
    return CustomerJobsState(
      jobs: jobs ?? this.jobs,
      selectedJob: selectedJob ?? this.selectedJob,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      errorMessage: errorMessage,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}
