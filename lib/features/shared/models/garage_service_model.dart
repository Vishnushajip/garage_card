import 'package:garage_card/core/formatting/date_formatter.dart';

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
    required this.name,
    this.description = '',
    this.category = 'General',
    this.imageUrl,
    this.applicableVehicleTypes = const ['motorcycle', 'scooter', 'car'],
    this.pricingMethod = 'fixed',
    this.fixedPrice,
    this.startingPrice,
    this.categoryPrices = const {},
    this.attributeRules = const [],
    this.estimatedDuration = '1-2 hrs',
    this.terms,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final List<String> applicableVehicleTypes;
  final String pricingMethod;
  final double? fixedPrice;
  final double? startingPrice;
  final Map<String, double> categoryPrices;
  final List<PricingAttributeRule> attributeRules;
  final String estimatedDuration;
  final String? terms;
  final bool isActive;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'applicableVehicleTypes': applicableVehicleTypes,
      'pricingMethod': pricingMethod,
      'fixedPrice': fixedPrice,
      'startingPrice': startingPrice,
      'categoryPrices': categoryPrices,
      'attributeRules': attributeRules.map((e) => e.toMap()).toList(),
      'estimatedDuration': estimatedDuration,
      'terms': terms,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
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

    final attrRulesRaw = data['attributeRules'] as List<dynamic>?;
    final parsedAttrRules = attrRulesRaw != null
        ? attrRulesRaw
              .whereType<Map<String, dynamic>>()
              .map(PricingAttributeRule.fromMap)
              .toList()
        : <PricingAttributeRule>[];

    return GarageServiceModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
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
      fixedPrice: (data['fixedPrice'] as num?)?.toDouble(),
      startingPrice: (data['startingPrice'] as num?)?.toDouble(),
      categoryPrices: parsedCatPrices,
      attributeRules: parsedAttrRules,
      estimatedDuration: data['estimatedDuration'] as String? ?? '1-2 hrs',
      terms: data['terms'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: DateFormatter.parse(data['createdAt']),
    );
  }

  GarageServiceModel copyWith({
    String? id,
    String? garageId,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    List<String>? applicableVehicleTypes,
    String? pricingMethod,
    double? fixedPrice,
    double? startingPrice,
    Map<String, double>? categoryPrices,
    List<PricingAttributeRule>? attributeRules,
    String? estimatedDuration,
    String? terms,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return GarageServiceModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      applicableVehicleTypes:
          applicableVehicleTypes ?? this.applicableVehicleTypes,
      pricingMethod: pricingMethod ?? this.pricingMethod,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      startingPrice: startingPrice ?? this.startingPrice,
      categoryPrices: categoryPrices ?? this.categoryPrices,
      attributeRules: attributeRules ?? this.attributeRules,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      terms: terms ?? this.terms,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
