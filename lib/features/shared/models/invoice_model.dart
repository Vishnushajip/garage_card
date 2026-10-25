import 'line_item_model.dart';

class InvoiceModel {
  const InvoiceModel({
    required this.id,
    required this.garageId,
    required this.jobId,
    this.estimateId,
    required this.customerId,
    required this.invoiceNumber,
    this.items = const [],
    this.subtotal = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.balanceDue = 0.0,
    this.currencyCode = 'INR',
    this.status = 'unpaid',
    this.dueDate,
    this.issuedAt,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String jobId;
  final String? estimateId;
  final String customerId;
  final String invoiceNumber;
  final List<LineItemModel> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final double balanceDue;
  final String currencyCode;
  final String status;
  final DateTime? dueDate;
  final DateTime? issuedAt;
  final DateTime? createdAt;

  bool get isPaid => status == 'paid' || balanceDue <= 0.0;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'jobId': jobId,
      'estimateId': estimateId,
      'customerId': customerId,
      'invoiceNumber': invoiceNumber,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'balanceDue': balanceDue,
      'currencyCode': currencyCode,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'issuedAt': issuedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory InvoiceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return InvoiceModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      jobId: data['jobId'] as String? ?? '',
      estimateId: data['estimateId'] as String?,
      customerId: data['customerId'] as String? ?? '',
      invoiceNumber: data['invoiceNumber'] as String? ?? '',
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
      paidAmount: (data['paidAmount'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (data['balanceDue'] as num?)?.toDouble() ?? 0.0,
      currencyCode: data['currencyCode'] as String? ?? 'INR',
      status: data['status'] as String? ?? 'unpaid',
      dueDate: data['dueDate'] != null
          ? DateTime.tryParse(data['dueDate'] as String)
          : null,
      issuedAt: data['issuedAt'] != null
          ? DateTime.tryParse(data['issuedAt'] as String)
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  InvoiceModel copyWith({
    String? id,
    String? garageId,
    String? jobId,
    String? estimateId,
    String? customerId,
    String? invoiceNumber,
    List<LineItemModel>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    double? balanceDue,
    String? currencyCode,
    String? status,
    DateTime? dueDate,
    DateTime? issuedAt,
    DateTime? createdAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      jobId: jobId ?? this.jobId,
      estimateId: estimateId ?? this.estimateId,
      customerId: customerId ?? this.customerId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
