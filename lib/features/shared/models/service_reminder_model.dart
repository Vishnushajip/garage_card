class ServiceReminderModel {
  const ServiceReminderModel({
    required this.id,
    required this.garageId,
    required this.customerId,
    required this.vehicleId,
    this.vehicleDisplay = '',
    required this.title,
    this.serviceType = 'Routine Service',
    required this.dueDate,
    this.dueMileage = 0,
    this.status = 'pending',
    this.isCustomerReported = false,
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String customerId;
  final String vehicleId;
  final String vehicleDisplay;
  final String title;
  final String serviceType;
  final DateTime dueDate;
  final int dueMileage;
  final String status;
  final bool isCustomerReported;
  final String notes;
  final DateTime? createdAt;

  bool get isDueSoon {
    final difference = dueDate.difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 14;
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != 'completed';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'vehicleDisplay': vehicleDisplay,
      'title': title,
      'serviceType': serviceType,
      'dueDate': dueDate.toIso8601String(),
      'dueMileage': dueMileage,
      'status': status,
      'isCustomerReported': isCustomerReported,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ServiceReminderModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ServiceReminderModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String? ?? '',
      vehicleDisplay: data['vehicleDisplay'] as String? ?? '',
      title: data['title'] as String? ?? 'Service Reminder',
      serviceType: data['serviceType'] as String? ?? 'Routine Service',
      dueDate: data['dueDate'] != null
          ? DateTime.tryParse(data['dueDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      dueMileage: (data['dueMileage'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'pending',
      isCustomerReported: data['isCustomerReported'] as bool? ?? false,
      notes: data['notes'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  ServiceReminderModel copyWith({
    String? id,
    String? garageId,
    String? customerId,
    String? vehicleId,
    String? vehicleDisplay,
    String? title,
    String? serviceType,
    DateTime? dueDate,
    int? dueMileage,
    String? status,
    bool? isCustomerReported,
    String? notes,
    DateTime? createdAt,
  }) {
    return ServiceReminderModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleDisplay: vehicleDisplay ?? this.vehicleDisplay,
      title: title ?? this.title,
      serviceType: serviceType ?? this.serviceType,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      status: status ?? this.status,
      isCustomerReported: isCustomerReported ?? this.isCustomerReported,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
