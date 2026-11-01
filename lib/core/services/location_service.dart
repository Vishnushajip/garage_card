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
  static const String googleMapsApiKey =
      'AIzaSyDIWXi7mtIUzX0V47wci-WetyCBle_ll2E';

  final Map<String, LocationDetails> _reverseGeocodeCache = {};
  final Map<String, List<LocationDetails>> _searchCache = {};

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

  LocationDetails _parseGoogleGeocodeResult(
    Map<String, dynamic> result, {
    double? fallbackLat,
    double? fallbackLng,
  }) {
    final formattedAddress = result['formatted_address'] as String? ?? '';
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = (location?['lat'] as num?)?.toDouble() ?? fallbackLat ?? 0.0;
    final lng = (location?['lng'] as num?)?.toDouble() ?? fallbackLng ?? 0.0;

    final components = result['address_components'] as List<dynamic>? ?? [];
    String? street;
    String? city;
    String? state;
    String? country;
    String? postalCode;

    for (final comp in components) {
      if (comp is! Map<String, dynamic>) continue;
      final types =
          (comp['types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final longName = comp['long_name'] as String? ?? '';

      if (types.contains('route') ||
          types.contains('sublocality_level_1') ||
          types.contains('sublocality')) {
        street = street == null ? longName : '$street, $longName';
      } else if (types.contains('locality')) {
        city = longName;
      } else if (city == null &&
          (types.contains('administrative_area_level_2') ||
              types.contains('sublocality_level_2'))) {
        city = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = longName;
      } else if (types.contains('country')) {
        country = longName;
      } else if (types.contains('postal_code')) {
        postalCode = longName;
      }
    }

    return LocationDetails(
      latitude: lat,
      longitude: lng,
      displayName: formattedAddress,
      street: street,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
    );
  }

  Future<LocationDetails?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey =
        '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';
    if (_reverseGeocodeCache.containsKey(cacheKey)) {
      return _reverseGeocodeCache[cacheKey];
    }

    try {
      final googleUri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsApiKey',
      );
      final client = http.Client();
      final response = await client
          .get(googleUri)
          .timeout(const Duration(seconds: 4));
      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        final results = data['results'] as List<dynamic>?;
        if (status == 'OK' && results != null && results.isNotEmpty) {
          final first = results.first as Map<String, dynamic>;
          final parsed = _parseGoogleGeocodeResult(
            first,
            fallbackLat: latitude,
            fallbackLng: longitude,
          );
          _reverseGeocodeCache[cacheKey] = parsed;
          return parsed;
        }
      }
    } catch (_) {}

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

        final details = LocationDetails(
          latitude: latitude,
          longitude: longitude,
          displayName: displayName,
          street: street,
          city: city,
          state: state,
          country: country,
          postalCode: postcode,
        );
        _reverseGeocodeCache[cacheKey] = details;
        return details;
      }
    } catch (_) {}
    return null;
  }

  Future<List<LocationDetails>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    final cacheKey = trimmed.toLowerCase();
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    try {
      final googleUri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(trimmed)}&key=$googleMapsApiKey',
      );
      final client = http.Client();
      final response = await client
          .get(googleUri)
          .timeout(const Duration(seconds: 4));
      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        final results = data['results'] as List<dynamic>?;
        if (status == 'OK' && results != null && results.isNotEmpty) {
          final list = <LocationDetails>[];
          for (final item in results) {
            if (item is Map<String, dynamic>) {
              list.add(_parseGoogleGeocodeResult(item));
            }
          }
          if (list.isNotEmpty) {
            _searchCache[cacheKey] = list;
            return list;
          }
        }
      }
    } catch (_) {}

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
        _searchCache[cacheKey] = results;
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
