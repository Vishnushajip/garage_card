import 'package:garage_card/features/shared/models/vehicle_model.dart';

class CustomerVehiclesState {
  const CustomerVehiclesState({
    this.vehicles = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  final List<VehicleModel> vehicles;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String searchQuery;

  CustomerVehiclesState copyWith({
    List<VehicleModel>? vehicles,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? searchQuery,
  }) {
    return CustomerVehiclesState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
