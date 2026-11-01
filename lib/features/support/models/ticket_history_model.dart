import 'package:garage_card/core/formatting/date_formatter.dart';

class TicketHistoryModel {
  const TicketHistoryModel({
    required this.id,
    required this.ticketId,
    required this.action,
    this.previousValue,
    this.newValue,
    required this.performedBy,
    required this.performedByName,
    required this.performedByRole,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String ticketId;
  final String action;
  final String? previousValue;
  final String? newValue;
  final String performedBy;
  final String performedByName;
  final String performedByRole;
  final String? comment;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'action': action,
      'previousValue': previousValue,
      'newValue': newValue,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'performedByRole': performedByRole,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory TicketHistoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TicketHistoryModel(
      id: id ?? map['id'] as String? ?? '',
      ticketId: map['ticketId'] as String? ?? '',
      action: map['action'] as String? ?? 'updated',
      previousValue: map['previousValue'] as String?,
      newValue: map['newValue'] as String?,
      performedBy: map['performedBy'] as String? ?? '',
      performedByName: map['performedByName'] as String? ?? 'System',
      performedByRole: map['performedByRole'] as String? ?? 'customer',
      comment: map['comment'] as String?,
      createdAt: DateFormatter.parse(map['createdAt']),
    );
  }
}
