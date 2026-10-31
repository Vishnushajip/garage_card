import 'package:garage_card/core/formatting/date_formatter.dart';

class WarrantyItemModel {
  const WarrantyItemModel({
    required this.id,
    required this.invoiceId,
    required this.partName,
    this.durationMonths = 6,
    this.coverageKm,
    this.startDate,
    this.expiryDate,
    this.garageName = 'Apex Auto Works',
    this.status = 'active',
  });

  final String id;
  final String invoiceId;
  final String partName;
  final int durationMonths;
  final int? coverageKm;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final String garageName;
  final String status;

  bool get isActive {
    if (status != 'active') return false;
    if (expiryDate == null) return true;
    return expiryDate!.isAfter(DateTime.now());
  }

  int? get remainingDays {
    if (expiryDate == null) return null;
    final diff = expiryDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'partName': partName,
      'durationMonths': durationMonths,
      'coverageKm': coverageKm,
      'startDate': startDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'garageName': garageName,
      'status': status,
    };
  }

  factory WarrantyItemModel.fromMap(Map<String, dynamic> map) {
    return WarrantyItemModel(
      id: map['id'] as String? ?? '',
      invoiceId: map['invoiceId'] as String? ?? '',
      partName: map['partName'] as String? ?? '',
      durationMonths: (map['durationMonths'] as num?)?.toInt() ?? 6,
      coverageKm: (map['coverageKm'] as num?)?.toInt(),
      startDate: DateFormatter.parse(map['startDate']),
      expiryDate: DateFormatter.parse(map['expiryDate']),
      garageName: map['garageName'] as String? ?? 'Apex Auto Works',
      status: map['status'] as String? ?? 'active',
    );
  }

  WarrantyItemModel copyWith({
    String? id,
    String? invoiceId,
    String? partName,
    int? durationMonths,
    int? coverageKm,
    DateTime? startDate,
    DateTime? expiryDate,
    String? garageName,
    String? status,
  }) {
    return WarrantyItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      partName: partName ?? this.partName,
      durationMonths: durationMonths ?? this.durationMonths,
      coverageKm: coverageKm ?? this.coverageKm,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      garageName: garageName ?? this.garageName,
      status: status ?? this.status,
    );
  }
}
