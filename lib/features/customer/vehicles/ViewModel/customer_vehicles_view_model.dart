import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import '../Model/customer_vehicles_state.dart';

class CustomerVehiclesViewModel extends Notifier<CustomerVehiclesState> {
  @override
  CustomerVehiclesState build() {
    Future.microtask(_loadVehicles);
    return const CustomerVehiclesState(isLoading: true);
  }

  Future<void> _loadVehicles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref.read(garageRepositoryProvider).getVehicles(
            customerId: 'cust_demo_1',
            search: state.searchQuery,
          );
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
      final veh = VehicleModel(
        id: '',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_1',
        make: make,
        model: model,
        year: year,
        licensePlate: licensePlate,
        fuelType: fuelType,
        currentOdometer: currentOdometer,
        color: color,
        createdAt: DateTime.now(),
      );

      final created =
          await ref.read(garageRepositoryProvider).createVehicle(veh);
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
