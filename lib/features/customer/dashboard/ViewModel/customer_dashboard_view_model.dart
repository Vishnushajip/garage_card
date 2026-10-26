import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/location/location_service.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/service_reminder_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_dashboard_state.dart';

class CustomerDashboardViewModel extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() {
    Future.microtask(_loadDashboardData);
    return const CustomerDashboardState(isLoading: true);
  }

  String? get _currentCustomerId {
    final profile = ref.read(authViewModelProvider).userProfile;
    if (profile != null && profile.uid.isNotEmpty) {
      return profile.uid;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final locService = ref.read(locationServiceProvider);
      final customerId = _currentCustomerId;

      final locationFuture = locService.getCurrentLocation().timeout(
        const Duration(milliseconds: 1200),
        onTimeout: () => null,
      );

      final jobsFuture = customerId != null
          ? repo.getServiceJobs(customerId: customerId, limit: 10)
          : Future.value(<ServiceJobModel>[]);
      final vehiclesFuture = customerId != null
          ? repo.getVehicles(customerId: customerId, limit: 10)
          : Future.value(<VehicleModel>[]);
      final estimatesFuture = customerId != null
          ? repo.getEstimates(customerId: customerId, limit: 10)
          : Future.value(<EstimateModel>[]);
      final invoicesFuture = customerId != null
          ? repo.getInvoices(customerId: customerId, limit: 10)
          : Future.value(<InvoiceModel>[]);
      final remindersFuture = customerId != null
          ? repo.getReminders(customerId: customerId)
          : Future.value(<ServiceReminderModel>[]);

      final results = await Future.wait([
        locationFuture,
        jobsFuture,
        vehiclesFuture,
        estimatesFuture,
        invoicesFuture,
        remindersFuture,
      ]);

      final location = results[0] as dynamic;
      final jobs = results[1] as List<ServiceJobModel>;
      final vehicles = results[2] as List<VehicleModel>;
      final estimates = results[3] as List<EstimateModel>;
      final invoices = results[4] as List<InvoiceModel>;
      final reminders = results[5] as List<ServiceReminderModel>;

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
