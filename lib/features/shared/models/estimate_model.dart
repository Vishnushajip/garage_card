import 'line_item_model.dart';

class EstimateModel {
  const EstimateModel({
    required this.id,
    required this.garageId,
    required this.jobId,
    required this.customerId,
    required this.estimateNumber,
    this.items = const [],
    this.subtotal = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.currencyCode = 'INR',
    this.status = 'sent',
    this.rejectionReason,
    this.version = 1,
    this.expiresAt,
    this.approvedAt,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String jobId;
  final String customerId;
  final String estimateNumber;
  final List<LineItemModel> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currencyCode;
  final String status;
  final String? rejectionReason;
  final int version;
  final DateTime? expiresAt;
  final DateTime? approvedAt;
  final DateTime? createdAt;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'sent' || status == 'draft';

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'jobId': jobId,
      'customerId': customerId,
      'estimateNumber': estimateNumber,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currencyCode': currencyCode,
      'status': status,
      'rejectionReason': rejectionReason,
      'version': version,
      'expiresAt': expiresAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory EstimateModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EstimateModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      jobId: data['jobId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      estimateNumber: data['estimateNumber'] as String? ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (e) =>
                    LineItemModel.fromMap(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currencyCode: data['currencyCode'] as String? ?? 'INR',
      status: data['status'] as String? ?? 'sent',
      rejectionReason: data['rejectionReason'] as String?,
      version: (data['version'] as num?)?.toInt() ?? 1,
      expiresAt: data['expiresAt'] != null
          ? DateTime.tryParse(data['expiresAt'] as String)
          : null,
      approvedAt: data['approvedAt'] != null
          ? DateTime.tryParse(data['approvedAt'] as String)
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  EstimateModel copyWith({
    String? id,
    String? garageId,
    String? jobId,
    String? customerId,
    String? estimateNumber,
    List<LineItemModel>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currencyCode,
    String? status,
    String? rejectionReason,
    int? version,
    DateTime? expiresAt,
    DateTime? approvedAt,
    DateTime? createdAt,
  }) {
    return EstimateModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      jobId: jobId ?? this.jobId,
      customerId: customerId ?? this.customerId,
      estimateNumber: estimateNumber ?? this.estimateNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      version: version ?? this.version,
      expiresAt: expiresAt ?? this.expiresAt,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
