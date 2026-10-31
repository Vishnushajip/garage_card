import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';

enum EvaluatedPricingType {
  fixed,
  range,
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
    this.minPrice,
    this.maxPrice,
    this.startingPrice,
    this.matchedRuleLabel,
    this.currencyCode = 'INR',
  });

  final EvaluatedPricingType type;
  final double? price;
  final double? minPrice;
  final double? maxPrice;
  final double? startingPrice;
  final String? matchedRuleLabel;
  final String currencyCode;

  bool get isQuotationRequired =>
      type == EvaluatedPricingType.quotation ||
      type == EvaluatedPricingType.unresolved;

  bool get isStartingPrice => type == EvaluatedPricingType.startingPrice;
  bool get isRange => type == EvaluatedPricingType.range;
  double? get amount => price ?? minPrice ?? startingPrice;

  String get formattedDisplay {
    switch (type) {
      case EvaluatedPricingType.override:
      case EvaluatedPricingType.fixed:
      case EvaluatedPricingType.category:
      case EvaluatedPricingType.attribute:
        if (price != null) {
          return CurrencyFormatter.format(price!, currencyCode: currencyCode);
        }
        return 'Contact for Price';
      case EvaluatedPricingType.range:
        if (minPrice != null && maxPrice != null) {
          final minFmt = CurrencyFormatter.format(
            minPrice!,
            currencyCode: currencyCode,
          );
          final maxFmt = CurrencyFormatter.format(
            maxPrice!,
            currencyCode: currencyCode,
          );
          return '$minFmt – $maxFmt';
        }
        if (minPrice != null) {
          return 'Starting from ${CurrencyFormatter.format(minPrice!, currencyCode: currencyCode)}';
        }
        return 'Contact for Price';
      case EvaluatedPricingType.startingPrice:
        if (startingPrice != null) {
          return 'Starting from ${CurrencyFormatter.format(startingPrice!, currencyCode: currencyCode)}';
        }
        return 'Contact for Price';
      case EvaluatedPricingType.quotation:
        return 'Contact for Price';
      case EvaluatedPricingType.unresolved:
        return 'Inspection Required';
    }
  }

  String get pricingSubtitle {
    switch (type) {
      case EvaluatedPricingType.override:
        return 'Custom job override';
      case EvaluatedPricingType.fixed:
        return matchedRuleLabel != null
            ? 'Fixed price for $matchedRuleLabel'
            : 'Fixed price for all vehicles';
      case EvaluatedPricingType.range:
        return matchedRuleLabel != null
            ? 'Estimated range for $matchedRuleLabel'
            : 'Price range depends on scope / parts';
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
        return 'Custom quote prepared after inspection';
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
    String? vehicleType,
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

    final pType = service.effectivePricingType.toLowerCase();

    if (pType == 'contact_for_price' ||
        pType == 'quotation' ||
        pType == 'contact') {
      return EvaluatedPrice(
        type: EvaluatedPricingType.quotation,
        currencyCode: currencyCode,
      );
    }

    final effectiveType = vehicle?.vehicleType ?? vehicleType;

    if (effectiveType != null && effectiveType.isNotEmpty) {
      final tier = service.getTierForVehicle(effectiveType);
      if (tier != null) {
        final tierType = tier.pricingType.toLowerCase();
        if (tierType == 'contact' || tierType == 'contact_for_price') {
          return EvaluatedPrice(
            type: EvaluatedPricingType.quotation,
            matchedRuleLabel: tier.vehicleType,
            currencyCode: currencyCode,
          );
        }
        if (tierType == 'range' &&
            tier.minPrice != null &&
            tier.maxPrice != null) {
          return EvaluatedPrice(
            type: EvaluatedPricingType.range,
            minPrice: tier.minPrice,
            maxPrice: tier.maxPrice,
            matchedRuleLabel: tier.vehicleType,
            currencyCode: currencyCode,
          );
        }
        if (tier.fixedPrice != null && tier.fixedPrice! > 0) {
          return EvaluatedPrice(
            type: EvaluatedPricingType.fixed,
            price: tier.fixedPrice,
            matchedRuleLabel: tier.vehicleType,
            currencyCode: currencyCode,
          );
        }
      }

      if (service.attributeRules.isNotEmpty) {
        for (final rule in service.attributeRules) {
          if (rule.matchesVehicle(effectiveType, vehicle?.engineCc)) {
            return EvaluatedPrice(
              type: EvaluatedPricingType.attribute,
              price: rule.price,
              matchedRuleLabel: rule.label,
              currencyCode: currencyCode,
            );
          }
        }
      }

      if (service.categoryPrices.isNotEmpty) {
        final normalizedType = effectiveType.toLowerCase();
        if (service.categoryPrices.containsKey(normalizedType)) {
          return EvaluatedPrice(
            type: EvaluatedPricingType.category,
            price: service.categoryPrices[normalizedType],
            matchedRuleLabel: effectiveType,
            currencyCode: currencyCode,
          );
        }
      }
    }

    if (pType == 'vehicle_specific' && service.vehiclePricing.isNotEmpty) {
      double? overallMin;
      double? overallMax;
      for (final tier in service.vehiclePricing) {
        if (tier.fixedPrice != null && tier.fixedPrice! > 0) {
          overallMin = overallMin == null
              ? tier.fixedPrice
              : (tier.fixedPrice! < overallMin ? tier.fixedPrice : overallMin);
          overallMax = overallMax == null
              ? tier.fixedPrice
              : (tier.fixedPrice! > overallMax ? tier.fixedPrice : overallMax);
        }
        if (tier.minPrice != null && tier.minPrice! > 0) {
          overallMin = overallMin == null
              ? tier.minPrice
              : (tier.minPrice! < overallMin ? tier.minPrice : overallMin);
        }
        if (tier.maxPrice != null && tier.maxPrice! > 0) {
          overallMax = overallMax == null
              ? tier.maxPrice
              : (tier.maxPrice! > overallMax ? tier.maxPrice : overallMax);
        }
      }
      if (overallMin != null &&
          overallMax != null &&
          overallMin != overallMax) {
        return EvaluatedPrice(
          type: EvaluatedPricingType.range,
          minPrice: overallMin,
          maxPrice: overallMax,
          currencyCode: currencyCode,
        );
      }
      if (overallMin != null) {
        return EvaluatedPrice(
          type: EvaluatedPricingType.fixed,
          price: overallMin,
          currencyCode: currencyCode,
        );
      }
    }

    if (pType == 'range' ||
        (service.minPrice != null && service.maxPrice != null)) {
      return EvaluatedPrice(
        type: EvaluatedPricingType.range,
        minPrice: service.minPrice,
        maxPrice: service.maxPrice,
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
