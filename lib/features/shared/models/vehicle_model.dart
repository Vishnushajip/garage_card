class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.garageId,
    required this.customerId,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vehicleType = 'motorcycle',
    this.engineCc,
    this.imageUrl,
    this.vin = '',
    this.currentOdometer = 0,
    this.fuelType = 'Petrol',
    this.color = '',
    this.lastServiceDate,
    this.lastServiceType,
    this.nextServiceDue,
    this.nextServiceOdometer,
    this.maintenanceIntervalMonths,
    this.maintenanceIntervalKm,
    this.lastServicedGarageId,
    this.lastServiceJobId,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String customerId;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String vehicleType;
  final int? engineCc;
  final String? imageUrl;
  final String vin;
  final int currentOdometer;
  final String fuelType;
  final String color;
  final DateTime? lastServiceDate;
  final String? lastServiceType;
  final DateTime? nextServiceDue;
  final int? nextServiceOdometer;
  final int? maintenanceIntervalMonths;
  final int? maintenanceIntervalKm;
  final String? lastServicedGarageId;
  final String? lastServiceJobId;
  final DateTime? createdAt;

  String get displayName => '$year $make $model ($licensePlate)';

  bool get hasMaintenanceSchedule =>
      nextServiceDue != null || nextServiceOdometer != null;

  String get maintenanceStatus {
    if (!hasMaintenanceSchedule) {
      return 'not_available';
    }
    final now = DateTime.now();
    final daysRemaining = nextServiceDue?.difference(now).inDays;
    final kmRemaining = nextServiceOdometer == null
        ? null
        : nextServiceOdometer! - currentOdometer;

    if ((daysRemaining != null && daysRemaining < 0) ||
        (kmRemaining != null && kmRemaining < 0)) {
      return 'overdue';
    }
    if ((daysRemaining != null && daysRemaining <= 3) ||
        (kmRemaining != null && kmRemaining <= 100)) {
      return 'due';
    }
    if ((daysRemaining != null && daysRemaining <= 14) ||
        (kmRemaining != null && kmRemaining <= 500)) {
      return 'due_soon';
    }
    return 'upcoming';
  }

  int? get daysUntilNextService {
    if (nextServiceDue == null) return null;
    return nextServiceDue!.difference(DateTime.now()).inDays;
  }

  int? get kmUntilNextService {
    if (nextServiceOdometer == null) return null;
    return nextServiceOdometer! - currentOdometer;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'customerId': customerId,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'vehicleType': vehicleType,
      'engineCc': engineCc,
      'imageUrl': imageUrl,
      'vin': vin,
      'currentOdometer': currentOdometer,
      'fuelType': fuelType,
      'color': color,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'lastServiceType': lastServiceType,
      'nextServiceDue': nextServiceDue?.toIso8601String(),
      'nextServiceOdometer': nextServiceOdometer,
      'maintenanceIntervalMonths': maintenanceIntervalMonths,
      'maintenanceIntervalKm': maintenanceIntervalKm,
      'lastServicedGarageId': lastServicedGarageId,
      'lastServiceJobId': lastServiceJobId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory VehicleModel.fromFirestore(Map<String, dynamic> data, String id) {
    return VehicleModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      make: data['make'] as String? ?? '',
      model: data['model'] as String? ?? '',
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      licensePlate: data['licensePlate'] as String? ?? '',
      vehicleType: data['vehicleType'] as String? ?? 'motorcycle',
      engineCc: (data['engineCc'] as num?)?.toInt(),
      imageUrl: data['imageUrl'] as String?,
      vin: data['vin'] as String? ?? '',
      currentOdometer: (data['currentOdometer'] as num?)?.toInt() ?? 0,
      fuelType: data['fuelType'] as String? ?? 'Petrol',
      color: data['color'] as String? ?? '',
      lastServiceDate: data['lastServiceDate'] != null
          ? DateTime.tryParse(data['lastServiceDate'] as String)
          : null,
      lastServiceType: data['lastServiceType'] as String?,
      nextServiceDue: data['nextServiceDue'] != null
          ? DateTime.tryParse(data['nextServiceDue'] as String)
          : null,
      nextServiceOdometer: (data['nextServiceOdometer'] as num?)?.toInt(),
      maintenanceIntervalMonths: (data['maintenanceIntervalMonths'] as num?)
          ?.toInt(),
      maintenanceIntervalKm: (data['maintenanceIntervalKm'] as num?)?.toInt(),
      lastServicedGarageId: data['lastServicedGarageId'] as String?,
      lastServiceJobId: data['lastServiceJobId'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  VehicleModel copyWith({
    String? id,
    String? garageId,
    String? customerId,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? vehicleType,
    int? engineCc,
    String? imageUrl,
    String? vin,
    int? currentOdometer,
    String? fuelType,
    String? color,
    DateTime? lastServiceDate,
    String? lastServiceType,
    DateTime? nextServiceDue,
    int? nextServiceOdometer,
    int? maintenanceIntervalMonths,
    int? maintenanceIntervalKm,
    String? lastServicedGarageId,
    String? lastServiceJobId,
    DateTime? createdAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      customerId: customerId ?? this.customerId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      engineCc: engineCc ?? this.engineCc,
      imageUrl: imageUrl ?? this.imageUrl,
      vin: vin ?? this.vin,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      fuelType: fuelType ?? this.fuelType,
      color: color ?? this.color,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceType: lastServiceType ?? this.lastServiceType,
      nextServiceDue: nextServiceDue ?? this.nextServiceDue,
      nextServiceOdometer: nextServiceOdometer ?? this.nextServiceOdometer,
      maintenanceIntervalMonths:
          maintenanceIntervalMonths ?? this.maintenanceIntervalMonths,
      maintenanceIntervalKm:
          maintenanceIntervalKm ?? this.maintenanceIntervalKm,
      lastServicedGarageId: lastServicedGarageId ?? this.lastServicedGarageId,
      lastServiceJobId: lastServiceJobId ?? this.lastServiceJobId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
