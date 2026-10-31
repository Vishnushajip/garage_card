import 'package:garage_card/core/formatting/date_formatter.dart';

class VehiclePricingTier {
  const VehiclePricingTier({
    required this.vehicleType,
    this.pricingType = 'fixed',
    this.fixedPrice,
    this.minPrice,
    this.maxPrice,
  });

  final String vehicleType;
  final String pricingType;
  final double? fixedPrice;
  final double? minPrice;
  final double? maxPrice;

  Map<String, dynamic> toMap() {
    return {
      'vehicleType': vehicleType,
      'pricingType': pricingType,
      'fixedPrice': fixedPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
    };
  }

  factory VehiclePricingTier.fromMap(Map<String, dynamic> map) {
    return VehiclePricingTier(
      vehicleType: map['vehicleType'] as String? ?? '',
      pricingType: map['pricingType'] as String? ?? 'fixed',
      fixedPrice: (map['fixedPrice'] as num?)?.toDouble(),
      minPrice: (map['minPrice'] as num?)?.toDouble(),
      maxPrice: (map['maxPrice'] as num?)?.toDouble(),
    );
  }

  VehiclePricingTier copyWith({
    String? vehicleType,
    String? pricingType,
    double? fixedPrice,
    double? minPrice,
    double? maxPrice,
  }) {
    return VehiclePricingTier(
      vehicleType: vehicleType ?? this.vehicleType,
      pricingType: pricingType ?? this.pricingType,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

class PricingAttributeRule {
  const PricingAttributeRule({
    required this.label,
    this.vehicleType,
    this.minCc,
    this.maxCc,
    this.segment,
    required this.price,
  });

  final String label;
  final String? vehicleType;
  final int? minCc;
  final int? maxCc;
  final String? segment;
  final double price;

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'vehicleType': vehicleType,
      'minCc': minCc,
      'maxCc': maxCc,
      'segment': segment,
      'price': price,
    };
  }

  factory PricingAttributeRule.fromMap(Map<String, dynamic> map) {
    return PricingAttributeRule(
      label: map['label'] as String? ?? '',
      vehicleType: map['vehicleType'] as String?,
      minCc: (map['minCc'] as num?)?.toInt(),
      maxCc: (map['maxCc'] as num?)?.toInt(),
      segment: map['segment'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool matchesVehicle(String vType, int? vCc) {
    if (vehicleType != null &&
        vehicleType!.isNotEmpty &&
        vehicleType!.toLowerCase() != vType.toLowerCase()) {
      return false;
    }
    if (minCc != null && (vCc == null || vCc < minCc!)) {
      return false;
    }
    if (maxCc != null && (vCc == null || vCc > maxCc!)) {
      return false;
    }
    return true;
  }
}

class GarageServiceModel {
  const GarageServiceModel({
    required this.id,
    required this.garageId,
    this.merchantId = '',
    required this.name,
    this.description = '',
    this.category = 'General',
    this.imageUrl,
    List<String> applicableVehicleTypes = const [
      'motorcycle',
      'scooter',
      'car',
    ],
    List<String>? supportedVehicleTypes,
    this.pricingMethod = 'fixed',
    this.pricingType = 'fixed',
    this.fixedPrice,
    this.minPrice,
    this.maxPrice,
    this.startingPrice,
    this.categoryPrices = const {},
    this.vehiclePricing = const [],
    this.attributeRules = const [],
    this.estimatedDuration = '1-2 hrs',
    this.includedItems = const [],
    this.excludedItems = const [],
    this.requiredParts = const [],
    this.specialInstructions,
    this.terms,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  }) : applicableVehicleTypes = supportedVehicleTypes ?? applicableVehicleTypes;

  final String id;
  final String garageId;
  final String merchantId;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final List<String> applicableVehicleTypes;
  List<String> get supportedVehicleTypes => applicableVehicleTypes;
  final String pricingMethod;
  final String pricingType;
  final double? fixedPrice;
  final double? minPrice;
  final double? maxPrice;
  final double? startingPrice;
  final Map<String, double> categoryPrices;
  final List<VehiclePricingTier> vehiclePricing;
  final List<PricingAttributeRule> attributeRules;
  final String estimatedDuration;
  final List<String> includedItems;
  final List<String> excludedItems;
  final List<String> requiredParts;
  final String? specialInstructions;
  final String? terms;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get effectivePricingType =>
      pricingType.isNotEmpty && pricingType != 'fixed'
      ? pricingType
      : pricingMethod;

  bool supportsVehicle(String vehicleType) {
    final v = vehicleType.toLowerCase().trim();
    if (applicableVehicleTypes.isEmpty) return true;
    return applicableVehicleTypes.any((t) => t.toLowerCase().trim() == v);
  }

  VehiclePricingTier? getTierForVehicle(String vehicleType) {
    final v = vehicleType.toLowerCase().trim();
    for (final tier in vehiclePricing) {
      if (tier.vehicleType.toLowerCase().trim() == v) {
        return tier;
      }
    }
    return null;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'merchantId': merchantId,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'applicableVehicleTypes': applicableVehicleTypes,
      'pricingMethod': pricingMethod,
      'pricingType': pricingType,
      'fixedPrice': fixedPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'startingPrice': startingPrice,
      'categoryPrices': categoryPrices,
      'vehiclePricing': vehiclePricing.map((e) => e.toMap()).toList(),
      'attributeRules': attributeRules.map((e) => e.toMap()).toList(),
      'estimatedDuration': estimatedDuration,
      'includedItems': includedItems,
      'excludedItems': excludedItems,
      'requiredParts': requiredParts,
      'specialInstructions': specialInstructions,
      'terms': terms,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory GarageServiceModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final catPricesRaw = data['categoryPrices'];
    final Map<String, double> parsedCatPrices = {};
    if (catPricesRaw is Map) {
      catPricesRaw.forEach((key, val) {
        if (val is num) {
          parsedCatPrices[key.toString()] = val.toDouble();
        }
      });
    }

    final vPricingRaw = data['vehiclePricing'] as List<dynamic>?;
    final parsedVPricing = vPricingRaw != null
        ? vPricingRaw
              .whereType<Map<String, dynamic>>()
              .map(VehiclePricingTier.fromMap)
              .toList()
        : <VehiclePricingTier>[];

    final attrRulesRaw = data['attributeRules'] as List<dynamic>?;
    final parsedAttrRules = attrRulesRaw != null
        ? attrRulesRaw
              .whereType<Map<String, dynamic>>()
              .map(PricingAttributeRule.fromMap)
              .toList()
        : <PricingAttributeRule>[];

    final incRaw = data['includedItems'] as List<dynamic>?;
    final excRaw = data['excludedItems'] as List<dynamic>?;
    final partsRaw = data['requiredParts'] as List<dynamic>?;

    final pType =
        data['pricingType'] as String? ??
        data['pricingMethod'] as String? ??
        'fixed';

    return GarageServiceModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      merchantId: data['merchantId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      imageUrl: data['imageUrl'] as String?,
      applicableVehicleTypes:
          (data['applicableVehicleTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['motorcycle', 'scooter', 'car'],
      pricingMethod: data['pricingMethod'] as String? ?? 'fixed',
      pricingType: pType,
      fixedPrice: (data['fixedPrice'] as num?)?.toDouble(),
      minPrice: (data['minPrice'] as num?)?.toDouble(),
      maxPrice: (data['maxPrice'] as num?)?.toDouble(),
      startingPrice: (data['startingPrice'] as num?)?.toDouble(),
      categoryPrices: parsedCatPrices,
      vehiclePricing: parsedVPricing,
      attributeRules: parsedAttrRules,
      estimatedDuration: data['estimatedDuration'] as String? ?? '1-2 hrs',
      includedItems: incRaw?.map((e) => e.toString()).toList() ?? const [],
      excludedItems: excRaw?.map((e) => e.toString()).toList() ?? const [],
      requiredParts: partsRaw?.map((e) => e.toString()).toList() ?? const [],
      specialInstructions: data['specialInstructions'] as String?,
      terms: data['terms'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: DateFormatter.parse(data['createdAt']),
      updatedAt: DateFormatter.parse(data['updatedAt']),
    );
  }

  GarageServiceModel copyWith({
    String? id,
    String? garageId,
    String? merchantId,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    List<String>? applicableVehicleTypes,
    String? pricingMethod,
    String? pricingType,
    double? fixedPrice,
    double? minPrice,
    double? maxPrice,
    double? startingPrice,
    Map<String, double>? categoryPrices,
    List<VehiclePricingTier>? vehiclePricing,
    List<PricingAttributeRule>? attributeRules,
    String? estimatedDuration,
    List<String>? includedItems,
    List<String>? excludedItems,
    List<String>? requiredParts,
    String? specialInstructions,
    String? terms,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GarageServiceModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      applicableVehicleTypes:
          applicableVehicleTypes ?? this.applicableVehicleTypes,
      pricingMethod: pricingMethod ?? this.pricingMethod,
      pricingType: pricingType ?? this.pricingType,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      startingPrice: startingPrice ?? this.startingPrice,
      categoryPrices: categoryPrices ?? this.categoryPrices,
      vehiclePricing: vehiclePricing ?? this.vehiclePricing,
      attributeRules: attributeRules ?? this.attributeRules,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      includedItems: includedItems ?? this.includedItems,
      excludedItems: excludedItems ?? this.excludedItems,
      requiredParts: requiredParts ?? this.requiredParts,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      terms: terms ?? this.terms,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
