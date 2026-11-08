import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/service_recall_model.dart';

final serviceRecallsViewModelProvider =
    NotifierProvider<ServiceRecallsViewModel, ServiceRecallsState>(
      ServiceRecallsViewModel.new,
    );

class ServiceRecallsViewModel extends Notifier<ServiceRecallsState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return '';
  }

  @override
  ServiceRecallsState build() {
    Future.microtask(_loadRecalls);
    return const ServiceRecallsState(isLoading: true);
  }

  Future<void> _loadRecalls() async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final res = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(garageId: garageId, limit: 100);

      final completedJobs = res.items.where((j) {
        final s = j.status.toLowerCase();
        return s == 'completed' || s == 'delivered' || s == 'closed';
      }).toList();

      final recalls = _computeRecalls(completedJobs);
      state = state.copyWith(isLoading: false, items: recalls);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  List<ServiceRecallItem> _computeRecalls(List<ServiceJobModel> jobs) {
    final Map<String, ServiceJobModel> latestByVehicle = {};

    for (final j in jobs) {
      final key = j.vehicleDisplay.trim().toLowerCase();
      if (key.isEmpty) continue;

      final existing = latestByVehicle[key];
      if (existing == null) {
        latestByVehicle[key] = j;
      } else {
        final existingDate =
            existing.completedDate ?? existing.createdAt ?? DateTime.now();
        final candidateDate = j.completedDate ?? j.createdAt ?? DateTime.now();
        if (candidateDate.isAfter(existingDate)) {
          latestByVehicle[key] = j;
        }
      }
    }

    final now = DateTime.now();
    final List<ServiceRecallItem> items = [];

    for (final j in latestByVehicle.values) {
      final serviceDate = j.completedDate ?? j.createdAt ?? DateTime.now();
      final daysDiff = now.difference(serviceDate).inDays;

      String status;
      if (daysDiff >= 120) {
        status = 'overdue';
      } else if (daysDiff >= 75) {
        status = 'dueThisMonth';
      } else {
        status = 'upcoming';
      }

      items.add(
        ServiceRecallItem(
          vehicleDisplay: j.vehicleDisplay.isNotEmpty
              ? j.vehicleDisplay
              : j.jobNumber,
          customerName: j.customerName,
          customerPhone: j.customerPhone,
          lastServiceDate: serviceDate,
          daysSinceLastService: daysDiff,
          lastJobNumber: j.jobNumber,
          lastComplaints: j.complaints,
          estimatedOdometer: j.odometerReading,
          status: status,
        ),
      );
    }

    items.sort(
      (a, b) => b.daysSinceLastService.compareTo(a.daysSinceLastService),
    );
    return items;
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async {
    await _loadRecalls();
  }
}
