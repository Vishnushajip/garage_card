import 'package:garage_card/core/formatting/date_formatter.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    this.attachmentUrl,
    this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final String text;
  final String? attachmentUrl;
  final DateTime? createdAt;
  final bool isRead;

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt?.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatMessageModel(
      id: id,
      conversationId: data['conversationId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? 'customer',
      text: data['text'] as String? ?? '',
      attachmentUrl: data['attachmentUrl'] as String?,
      createdAt: DateFormatter.parse(data['createdAt']),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderRole,
    String? text,
    String? attachmentUrl,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      text: text ?? this.text,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
