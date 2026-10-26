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
    this.nextServiceDue,
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
  final DateTime? nextServiceDue;
  final DateTime? createdAt;

  String get displayName => '$year $make $model ($licensePlate)';

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
      'nextServiceDue': nextServiceDue?.toIso8601String(),
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
      nextServiceDue: data['nextServiceDue'] != null
          ? DateTime.tryParse(data['nextServiceDue'] as String)
          : null,
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
    DateTime? nextServiceDue,
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
      nextServiceDue: nextServiceDue ?? this.nextServiceDue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
