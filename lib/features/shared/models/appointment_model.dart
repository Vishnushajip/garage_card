class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.garageId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleInfo,
    required this.preferredDate,
    this.preferredTime = 'Morning',
    required this.issueDescription,
    this.status = 'submitted',
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleInfo;
  final DateTime preferredDate;
  final String preferredTime;
  final String issueDescription;
  final String status;
  final String? rejectionReason;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vehicleInfo': vehicleInfo,
      'preferredDate': preferredDate.toIso8601String(),
      'preferredTime': preferredTime,
      'issueDescription': issueDescription,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AppointmentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      vehicleInfo: data['vehicleInfo'] as String? ?? '',
      preferredDate: data['preferredDate'] != null
          ? DateTime.tryParse(data['preferredDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      preferredTime: data['preferredTime'] as String? ?? 'Morning',
      issueDescription: data['issueDescription'] as String? ?? '',
      status: data['status'] as String? ?? 'submitted',
      rejectionReason: data['rejectionReason'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? garageId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? vehicleInfo,
    DateTime? preferredDate,
    String? preferredTime,
    String? issueDescription,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      issueDescription: issueDescription ?? this.issueDescription,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
