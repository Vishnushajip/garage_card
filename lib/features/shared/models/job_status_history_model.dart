class JobStatusHistoryModel {
  const JobStatusHistoryModel({
    required this.id,
    required this.jobId,
    required this.fromStatus,
    required this.toStatus,
    this.notes = '',
    this.updatedBy = '',
    required this.timestamp,
  });

  final String id;
  final String jobId;
  final String fromStatus;
  final String toStatus;
  final String notes;
  final String updatedBy;
  final DateTime timestamp;

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'notes': notes,
      'updatedBy': updatedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory JobStatusHistoryModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return JobStatusHistoryModel(
      id: id,
      jobId: data['jobId'] as String? ?? '',
      fromStatus: data['fromStatus'] as String? ?? '',
      toStatus: data['toStatus'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      updatedBy: data['updatedBy'] as String? ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
