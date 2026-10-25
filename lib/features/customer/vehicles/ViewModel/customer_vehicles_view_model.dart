import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_vehicles_state.dart';

class CustomerVehiclesViewModel extends Notifier<CustomerVehiclesState> {
  @override
  CustomerVehiclesState build() {
    Future.microtask(_loadVehicles);
    return const CustomerVehiclesState(isLoading: true);
  }

  String? get _currentCustomerId {
    final profile = ref.read(authViewModelProvider).userProfile;
    if (profile != null && profile.uid.isNotEmpty) {
      return profile.uid;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadVehicles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final uid = _currentCustomerId;
      if (uid == null) {
        state = state.copyWith(isLoading: false, vehicles: []);
        return;
      }
      final list = await ref
          .read(garageRepositoryProvider)
          .getVehicles(customerId: uid, search: state.searchQuery);
      state = state.copyWith(isLoading: false, vehicles: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> registerVehicle({
    required String make,
    required String model,
    required int year,
    required String licensePlate,
    required String fuelType,
    required int currentOdometer,
    required String color,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final uid = _currentCustomerId ?? '';
      final veh = VehicleModel(
        id: '',
        garageId: 'garage_demo_1',
        customerId: uid,
        make: make,
        model: model,
        year: year,
        licensePlate: licensePlate,
        fuelType: fuelType,
        currentOdometer: currentOdometer,
        color: color,
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(garageRepositoryProvider)
          .createVehicle(veh);
      state = state.copyWith(
        isSaving: false,
        vehicles: [created, ...state.vehicles],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadVehicles();
  }
}

final customerVehiclesViewModelProvider =
    NotifierProvider<CustomerVehiclesViewModel, CustomerVehiclesState>(
      CustomerVehiclesViewModel.new,
    );
