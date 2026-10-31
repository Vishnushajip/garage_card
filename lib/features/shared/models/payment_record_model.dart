import 'package:garage_card/core/formatting/date_formatter.dart';

class PaymentRecordModel {
  const PaymentRecordModel({
    required this.id,
    required this.invoiceId,
    required this.amount,
    this.method = 'cash',
    this.reference,
    this.recordedAt,
    this.notes,
  });

  final String id;
  final String invoiceId;
  final double amount;
  final String method;
  final String? reference;
  final DateTime? recordedAt;
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'method': method,
      'reference': reference,
      'recordedAt': recordedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory PaymentRecordModel.fromMap(Map<String, dynamic> map) {
    return PaymentRecordModel(
      id: map['id'] as String? ?? '',
      invoiceId: map['invoiceId'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      method: map['method'] as String? ?? 'cash',
      reference: map['reference'] as String?,
      recordedAt: DateFormatter.parse(map['recordedAt']),
      notes: map['notes'] as String?,
    );
  }

  PaymentRecordModel copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    String? method,
    String? reference,
    DateTime? recordedAt,
    String? notes,
  }) {
    return PaymentRecordModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
    );
  }
}
