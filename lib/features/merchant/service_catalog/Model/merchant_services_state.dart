import 'package:garage_card/features/shared/models/garage_service_model.dart';

class MerchantServicesState {
  const MerchantServicesState({
    this.services = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.selectedCategory = 'All',
    this.errorMessage,
  });

  final List<GarageServiceModel> services;
  final bool isLoading;
  final bool isSaving;
  final String selectedCategory;
  final String? errorMessage;

  List<String> get categories {
    final set = <String>{'All'};
    for (final s in services) {
      if (s.category.isNotEmpty) {
        set.add(s.category);
      }
    }
    return set.toList();
  }

  List<GarageServiceModel> get filteredServices {
    if (selectedCategory == 'All') {
      return services;
    }
    return services.where((s) => s.category == selectedCategory).toList();
  }

  MerchantServicesState copyWith({
    List<GarageServiceModel>? services,
    bool? isLoading,
    bool? isSaving,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return MerchantServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
    );
  }
}
