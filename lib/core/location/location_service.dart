import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return const UserLocation(
      latitude: 9.9312,
      longitude: 76.2673,
      city: 'Kochi',
      locality: 'Ernakulam',
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
