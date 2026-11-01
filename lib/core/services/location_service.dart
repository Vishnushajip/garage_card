import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationDetails {
  const LocationDetails({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  final double latitude;
  final double longitude;
  final String displayName;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  LatLng get latLng => LatLng(latitude, longitude);

  String get shortAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (parts.isNotEmpty) return parts.join(', ');
    return displayName;
  }
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  static const LatLng defaultKeralaCenter = LatLng(9.9674, 76.2891);

  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && !kIsWeb) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return await Geolocator.getCurrentPosition(locationSettings: settings);
    } catch (_) {
      try {
        const fallbackSettings = LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        );
        return await Geolocator.getCurrentPosition(
          locationSettings: fallbackSettings,
        );
      } catch (_) {
        return null;
      }
    }
  }

  Future<LocationDetails?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1',
      );
      final client = http.Client();
      final response = await client
          .get(
            uri,
            headers: {
              'User-Agent': 'WeFixAutomotiveApp/1.0 (dev.inspirezest.wefix)',
            },
          )
          .timeout(const Duration(seconds: 6));
      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName = data['display_name'] as String? ?? '';
        final address = data['address'] as Map<String, dynamic>?;

        final road = address?['road'] as String?;
        final suburb = address?['suburb'] as String?;
        final city =
            address?['city'] as String? ??
            address?['town'] as String? ??
            address?['village'] as String? ??
            address?['county'] as String?;
        final state = address?['state'] as String?;
        final country = address?['country'] as String?;
        final postcode = address?['postcode'] as String?;

        String? street = road;
        if (street != null && suburb != null && !street.contains(suburb)) {
          street = '$street, $suburb';
        } else if (street == null && suburb != null) {
          street = suburb;
        }

        return LocationDetails(
          latitude: latitude,
          longitude: longitude,
          displayName: displayName,
          street: street,
          city: city,
          state: state,
          country: country,
          postalCode: postcode,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<List<LocationDetails>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(trimmed)}&format=json&limit=5&addressdetails=1',
      );
      final client = http.Client();
      final response = await client
          .get(
            uri,
            headers: {
              'User-Agent': 'WeFixAutomotiveApp/1.0 (dev.inspirezest.wefix)',
            },
          )
          .timeout(const Duration(seconds: 6));
      client.close();

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        final results = <LocationDetails>[];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final lat = double.tryParse(item['lat']?.toString() ?? '');
            final lon = double.tryParse(item['lon']?.toString() ?? '');
            if (lat != null && lon != null) {
              final displayName = item['display_name'] as String? ?? '';
              final address = item['address'] as Map<String, dynamic>?;
              final road = address?['road'] as String?;
              final city =
                  address?['city'] as String? ??
                  address?['town'] as String? ??
                  address?['village'] as String?;
              final state = address?['state'] as String?;
              final country = address?['country'] as String?;
              final postcode = address?['postcode'] as String?;

              results.add(
                LocationDetails(
                  latitude: lat,
                  longitude: lon,
                  displayName: displayName,
                  street: road,
                  city: city,
                  state: state,
                  country: country,
                  postalCode: postcode,
                ),
              );
            }
          }
        }
        return results;
      }
    } catch (_) {}
    return [];
  }

  LatLng? parseCoordinatesFromUrl(String url) {
    if (url.trim().isEmpty) return null;

    final regexAt = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final matchAt = regexAt.firstMatch(url);
    if (matchAt != null) {
      final lat = double.tryParse(matchAt.group(1)!);
      final lng = double.tryParse(matchAt.group(2)!);
      if (lat != null && lng != null) return LatLng(lat, lng);
    }

    final regexQuery = RegExp(
      r'[?&](?:q|ll|destination)=(-?\d+\.\d+),(-?\d+\.\d+)',
    );
    final matchQuery = regexQuery.firstMatch(url);
    if (matchQuery != null) {
      final lat = double.tryParse(matchQuery.group(1)!);
      final lng = double.tryParse(matchQuery.group(2)!);
      if (lat != null && lng != null) return LatLng(lat, lng);
    }

    final regexDirect = RegExp(r'^(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)$');
    final matchDirect = regexDirect.firstMatch(url.trim());
    if (matchDirect != null) {
      final lat = double.tryParse(matchDirect.group(1)!);
      final lng = double.tryParse(matchDirect.group(2)!);
      if (lat != null && lng != null) return LatLng(lat, lng);
    }

    return null;
  }
}
