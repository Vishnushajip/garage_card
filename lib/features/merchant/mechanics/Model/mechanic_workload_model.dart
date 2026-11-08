import 'package:garage_card/features/shared/models/mechanic_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class MechanicWorkloadModel {
  const MechanicWorkloadModel({
    required this.mechanic,
    this.activeJobs = const [],
    this.completedJobsCount = 0,
    this.totalLaborRevenue = 0.0,
    this.commissionRate = 10.0,
    this.earnedCommission = 0.0,
  });

  final MechanicModel mechanic;
  final List<ServiceJobModel> activeJobs;
  final int completedJobsCount;
  final double totalLaborRevenue;
  final double commissionRate;
  final double earnedCommission;

  int get activeJobsCount => activeJobs.length;

  MechanicWorkloadModel copyWith({
    MechanicModel? mechanic,
    List<ServiceJobModel>? activeJobs,
    int? completedJobsCount,
    double? totalLaborRevenue,
    double? commissionRate,
    double? earnedCommission,
  }) {
    return MechanicWorkloadModel(
      mechanic: mechanic ?? this.mechanic,
      activeJobs: activeJobs ?? this.activeJobs,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      totalLaborRevenue: totalLaborRevenue ?? this.totalLaborRevenue,
      commissionRate: commissionRate ?? this.commissionRate,
      earnedCommission: earnedCommission ?? this.earnedCommission,
    );
  }
}

class MerchantMechanicsState {
  const MerchantMechanicsState({
    this.isLoading = false,
    this.workloads = const [],
    this.enableIncentives = false,
    this.defaultCommissionRate = 10.0,
    this.searchQuery = '',
    this.errorMessage,
  });

  final bool isLoading;
  final List<MechanicWorkloadModel> workloads;
  final bool enableIncentives;
  final double defaultCommissionRate;
  final String searchQuery;
  final String? errorMessage;

  int get totalMechanics => workloads.length;

  int get totalActiveAssignedJobs =>
      workloads.fold(0, (sum, item) => sum + item.activeJobsCount);

  int get totalCompletedJobs =>
      workloads.fold(0, (sum, item) => sum + item.completedJobsCount);

  double get grandLaborRevenue =>
      workloads.fold(0.0, (sum, item) => sum + item.totalLaborRevenue);

  double get grandEarnedCommission =>
      workloads.fold(0.0, (sum, item) => sum + item.earnedCommission);

  List<MechanicWorkloadModel> get filteredWorkloads {
    if (searchQuery.trim().isEmpty) return workloads;
    final query = searchQuery.trim().toLowerCase();
    return workloads.where((item) {
      final name = item.mechanic.name.toLowerCase();
      final specialty = item.mechanic.specialization.toLowerCase();
      return name.contains(query) || specialty.contains(query);
    }).toList();
  }

  MerchantMechanicsState copyWith({
    bool? isLoading,
    List<MechanicWorkloadModel>? workloads,
    bool? enableIncentives,
    double? defaultCommissionRate,
    String? searchQuery,
    String? errorMessage,
  }) {
    return MerchantMechanicsState(
      isLoading: isLoading ?? this.isLoading,
      workloads: workloads ?? this.workloads,
      enableIncentives: enableIncentives ?? this.enableIncentives,
      defaultCommissionRate:
          defaultCommissionRate ?? this.defaultCommissionRate,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}
