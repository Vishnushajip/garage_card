import 'package:garage_card/core/formatting/date_formatter.dart';

import 'supplemental_work_model.dart';

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
    this.actualStartTime,
    this.estimatedCompletionDate,
    this.completedDate,
    this.vehicleDisplay = '',
    this.customerName = '',
    this.customerPhone = '',
    this.customerWhatsApp = '',
    this.gatePassCode,
    this.isGatePassVerified = false,
    this.gatePassVerifiedAt,
    this.qcChecklist = const {},
    this.isQcPassed = false,
    this.qcInspectorName,
    this.qcInspectedAt,
    this.supplementalItems = const [],
    this.nextRecommendedServiceDate,
    this.nextRecommendedOdometer,
    this.nextRecommendedServiceType,
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
  final DateTime? actualStartTime;
  final DateTime? estimatedCompletionDate;
  final DateTime? completedDate;
  final String vehicleDisplay;
  final String customerName;
  final String customerPhone;
  final String customerWhatsApp;
  final String? gatePassCode;
  final bool isGatePassVerified;
  final DateTime? gatePassVerifiedAt;
  final Map<String, bool> qcChecklist;
  final bool isQcPassed;
  final String? qcInspectorName;
  final DateTime? qcInspectedAt;
  final List<SupplementalWorkItem> supplementalItems;
  final DateTime? nextRecommendedServiceDate;
  final int? nextRecommendedOdometer;
  final String? nextRecommendedServiceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActiveRepair {
    final s = status.toLowerCase();
    return s == 'in_progress' ||
        s == 'inprogress' ||
        s == 'awaiting_parts' ||
        s == 'waitingforparts' ||
        s == 'on_hold' ||
        s == 'quality_check' ||
        s == 'qualitycheck';
  }

  bool get isPendingRequest {
    final s = status.toLowerCase();
    return s == 'received' ||
        s == 'requested' ||
        s == 'pending' ||
        s == 'accepted' ||
        s == 'scheduled' ||
        s == 'checked_in' ||
        s == 'inspection' ||
        s == 'inspectionpending' ||
        s == 'estimate_pending' ||
        s == 'approved';
  }

  bool get isCompletedRepair {
    final s = status.toLowerCase();
    return s == 'completed' || s == 'closed' || s == 'delivered';
  }

  bool get isCancelled {
    final s = status.toLowerCase();
    return s == 'cancelled' || s == 'rejected';
  }

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
      'actualStartTime': actualStartTime?.toIso8601String(),
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'vehicleDisplay': vehicleDisplay,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerWhatsApp': customerWhatsApp,
      'gatePassCode': gatePassCode,
      'isGatePassVerified': isGatePassVerified,
      'gatePassVerifiedAt': gatePassVerifiedAt?.toIso8601String(),
      'qcChecklist': qcChecklist,
      'isQcPassed': isQcPassed,
      'qcInspectorName': qcInspectorName,
      'qcInspectedAt': qcInspectedAt?.toIso8601String(),
      'supplementalItems': supplementalItems.map((e) => e.toMap()).toList(),
      'nextRecommendedServiceDate': nextRecommendedServiceDate
          ?.toIso8601String(),
      'nextRecommendedOdometer': nextRecommendedOdometer,
      'nextRecommendedServiceType': nextRecommendedServiceType,
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
      actualStartTime: DateFormatter.parse(data['actualStartTime']),
      estimatedCompletionDate: DateFormatter.parse(
        data['estimatedCompletionDate'],
      ),
      completedDate: DateFormatter.parse(data['completedDate']),
      vehicleDisplay: data['vehicleDisplay'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      customerWhatsApp: data['customerWhatsApp'] as String? ?? '',
      gatePassCode: data['gatePassCode'] as String?,
      isGatePassVerified: data['isGatePassVerified'] as bool? ?? false,
      gatePassVerifiedAt: DateFormatter.parse(data['gatePassVerifiedAt']),
      qcChecklist:
          (data['qcChecklist'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v as bool? ?? false),
          ) ??
          const {},
      isQcPassed: data['isQcPassed'] as bool? ?? false,
      qcInspectorName: data['qcInspectorName'] as String?,
      qcInspectedAt: DateFormatter.parse(data['qcInspectedAt']),
      supplementalItems:
          (data['supplementalItems'] as List<dynamic>?)
              ?.map(
                (e) =>
                    SupplementalWorkItem.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      nextRecommendedServiceDate: DateFormatter.parse(
        data['nextRecommendedServiceDate'],
      ),
      nextRecommendedOdometer: (data['nextRecommendedOdometer'] as num?)
          ?.toInt(),
      nextRecommendedServiceType: data['nextRecommendedServiceType'] as String?,
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
    DateTime? actualStartTime,
    DateTime? estimatedCompletionDate,
    DateTime? completedDate,
    String? vehicleDisplay,
    String? customerName,
    String? customerPhone,
    String? customerWhatsApp,
    String? gatePassCode,
    bool? isGatePassVerified,
    DateTime? gatePassVerifiedAt,
    Map<String, bool>? qcChecklist,
    bool? isQcPassed,
    String? qcInspectorName,
    DateTime? qcInspectedAt,
    List<SupplementalWorkItem>? supplementalItems,
    DateTime? nextRecommendedServiceDate,
    int? nextRecommendedOdometer,
    String? nextRecommendedServiceType,
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
      actualStartTime: actualStartTime ?? this.actualStartTime,
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
      completedDate: completedDate ?? this.completedDate,
      vehicleDisplay: vehicleDisplay ?? this.vehicleDisplay,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerWhatsApp: customerWhatsApp ?? this.customerWhatsApp,
      gatePassCode: gatePassCode ?? this.gatePassCode,
      isGatePassVerified: isGatePassVerified ?? this.isGatePassVerified,
      gatePassVerifiedAt: gatePassVerifiedAt ?? this.gatePassVerifiedAt,
      qcChecklist: qcChecklist ?? this.qcChecklist,
      isQcPassed: isQcPassed ?? this.isQcPassed,
      qcInspectorName: qcInspectorName ?? this.qcInspectorName,
      qcInspectedAt: qcInspectedAt ?? this.qcInspectedAt,
      supplementalItems: supplementalItems ?? this.supplementalItems,
      nextRecommendedServiceDate:
          nextRecommendedServiceDate ?? this.nextRecommendedServiceDate,
      nextRecommendedOdometer:
          nextRecommendedOdometer ?? this.nextRecommendedOdometer,
      nextRecommendedServiceType:
          nextRecommendedServiceType ?? this.nextRecommendedServiceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
