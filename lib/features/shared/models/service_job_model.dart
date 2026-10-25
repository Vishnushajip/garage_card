import 'package:garage_card/core/formatting/date_formatter.dart';

class ServiceJobModel {
  const ServiceJobModel({
    required this.id,
    required this.garageId,
    required this.customerId,
    required this.vehicleId,
    required this.jobNumber,
    this.status = 'received',
    this.odometerReading = 0,
    this.complaints = const [],
    this.customerNotes = '',
    this.internalNotes = '',
    this.technicianName = '',
    this.estimatedCompletionDate,
    this.completedDate,
    this.vehicleDisplay = '',
    this.customerName = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String garageId;
  final String customerId;
  final String vehicleId;
  final String jobNumber;
  final String status;
  final int odometerReading;
  final List<String> complaints;
  final String customerNotes;
  final String internalNotes;
  final String technicianName;
  final DateTime? estimatedCompletionDate;
  final DateTime? completedDate;
  final String vehicleDisplay;
  final String customerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'jobNumber': jobNumber,
      'status': status,
      'odometerReading': odometerReading,
      'complaints': complaints,
      'customerNotes': customerNotes,
      'internalNotes': internalNotes,
      'technicianName': technicianName,
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'vehicleDisplay': vehicleDisplay,
      'customerName': customerName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ServiceJobModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ServiceJobModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String? ?? '',
      jobNumber: data['jobNumber'] as String? ?? '',
      status: data['status'] as String? ?? 'received',
      odometerReading: (data['odometerReading'] as num?)?.toInt() ?? 0,
      complaints:
          (data['complaints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      customerNotes: data['customerNotes'] as String? ?? '',
      internalNotes: data['internalNotes'] as String? ?? '',
      technicianName: data['technicianName'] as String? ?? '',
      estimatedCompletionDate: DateFormatter.parse(
        data['estimatedCompletionDate'],
      ),
      completedDate: DateFormatter.parse(data['completedDate']),
      vehicleDisplay: data['vehicleDisplay'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      createdAt: DateFormatter.parse(data['createdAt']),
      updatedAt: DateFormatter.parse(data['updatedAt']),
    );
  }

  ServiceJobModel copyWith({
    String? id,
    String? garageId,
    String? customerId,
    String? vehicleId,
    String? jobNumber,
    String? status,
    int? odometerReading,
    List<String>? complaints,
    String? customerNotes,
    String? internalNotes,
    String? technicianName,
    DateTime? estimatedCompletionDate,
    DateTime? completedDate,
    String? vehicleDisplay,
    String? customerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceJobModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      jobNumber: jobNumber ?? this.jobNumber,
      status: status ?? this.status,
      odometerReading: odometerReading ?? this.odometerReading,
      complaints: complaints ?? this.complaints,
      customerNotes: customerNotes ?? this.customerNotes,
      internalNotes: internalNotes ?? this.internalNotes,
      technicianName: technicianName ?? this.technicianName,
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
      completedDate: completedDate ?? this.completedDate,
      vehicleDisplay: vehicleDisplay ?? this.vehicleDisplay,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
