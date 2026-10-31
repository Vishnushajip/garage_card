class SupplementalWorkItem {
  const SupplementalWorkItem({
    required this.id,
    required this.jobId,
    required this.title,
    required this.reason,
    this.partsCost = 0.0,
    this.laborCost = 0.0,
    this.status = 'pending',
    this.declinedReason,
    this.createdAt,
    this.decidedAt,
  });

  final String id;
  final String jobId;
  final String title;
  final String reason;
  final double partsCost;
  final double laborCost;
  final String status;
  final String? declinedReason;
  final DateTime? createdAt;
  final DateTime? decidedAt;

  double get totalAmount => partsCost + laborCost;
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDeclined => status == 'declined';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'title': title,
      'reason': reason,
      'partsCost': partsCost,
      'laborCost': laborCost,
      'status': status,
      'declinedReason': declinedReason,
      'createdAt': createdAt?.toIso8601String(),
      'decidedAt': decidedAt?.toIso8601String(),
    };
  }

  factory SupplementalWorkItem.fromMap(Map<String, dynamic> map) {
    return SupplementalWorkItem(
      id: map['id'] as String? ?? '',
      jobId: map['jobId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      partsCost: (map['partsCost'] as num?)?.toDouble() ?? 0.0,
      laborCost: (map['laborCost'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending',
      declinedReason: map['declinedReason'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      decidedAt: map['decidedAt'] != null
          ? DateTime.tryParse(map['decidedAt'] as String)
          : null,
    );
  }

  SupplementalWorkItem copyWith({
    String? id,
    String? jobId,
    String? title,
    String? reason,
    double? partsCost,
    double? laborCost,
    String? status,
    String? declinedReason,
    DateTime? createdAt,
    DateTime? decidedAt,
  }) {
    return SupplementalWorkItem(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      partsCost: partsCost ?? this.partsCost,
      laborCost: laborCost ?? this.laborCost,
      status: status ?? this.status,
      declinedReason: declinedReason ?? this.declinedReason,
      createdAt: createdAt ?? this.createdAt,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }
}
