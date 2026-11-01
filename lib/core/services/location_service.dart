import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'web_maps_interop.dart';

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
  static String get googleMapsApiKey {
    const mask = 0x5A;
    const bytes = [
      27,
      19,
      32,
      59,
      9,
      35,
      25,
      18,
      14,
      50,
      11,
      19,
      48,
      10,
      27,
      42,
      47,
      28,
      18,
      119,
      15,
      45,
      48,
      35,
      0,
      0,
      63,
      111,
      3,
      104,
      41,
      34,
      61,
      25,
      29,
      110,
      111,
      0,
      19,
    ];
    return String.fromCharCodes(bytes.map((b) => b ^ mask));
  }

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

    if (kIsWeb) {
      try {
        final webJson = await callWebReverseGeocode(latitude, longitude);
        if (webJson != null && webJson.isNotEmpty) {
          final data = jsonDecode(webJson) as Map<String, dynamic>;
          final formatted = data['formatted_address'] as String? ?? '';
          final comps = data['address_components'] as List<dynamic>?;
          if (formatted.isNotEmpty) {
            String? street;
            String? city;
            String? state;
            String? country;
            String? postalCode;

            if (comps != null) {
              for (final c in comps) {
                if (c is Map<String, dynamic>) {
                  final types =
                      (c['types'] as List<dynamic>?)
                          ?.map((t) => t.toString())
                          .toList() ??
                      [];
                  final longName = c['long_name'] as String? ?? '';
                  if (types.contains('route') ||
                      types.contains('street_address')) {
                    street = longName;
                  } else if (types.contains('locality') ||
                      types.contains('administrative_area_level_2')) {
                    city ??= longName;
                  } else if (types.contains('administrative_area_level_1')) {
                    state = longName;
                  } else if (types.contains('country')) {
                    country = longName;
                  } else if (types.contains('postal_code')) {
                    postalCode = longName;
                  }
                }
              }
            }

            final details = LocationDetails(
              latitude: latitude,
              longitude: longitude,
              displayName: formatted,
              street: street,
              city: city,
              state: state,
              country: country,
              postalCode: postalCode,
            );
            _reverseGeocodeCache[cacheKey] = details;
            return details;
          }
        }
      } catch (_) {}
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
      final headers = kIsWeb
          ? <String, String>{}
          : {'User-Agent': 'WeFixAutomotiveApp/1.0 (dev.inspirezest.wefix)'};
      final response = await client
          .get(uri, headers: headers)
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

  Future<List<LocationDetails>> searchPlaces(
    String query, {
    double? proximityLat,
    double? proximityLng,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final cacheKey =
        '${trimmed.toLowerCase()}_${proximityLat?.toStringAsFixed(2)}_${proximityLng?.toStringAsFixed(2)}';
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    if (kIsWeb) {
      try {
        final webJson = await callWebSearchPlaces(
          trimmed,
          proximityLat,
          proximityLng,
        );
        if (webJson != null && webJson.isNotEmpty) {
          final list = jsonDecode(webJson) as List<dynamic>;
          final results = <LocationDetails>[];
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final name = item['name'] as String? ?? '';
              final addr = item['formatted_address'] as String? ?? '';
              final lat = (item['lat'] as num?)?.toDouble();
              final lng = (item['lng'] as num?)?.toDouble();
              if (lat != null && lng != null && lat != 0 && lng != 0) {
                results.add(
                  LocationDetails(
                    latitude: lat,
                    longitude: lng,
                    displayName: addr.isNotEmpty ? '$name, $addr' : name,
                    street: name,
                    city: _extractCityFromAddress(addr),
                  ),
                );
              }
            }
          }
          if (results.isNotEmpty) {
            _searchCache[cacheKey] = results;
            return results;
          }
        }
      } catch (_) {}
    }

    try {
      final locParam = (proximityLat != null && proximityLng != null)
          ? '&location=$proximityLat,$proximityLng&radius=25000'
          : '';
      final placesUri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(trimmed)}$locParam&key=$googleMapsApiKey',
      );
      final client = http.Client();
      final response = await client
          .get(placesUri)
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
              final name = item['name'] as String? ?? '';
              final addr = item['formatted_address'] as String? ?? '';
              final geom = item['geometry'] as Map<String, dynamic>?;
              final loc = geom?['location'] as Map<String, dynamic>?;
              final lat = (loc?['lat'] as num?)?.toDouble();
              final lng = (loc?['lng'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                list.add(
                  LocationDetails(
                    latitude: lat,
                    longitude: lng,
                    displayName: addr.isNotEmpty ? '$name, $addr' : name,
                    street: name,
                    city: _extractCityFromAddress(addr),
                  ),
                );
              }
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
      final viewboxParam = (proximityLat != null && proximityLng != null)
          ? '&viewbox=${proximityLng - 0.4},${proximityLat + 0.4},${proximityLng + 0.4},${proximityLat - 0.4}'
          : '';
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(trimmed)}&format=json&limit=8&addressdetails=1$viewboxParam',
      );
      final client = http.Client();
      final headers = kIsWeb
          ? <String, String>{}
          : {'User-Agent': 'WeFixAutomotiveApp/1.0 (dev.inspirezest.wefix)'};
      final response = await client
          .get(uri, headers: headers)
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
              final road =
                  address?['road'] as String? ??
                  address?['suburb'] as String? ??
                  address?['shop'] as String? ??
                  address?['amenity'] as String?;
              final city =
                  address?['city'] as String? ??
                  address?['town'] as String? ??
                  address?['village'] as String? ??
                  address?['county'] as String?;
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
        if (results.isNotEmpty) {
          _searchCache[cacheKey] = results;
          return results;
        }
      }
    } catch (_) {}
    return [];
  }

  String? _extractCityFromAddress(String address) {
    if (address.isEmpty) return null;
    final parts = address.split(',');
    if (parts.length >= 3) {
      return parts[parts.length - 3].trim();
    }
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return null;
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
