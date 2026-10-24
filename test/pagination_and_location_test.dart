import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/location/geohash_helper.dart';
import 'package:garage_card/core/pagination/paginated_state.dart';

void main() {
  group('Location & Pagination Helper Tests', () {
    test('Haversine distance calculation between Kochi and Aluva', () {
      final distance = GeohashHelper.calculateDistanceKm(
        lat1: 9.9312,
        lon1: 76.2673,
        lat2: 10.1076,
        lon2: 76.3516,
      );

      expect(distance, greaterThan(15.0));
      expect(distance, lessThan(25.0));
    });

    test('Bounding box calculation creates valid min/max bounds', () {
      final bounds = GeohashHelper.calculateBoundingBox(
        latitude: 9.9312,
        longitude: 76.2673,
        radiusKm: 25.0,
      );

      expect(bounds.minLat, lessThan(9.9312));
      expect(bounds.maxLat, greaterThan(9.9312));
      expect(bounds.minLon, lessThan(76.2673));
      expect(bounds.maxLon, greaterThan(76.2673));
    });

    test('PaginatedState copyWith maintains items and updates state', () {
      const state = PaginatedState<String>(
        items: ['item1', 'item2'],
        hasMore: true,
      );

      final nextState = state.copyWith(
        items: [...state.items, 'item3'],
        hasMore: false,
        isFetchingNextPage: false,
      );

      expect(nextState.items.length, 3);
      expect(nextState.hasMore, isFalse);
    });
  });
}
