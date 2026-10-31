import 'garage_model.dart';
import 'garage_service_model.dart';
import '../pricing/smart_pricing_engine.dart';

class GarageSearchResultModel {
  const GarageSearchResultModel({
    required this.garage,
    required this.distanceKm,
    this.matchedService,
    this.evaluatedPrice,
  });

  final GarageModel garage;
  final double distanceKm;
  final GarageServiceModel? matchedService;
  final EvaluatedPrice? evaluatedPrice;

  GarageSearchResultModel copyWith({
    GarageModel? garage,
    double? distanceKm,
    GarageServiceModel? matchedService,
    EvaluatedPrice? evaluatedPrice,
  }) {
    return GarageSearchResultModel(
      garage: garage ?? this.garage,
      distanceKm: distanceKm ?? this.distanceKm,
      matchedService: matchedService ?? this.matchedService,
      evaluatedPrice: evaluatedPrice ?? this.evaluatedPrice,
    );
  }
}
