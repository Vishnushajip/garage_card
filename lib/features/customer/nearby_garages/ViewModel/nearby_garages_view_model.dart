import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/location/location_service.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import '../Model/nearby_garages_state.dart';

class NearbyGaragesViewModel extends Notifier<NearbyGaragesState> {
  @override
  NearbyGaragesState build() {
    Future.microtask(_loadInitialGarages);
    return const NearbyGaragesState(isLoading: true);
  }

  Future<void> _loadInitialGarages() async {
    state = state.copyWith(isLoading: true, errorMessage: null, page: 0);
    try {
      final loc = await ref.read(locationServiceProvider).getCurrentLocation();
      final lat = loc?.latitude ?? 9.9312;
      final lon = loc?.longitude ?? 76.2673;

      final results = await ref.read(garageRepositoryProvider).getNearbyGarages(
            latitude: lat,
            longitude: lon,
            searchQuery: state.searchQuery,
            limit: 20,
          );

      state = state.copyWith(
        isLoading: false,
        garages: results,
        userLatitude: lat,
        userLongitude: lon,
        hasMore: results.length >= 20,
        page: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await _loadInitialGarages();
  }

  Future<void> fetchNextPage() async {
    if (state.isFetchingNextPage || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isFetchingNextPage: true);
    try {
      final nextPage = state.page + 1;
      final results = await ref.read(garageRepositoryProvider).getNearbyGarages(
            latitude: state.userLatitude,
            longitude: state.userLongitude,
            searchQuery: state.searchQuery,
            limit: 20,
          );

      final existingIds = state.garages.map((g) => g.id).toSet();
      final newGarages = results.where((g) => !existingIds.contains(g.id)).toList();

      state = state.copyWith(
        isFetchingNextPage: false,
        garages: [...state.garages, ...newGarages],
        page: nextPage,
        hasMore: newGarages.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isFetchingNextPage: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadInitialGarages();
  }
}

final nearbyGaragesViewModelProvider =
    NotifierProvider<NearbyGaragesViewModel, NearbyGaragesState>(
  NearbyGaragesViewModel.new,
);
