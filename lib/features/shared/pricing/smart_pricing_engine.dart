import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';

enum EvaluatedPricingType {
  fixed,
  category,
  attribute,
  startingPrice,
  quotation,
  override,
  unresolved,
}

class EvaluatedPrice {
  const EvaluatedPrice({
    required this.type,
    this.price,
    this.startingPrice,
    this.matchedRuleLabel,
    this.currencyCode = 'INR',
  });

  final EvaluatedPricingType type;
  final double? price;
  final double? startingPrice;
  final String? matchedRuleLabel;
  final String currencyCode;

  bool get isQuotationRequired =>
      type == EvaluatedPricingType.quotation ||
      type == EvaluatedPricingType.unresolved;

  bool get isStartingPrice => type == EvaluatedPricingType.startingPrice;

  String get formattedDisplay {
    switch (type) {
      case EvaluatedPricingType.override:
      case EvaluatedPricingType.fixed:
      case EvaluatedPricingType.category:
      case EvaluatedPricingType.attribute:
        if (price != null) {
          return CurrencyFormatter.format(price!, currencyCode: currencyCode);
        }
        return 'Quotation Required';
      case EvaluatedPricingType.startingPrice:
        if (startingPrice != null) {
          return 'Starting from ${CurrencyFormatter.format(startingPrice!, currencyCode: currencyCode)}';
        }
        return 'Quotation Required';
      case EvaluatedPricingType.quotation:
        return 'Quotation Required';
      case EvaluatedPricingType.unresolved:
        return 'Inspection Required';
    }
  }

  String get pricingSubtitle {
    switch (type) {
      case EvaluatedPricingType.override:
        return 'Custom job override';
      case EvaluatedPricingType.fixed:
        return 'Fixed price for all vehicles';
      case EvaluatedPricingType.category:
        return matchedRuleLabel != null
            ? 'Based on category ($matchedRuleLabel)'
            : 'Vehicle category pricing';
      case EvaluatedPricingType.attribute:
        return matchedRuleLabel != null
            ? 'Attribute matched: $matchedRuleLabel'
            : 'Engine capacity / segment rule';
      case EvaluatedPricingType.startingPrice:
        return 'Final price confirmed after inspection';
      case EvaluatedPricingType.quotation:
        return 'Custom estimate prepared after inspection';
      case EvaluatedPricingType.unresolved:
        return 'Price confirmed upon physical inspection';
    }
  }
}

class SmartPricingEngine {
  SmartPricingEngine._();

  static EvaluatedPrice evaluate({
    required GarageServiceModel service,
    VehicleModel? vehicle,
    double? customOverridePrice,
    String currencyCode = 'INR',
  }) {
    if (customOverridePrice != null && customOverridePrice > 0) {
      return EvaluatedPrice(
        type: EvaluatedPricingType.override,
        price: customOverridePrice,
        currencyCode: currencyCode,
      );
    }

    if (service.pricingMethod == 'quotation') {
      return EvaluatedPrice(
        type: EvaluatedPricingType.quotation,
        currencyCode: currencyCode,
      );
    }

    if (vehicle != null && service.attributeRules.isNotEmpty) {
      for (final rule in service.attributeRules) {
        if (rule.matchesVehicle(vehicle.vehicleType, vehicle.engineCc)) {
          return EvaluatedPrice(
            type: EvaluatedPricingType.attribute,
            price: rule.price,
            matchedRuleLabel: rule.label,
            currencyCode: currencyCode,
          );
        }
      }
    }

    if (vehicle != null && service.categoryPrices.isNotEmpty) {
      final normalizedType = vehicle.vehicleType.toLowerCase();
      if (service.categoryPrices.containsKey(normalizedType)) {
        return EvaluatedPrice(
          type: EvaluatedPricingType.category,
          price: service.categoryPrices[normalizedType],
          matchedRuleLabel: vehicle.vehicleType,
          currencyCode: currencyCode,
        );
      }
    }

    if (service.pricingMethod == 'fixed' && service.fixedPrice != null) {
      return EvaluatedPrice(
        type: EvaluatedPricingType.fixed,
        price: service.fixedPrice,
        currencyCode: currencyCode,
      );
    }

    if (service.pricingMethod == 'startingPrice' &&
        service.startingPrice != null) {
      return EvaluatedPrice(
        type: EvaluatedPricingType.startingPrice,
        startingPrice: service.startingPrice,
        currencyCode: currencyCode,
      );
    }

    if (service.fixedPrice != null && service.fixedPrice! > 0) {
      return EvaluatedPrice(
        type: EvaluatedPricingType.fixed,
        price: service.fixedPrice,
        currencyCode: currencyCode,
      );
    }

    if (service.startingPrice != null && service.startingPrice! > 0) {
      return EvaluatedPrice(
        type: EvaluatedPricingType.startingPrice,
        startingPrice: service.startingPrice,
        currencyCode: currencyCode,
      );
    }

    return EvaluatedPrice(
      type: EvaluatedPricingType.unresolved,
      currencyCode: currencyCode,
    );
  }
}
