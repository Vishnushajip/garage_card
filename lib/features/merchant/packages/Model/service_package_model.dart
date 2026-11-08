class ServicePackageModel {
  const ServicePackageModel({
    required this.id,
    required this.garageId,
    required this.title,
    this.description = '',
    this.includedServices = const [],
    required this.originalPrice,
    required this.packagePrice,
    this.vehicleType = 'all',
    this.validityDays = 30,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String title;
  final String description;
  final List<String> includedServices;
  final double originalPrice;
  final double packagePrice;
  final String vehicleType;
  final int validityDays;
  final bool isActive;
  final DateTime? createdAt;

  double get savingsAmount =>
      (originalPrice - packagePrice) > 0 ? (originalPrice - packagePrice) : 0.0;

  int get savingsPercentage {
    if (originalPrice <= 0) return 0;
    final pct = ((originalPrice - packagePrice) / originalPrice) * 100;
    return pct > 0 ? pct.round() : 0;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'title': title,
      'description': description,
      'includedServices': includedServices,
      'originalPrice': originalPrice,
      'packagePrice': packagePrice,
      'vehicleType': vehicleType,
      'validityDays': validityDays,
      'isActive': isActive,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory ServicePackageModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ServicePackageModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      includedServices:
          (data['includedServices'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      packagePrice: (data['packagePrice'] as num?)?.toDouble() ?? 0.0,
      vehicleType: data['vehicleType'] as String? ?? 'all',
      validityDays: (data['validityDays'] as num?)?.toInt() ?? 30,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  ServicePackageModel copyWith({
    String? id,
    String? garageId,
    String? title,
    String? description,
    List<String>? includedServices,
    double? originalPrice,
    double? packagePrice,
    String? vehicleType,
    int? validityDays,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ServicePackageModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      title: title ?? this.title,
      description: description ?? this.description,
      includedServices: includedServices ?? this.includedServices,
      originalPrice: originalPrice ?? this.originalPrice,
      packagePrice: packagePrice ?? this.packagePrice,
      vehicleType: vehicleType ?? this.vehicleType,
      validityDays: validityDays ?? this.validityDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ServicePackagesState {
  const ServicePackagesState({
    this.isLoading = false,
    this.packages = const [],
    this.filterActiveOnly = false,
    this.errorMessage,
  });

  final bool isLoading;
  final List<ServicePackageModel> packages;
  final bool filterActiveOnly;
  final String? errorMessage;

  int get totalPackages => packages.length;
  int get activePackagesCount => packages.where((p) => p.isActive).length;

  List<ServicePackageModel> get filteredPackages {
    if (!filterActiveOnly) return packages;
    return packages.where((p) => p.isActive).toList();
  }

  ServicePackagesState copyWith({
    bool? isLoading,
    List<ServicePackageModel>? packages,
    bool? filterActiveOnly,
    String? errorMessage,
  }) {
    return ServicePackagesState(
      isLoading: isLoading ?? this.isLoading,
      packages: packages ?? this.packages,
      filterActiveOnly: filterActiveOnly ?? this.filterActiveOnly,
      errorMessage: errorMessage,
    );
  }
}
