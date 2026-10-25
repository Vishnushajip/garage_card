import 'package:garage_card/core/formatting/date_formatter.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.recipientUid,
    required this.title,
    required this.body,
    this.type = 'general',
    this.referenceId,
    this.referenceType,
    this.imageUrl,
    this.deepLink,
    this.garageId,
    this.eventId,
    this.metadata,
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
  final String? imageUrl;
  final String? deepLink;
  final String? garageId;
  final String? eventId;
  final Map<String, dynamic>? metadata;
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
      'imageUrl': imageUrl,
      'deepLink': deepLink,
      'garageId': garageId,
      'eventId': eventId,
      'metadata': metadata,
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
      imageUrl: data['imageUrl'] as String?,
      deepLink: data['deepLink'] as String?,
      garageId: data['garageId'] as String?,
      eventId: data['eventId'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: DateFormatter.parse(data['createdAt']),
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
    String? imageUrl,
    String? deepLink,
    String? garageId,
    String? eventId,
    Map<String, dynamic>? metadata,
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
      imageUrl: imageUrl ?? this.imageUrl,
      deepLink: deepLink ?? this.deepLink,
      garageId: garageId ?? this.garageId,
      eventId: eventId ?? this.eventId,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
