import 'package:garage_card/features/shared/models/garage_search_result_model.dart';

class CustomerSearchState {
  const CustomerSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedDistance,
    this.selectedVehicleType = 'All',
    this.selectedCategory = 'All',
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'nearest',
    this.userLat = 9.9674,
    this.userLon = 76.2891,
    this.hasLocationPermission = false,
  });

  final String query;
  final List<GarageSearchResultModel> results;
  final bool isLoading;
  final String? errorMessage;
  final double? selectedDistance;
  final String selectedVehicleType;
  final String selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final double userLat;
  final double userLon;
  final bool hasLocationPermission;

  int get activeFilterCount {
    int count = 0;
    if (selectedDistance != null) count++;
    if (selectedVehicleType != 'All') count++;
    if (selectedCategory != 'All') count++;
    if (minPrice != null || maxPrice != null) count++;
    if (sortBy != 'nearest') count++;
    return count;
  }

  CustomerSearchState copyWith({
    String? query,
    List<GarageSearchResultModel>? results,
    bool? isLoading,
    String? errorMessage,
    double? selectedDistance,
    bool clearDistance = false,
    String? selectedVehicleType,
    String? selectedCategory,
    double? minPrice,
    double? maxPrice,
    bool clearPrice = false,
    String? sortBy,
    double? userLat,
    double? userLon,
    bool? hasLocationPermission,
  }) {
    return CustomerSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedDistance: clearDistance
          ? null
          : (selectedDistance ?? this.selectedDistance),
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
      userLat: userLat ?? this.userLat,
      userLon: userLon ?? this.userLon,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}
