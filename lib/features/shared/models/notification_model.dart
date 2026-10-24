class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.recipientUid,
    required this.title,
    required this.body,
    this.type = 'general',
    this.referenceId,
    this.referenceType,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String recipientUid;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'recipientUid': recipientUid,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory NotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return NotificationModel(
      id: id,
      recipientUid: data['recipientUid'] as String? ?? '',
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      referenceId: data['referenceId'] as String?,
      referenceType: data['referenceType'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? recipientUid,
    String? title,
    String? body,
    String? type,
    String? referenceId,
    String? referenceType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientUid: recipientUid ?? this.recipientUid,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
