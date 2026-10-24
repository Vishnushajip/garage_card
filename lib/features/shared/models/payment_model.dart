class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.garageId,
    required this.invoiceId,
    required this.customerId,
    required this.amount,
    this.paymentMethod = 'cash',
    this.referenceNumber = '',
    this.recordedByUid = '',
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String invoiceId;
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String referenceNumber;
  final String recordedByUid;
  final String notes;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'invoiceId': invoiceId,
      'customerId': customerId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'recordedByUid': recordedByUid,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory PaymentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      invoiceId: data['invoiceId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] as String? ?? 'cash',
      referenceNumber: data['referenceNumber'] as String? ?? '',
      recordedByUid: data['recordedByUid'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  PaymentModel copyWith({
    String? id,
    String? garageId,
    String? invoiceId,
    String? customerId,
    double? amount,
    String? paymentMethod,
    String? referenceNumber,
    String? recordedByUid,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      recordedByUid: recordedByUid ?? this.recordedByUid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
