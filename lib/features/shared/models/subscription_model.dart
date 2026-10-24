class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.currencyCode,
    required this.maxJobsPerMonth,
    required this.hasPdfExport,
    required this.hasWhatsAppSharing,
    required this.hasDigitalInspections,
    required this.hasPrioritySupport,
  });

  final String id;
  final String name;
  final double priceMonthly;
  final String currencyCode;
  final int maxJobsPerMonth;
  final bool hasPdfExport;
  final bool hasWhatsAppSharing;
  final bool hasDigitalInspections;
  final bool hasPrioritySupport;

  static const List<SubscriptionPlanModel> availablePlans = [
    SubscriptionPlanModel(
      id: 'free',
      name: 'Starter (Free)',
      priceMonthly: 0.0,
      currencyCode: 'INR',
      maxJobsPerMonth: 25,
      hasPdfExport: true,
      hasWhatsAppSharing: true,
      hasDigitalInspections: true,
      hasPrioritySupport: false,
    ),
    SubscriptionPlanModel(
      id: 'pro',
      name: 'Garage Pro',
      priceMonthly: 999.0,
      currencyCode: 'INR',
      maxJobsPerMonth: 500,
      hasPdfExport: true,
      hasWhatsAppSharing: true,
      hasDigitalInspections: true,
      hasPrioritySupport: true,
    ),
  ];
}

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.garageId,
    required this.planId,
    this.status = 'active',
    this.validUntil,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String planId;
  final String status;
  final DateTime? validUntil;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'planId': planId,
      'status': status,
      'validUntil': validUntil?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return SubscriptionModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      planId: data['planId'] as String? ?? 'free',
      status: data['status'] as String? ?? 'active',
      validUntil: data['validUntil'] != null
          ? DateTime.tryParse(data['validUntil'] as String)
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }
}
