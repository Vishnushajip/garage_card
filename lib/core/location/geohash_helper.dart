import 'dart:math' as math;

class GeohashHelper {
  GeohashHelper._();

  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  static ({double minLat, double maxLat, double minLon, double maxLon})
  calculateBoundingBox({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    const double earthRadiusKm = 6371.0;

    final latDelta = (radiusKm / earthRadiusKm) * (180.0 / math.pi);
    final lonDelta =
        (radiusKm / (earthRadiusKm * math.cos(_degreesToRadians(latitude)))) *
        (180.0 / math.pi);

    return (
      minLat: latitude - latDelta,
      maxLat: latitude + latDelta,
      minLon: longitude - lonDelta,
      maxLon: longitude + lonDelta,
    );
  }
}
