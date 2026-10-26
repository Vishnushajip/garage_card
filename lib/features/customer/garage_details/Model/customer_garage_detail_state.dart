import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/models/review_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';

class CustomerGarageDetailState {
  const CustomerGarageDetailState({
    this.garage,
    this.services = const [],
    this.reviews = const [],
    this.customerVehicles = const [],
    this.selectedVehicle,
    this.selectedCategory = 'All',
    this.isLoading = false,
    this.isSubmittingReview = false,
    this.errorMessage,
  });

  final GarageModel? garage;
  final List<GarageServiceModel> services;
  final List<ReviewModel> reviews;
  final List<VehicleModel> customerVehicles;
  final VehicleModel? selectedVehicle;
  final String selectedCategory;
  final bool isLoading;
  final bool isSubmittingReview;
  final String? errorMessage;

  List<String> get availableCategories {
    final set = <String>{'All'};
    for (final s in services) {
      if (s.isActive && s.category.isNotEmpty) {
        set.add(s.category);
      }
    }
    return set.toList();
  }

  List<GarageServiceModel> get filteredServices {
    final active = services.where((s) => s.isActive).toList();
    if (selectedCategory == 'All') {
      return active;
    }
    return active.where((s) => s.category == selectedCategory).toList();
  }

  CustomerGarageDetailState copyWith({
    GarageModel? garage,
    List<GarageServiceModel>? services,
    List<ReviewModel>? reviews,
    List<VehicleModel>? customerVehicles,
    VehicleModel? selectedVehicle,
    bool clearSelectedVehicle = false,
    String? selectedCategory,
    bool? isLoading,
    bool? isSubmittingReview,
    String? errorMessage,
  }) {
    return CustomerGarageDetailState(
      garage: garage ?? this.garage,
      services: services ?? this.services,
      reviews: reviews ?? this.reviews,
      customerVehicles: customerVehicles ?? this.customerVehicles,
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      errorMessage: errorMessage,
    );
  }
}
