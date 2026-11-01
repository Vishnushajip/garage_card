import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/services/location_service.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('LocationService URL & Coordinate Parsing Tests', () {
    test('parses at-format Google Maps URL correctly', () {
      const url =
          'https://www.google.com/maps/@9.9674251,76.2891342,17z?entry=ttu';
      final coords = LocationService.instance.parseCoordinatesFromUrl(url);

      expect(coords, isNotNull);
      expect(coords!.latitude, closeTo(9.9674, 0.001));
      expect(coords.longitude, closeTo(76.2891, 0.001));
    });

    test('parses query-format Google Maps URL correctly', () {
      const url = 'https://maps.google.com/?q=10.0158,76.3418&entry=gps';
      final coords = LocationService.instance.parseCoordinatesFromUrl(url);

      expect(coords, isNotNull);
      expect(coords!.latitude, closeTo(10.0158, 0.001));
      expect(coords.longitude, closeTo(76.3418, 0.001));
    });

    test('parses direct comma-separated coordinates', () {
      const direct = '8.5241, 76.9366';
      final coords = LocationService.instance.parseCoordinatesFromUrl(direct);

      expect(coords, isNotNull);
      expect(coords!.latitude, closeTo(8.5241, 0.0001));
      expect(coords.longitude, closeTo(76.9366, 0.0001));
    });

    test('returns null on invalid url', () {
      const invalid = 'https://example.com/not-a-map';
      final coords = LocationService.instance.parseCoordinatesFromUrl(invalid);

      expect(coords, isNull);
    });

    test('LocationDetails shortAddress fallback formats correctly', () {
      const details = LocationDetails(
        latitude: 9.9674,
        longitude: 76.2891,
        displayName: 'Marine Drive, Ernakulam, Kochi, Kerala, 682031, India',
        street: 'Marine Drive',
        city: 'Kochi',
        state: 'Kerala',
      );

      expect(details.shortAddress, equals('Marine Drive, Kochi, Kerala'));
      expect(details.latLng, equals(const LatLng(9.9674, 76.2891)));
    });
  });
}
