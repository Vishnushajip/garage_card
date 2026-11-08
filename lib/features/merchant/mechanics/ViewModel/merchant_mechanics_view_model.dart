import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/mechanic_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/mechanic_workload_model.dart';

final merchantMechanicsViewModelProvider =
    NotifierProvider<MerchantMechanicsViewModel, MerchantMechanicsState>(
      MerchantMechanicsViewModel.new,
    );

class MerchantMechanicsViewModel extends Notifier<MerchantMechanicsState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return '';
  }

  @override
  MerchantMechanicsState build() {
    Future.microtask(_loadData);
    return const MerchantMechanicsState(isLoading: true);
  }

  Future<void> _loadData() async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(garageRepositoryProvider);
      final mechanicsRes = await repo.getMechanicsPaginated(
        garageId: garageId,
        limit: 50,
      );
      final jobsRes = await repo.getServiceJobsPaginated(
        garageId: garageId,
        limit: 100,
      );

      final mechanics = mechanicsRes.items;
      final jobs = jobsRes.items;

      final workloads = _computeWorkloads(
        mechanics: mechanics,
        jobs: jobs,
        commissionRate: state.defaultCommissionRate,
      );

      state = state.copyWith(isLoading: false, workloads: workloads);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  List<MechanicWorkloadModel> _computeWorkloads({
    required List<MechanicModel> mechanics,
    required List<ServiceJobModel> jobs,
    required double commissionRate,
  }) {
    return mechanics.map((m) {
      final mechName = m.name.trim().toLowerCase();

      final matchingJobs = jobs.where((j) {
        final jMech = j.technicianName.trim().toLowerCase();
        return jMech.isNotEmpty &&
            (jMech == mechName || jMech.contains(mechName));
      }).toList();

      final active = matchingJobs.where((j) {
        final s = j.status.toLowerCase();
        return s != 'completed' && s != 'delivered' && s != 'cancelled';
      }).toList();

      final completed = matchingJobs.where((j) {
        final s = j.status.toLowerCase();
        return s == 'completed' || s == 'delivered';
      }).toList();

      double laborRevenue = 0.0;
      for (final j in completed) {
        double jobLabor = 350.0;
        for (final item in j.supplementalItems) {
          jobLabor += item.laborCost;
        }
        laborRevenue += jobLabor;
      }

      final earnedCommission = laborRevenue * (commissionRate / 100.0);

      return MechanicWorkloadModel(
        mechanic: m,
        activeJobs: active,
        completedJobsCount: completed.length,
        totalLaborRevenue: laborRevenue,
        commissionRate: commissionRate,
        earnedCommission: earnedCommission,
      );
    }).toList();
  }

  void toggleIncentives(bool enabled) {
    state = state.copyWith(enableIncentives: enabled);
  }

  void updateCommissionRate(double newRate) {
    final updated = state.workloads.map((w) {
      final earned = w.totalLaborRevenue * (newRate / 100.0);
      return w.copyWith(commissionRate: newRate, earnedCommission: earned);
    }).toList();

    state = state.copyWith(defaultCommissionRate: newRate, workloads: updated);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> addMechanic({
    required String name,
    required String phone,
    required String specialization,
  }) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty || name.trim().isEmpty) return false;

    try {
      final newMechanic = MechanicModel(
        id: '',
        garageId: garageId,
        name: name.trim(),
        phone: phone.trim(),
        specialization: specialization.trim(),
        isActive: true,
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(garageRepositoryProvider)
          .createMechanic(newMechanic);

      final newWorkload = MechanicWorkloadModel(
        mechanic: created,
        commissionRate: state.defaultCommissionRate,
      );

      state = state.copyWith(workloads: [newWorkload, ...state.workloads]);

      AppNotificationService.success('Mechanic added successfully');
      return true;
    } catch (e) {
      AppNotificationService.error('Failed to add mechanic: $e');
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
