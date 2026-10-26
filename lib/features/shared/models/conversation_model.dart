import 'package:garage_card/core/formatting/date_formatter.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.garageId,
    required this.garageName,
    this.lastMessage = '',
    this.lastMessageTime,
    this.lastSenderId,
    this.unreadCountCustomer = 0,
    this.unreadCountMerchant = 0,
    this.serviceJobId,
    this.serviceJobTitle,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String garageId;
  final String garageName;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String? lastSenderId;
  final int unreadCountCustomer;
  final int unreadCountMerchant;
  final String? serviceJobId;
  final String? serviceJobTitle;
  final DateTime? createdAt;

  int unreadCountFor(String userId) {
    if (userId == customerId) {
      return unreadCountCustomer;
    }
    return unreadCountMerchant;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'garageId': garageId,
      'garageName': garageName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastSenderId': lastSenderId,
      'unreadCountCustomer': unreadCountCustomer,
      'unreadCountMerchant': unreadCountMerchant,
      'serviceJobId': serviceJobId,
      'serviceJobTitle': serviceJobTitle,
      'createdAt': createdAt?.toIso8601String(),
      'participants': [customerId, garageId],
    };
  }

  factory ConversationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ConversationModel(
      id: id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? 'Customer',
      garageId: data['garageId'] as String? ?? '',
      garageName: data['garageName'] as String? ?? 'Garage',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: DateFormatter.parse(data['lastMessageTime']),
      lastSenderId: data['lastSenderId'] as String?,
      unreadCountCustomer: (data['unreadCountCustomer'] as num?)?.toInt() ?? 0,
      unreadCountMerchant: (data['unreadCountMerchant'] as num?)?.toInt() ?? 0,
      serviceJobId: data['serviceJobId'] as String?,
      serviceJobTitle: data['serviceJobTitle'] as String?,
      createdAt: DateFormatter.parse(data['createdAt']),
    );
  }

  ConversationModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? garageId,
    String? garageName,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastSenderId,
    int? unreadCountCustomer,
    int? unreadCountMerchant,
    String? serviceJobId,
    String? serviceJobTitle,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      garageId: garageId ?? this.garageId,
      garageName: garageName ?? this.garageName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCountCustomer: unreadCountCustomer ?? this.unreadCountCustomer,
      unreadCountMerchant: unreadCountMerchant ?? this.unreadCountMerchant,
      serviceJobId: serviceJobId ?? this.serviceJobId,
      serviceJobTitle: serviceJobTitle ?? this.serviceJobTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
