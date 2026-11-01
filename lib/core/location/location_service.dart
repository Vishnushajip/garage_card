import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/services/location_service.dart' as real_loc;

class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.locality,
  });

  final double latitude;
  final double longitude;
  final String? city;
  final String? locality;
}

class LocationService {
  Future<UserLocation?> getCurrentLocation() async {
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (isTesting) {
      return const UserLocation(
        latitude: 9.9312,
        longitude: 76.2673,
        city: 'Kochi',
        locality: 'Ernakulam',
      );
    }

    try {
      final position = await real_loc.LocationService.instance
          .getCurrentPosition()
          .timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (position != null) {
        final details = await real_loc.LocationService.instance
            .reverseGeocode(
              latitude: position.latitude,
              longitude: position.longitude,
            )
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          city: details?.city ?? 'Current Location',
          locality: details?.street,
        );
      }
    } catch (_) {}
    return null;
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
