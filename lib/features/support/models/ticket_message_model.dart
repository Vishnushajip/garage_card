import 'package:garage_card/core/formatting/date_formatter.dart';

class TicketMessageModel {
  const TicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    this.attachments = const [],
    this.isInternal = false,
    this.createdAt,
    this.readAt,
    this.clientMessageId,
  });

  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final List<String> attachments;
  final bool isInternal;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String? clientMessageId;

  bool get isFromCustomer => senderRole == 'customer';
  bool get isFromMerchant => senderRole == 'merchant';

  TicketMessageModel copyWith({
    String? id,
    String? ticketId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? message,
    List<String>? attachments,
    bool? isInternal,
    DateTime? createdAt,
    DateTime? readAt,
    String? clientMessageId,
  }) {
    return TicketMessageModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      attachments: attachments ?? this.attachments,
      isInternal: isInternal ?? this.isInternal,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      clientMessageId: clientMessageId ?? this.clientMessageId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'attachments': attachments,
      'isInternal': isInternal,
      'createdAt': createdAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'clientMessageId': clientMessageId,
    };
  }

  factory TicketMessageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TicketMessageModel(
      id: id ?? map['id'] as String? ?? '',
      ticketId: map['ticketId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'User',
      senderRole: map['senderRole'] as String? ?? 'customer',
      message: map['message'] as String? ?? '',
      attachments:
          (map['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isInternal: map['isInternal'] as bool? ?? false,
      createdAt: DateFormatter.parse(map['createdAt']),
      readAt: DateFormatter.parse(map['readAt']),
      clientMessageId: map['clientMessageId'] as String?,
    );
  }
}
