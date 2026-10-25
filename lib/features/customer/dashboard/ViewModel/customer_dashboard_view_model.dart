import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/location/location_service.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_dashboard_state.dart';

class CustomerDashboardViewModel extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() {
    Future.microtask(_loadDashboardData);
    return const CustomerDashboardState(isLoading: true);
  }

  Future<void> _loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final locService = ref.read(locationServiceProvider);
      final location = await locService.getCurrentLocation();

      final jobs = await repo.getServiceJobs(customerId: 'cust_demo_1');
      final vehicles = await repo.getVehicles(customerId: 'cust_demo_1');
      final estimates = await repo.getEstimates(customerId: 'cust_demo_1');
      final invoices = await repo.getInvoices(customerId: 'cust_demo_1');
      final reminders = await repo.getReminders(customerId: 'cust_demo_1');

      final nearby = await repo.getNearbyGarages(
        latitude: location?.latitude ?? 9.9312,
        longitude: location?.longitude ?? 76.2673,
      );

      final activeJobs = jobs.where((j) => j.status != 'completed').toList();
      final pendingEstimates = estimates.where((e) => e.isPending).toList();
      final unpaidInvoices = invoices.where((i) => !i.isPaid).toList();

      state = state.copyWith(
        isLoading: false,
        activeJobs: activeJobs,
        vehicles: vehicles,
        pendingEstimates: pendingEstimates,
        unpaidInvoices: unpaidInvoices,
        upcomingReminders: reminders,
        nearbyGarages: nearby,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadDashboardData();
  }
}

final customerDashboardViewModelProvider =
    NotifierProvider<CustomerDashboardViewModel, CustomerDashboardState>(
      CustomerDashboardViewModel.new,
    );
