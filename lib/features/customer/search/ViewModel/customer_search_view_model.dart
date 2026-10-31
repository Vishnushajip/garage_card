import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/location/location_service.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_search_state.dart';

class CustomerSearchViewModel extends Notifier<CustomerSearchState> {
  CustomerSearchViewModel(this.initialQuery);

  final String? initialQuery;
  late final GarageRepository _repo;
  late final LocationService _locationService;

  @override
  CustomerSearchState build() {
    _repo = ref.watch(garageRepositoryProvider);
    _locationService = ref.watch(locationServiceProvider);
    Future.microtask(_init);
    return CustomerSearchState(query: initialQuery ?? '', isLoading: true);
  }

  Future<void> _init() async {
    try {
      final loc = await _locationService.getCurrentLocation();
      if (loc != null) {
        state = state.copyWith(
          userLat: loc.latitude,
          userLon: loc.longitude,
          hasLocationPermission: true,
        );
      }
    } catch (_) {}
    await executeSearch();
  }

  Future<void> setQuery(String query) async {
    state = state.copyWith(query: query);
    await executeSearch();
  }

  Future<void> setDistance(double? distance) async {
    state = state.copyWith(
      selectedDistance: distance,
      clearDistance: distance == null,
    );
    await executeSearch();
  }

  Future<void> setVehicleType(String type) async {
    state = state.copyWith(selectedVehicleType: type);
    await executeSearch();
  }

  Future<void> setCategory(String category) async {
    state = state.copyWith(selectedCategory: category);
    await executeSearch();
  }

  Future<void> setPriceBudget({double? min, double? max}) async {
    state = state.copyWith(
      minPrice: min,
      maxPrice: max,
      clearPrice: min == null && max == null,
    );
    await executeSearch();
  }

  Future<void> setSortBy(String sortBy) async {
    state = state.copyWith(sortBy: sortBy);
    await executeSearch();
  }

  Future<void> clearAllFilters() async {
    state = state.copyWith(
      clearDistance: true,
      selectedVehicleType: 'All',
      selectedCategory: 'All',
      clearPrice: true,
      sortBy: 'nearest',
    );
    await executeSearch();
  }

  Future<void> executeSearch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await _repo.searchGaragesAndServices(
        query: state.query.isNotEmpty ? state.query : null,
        category: state.selectedCategory != 'All'
            ? state.selectedCategory
            : null,
        vehicleType: state.selectedVehicleType != 'All'
            ? state.selectedVehicleType
            : null,
        maxDistanceKm: state.selectedDistance,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sortBy: state.sortBy,
        userLat: state.userLat,
        userLon: state.userLon,
      );
      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Search failed: $e',
      );
    }
  }
}

final customerSearchViewModelProvider =
    NotifierProvider.family<
      CustomerSearchViewModel,
      CustomerSearchState,
      String?
    >(CustomerSearchViewModel.new);
