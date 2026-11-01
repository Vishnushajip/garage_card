import 'package:garage_card/core/formatting/date_formatter.dart';

class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.customerId,
    required this.customerName,
    this.customerPhone = '',
    this.merchantId = '',
    this.garageId = '',
    this.garageName = '',
    this.vehicleId,
    this.vehicleDisplay,
    this.vehiclePlate,
    this.jobId,
    this.jobNumber,
    this.invoiceId,
    this.invoiceNumber,
    required this.category,
    required this.subject,
    required this.description,
    this.status = 'open',
    this.priority = 'medium',
    this.assignedTo,
    this.preferredContact = 'in_app',
    this.attachments = const [],
    this.resolutionComment,
    this.resolvedAt,
    this.closedAt,
    this.reopenedAt,
    this.createdAt,
    this.updatedAt,
    this.lastMessageAt,
    this.lastMessageBy = 'customer',
    this.lastMessagePreview = '',
    this.unreadCustomer = false,
    this.unreadMerchant = true,
  });

  final String id;
  final String ticketNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String merchantId;
  final String garageId;
  final String garageName;
  final String? vehicleId;
  final String? vehicleDisplay;
  final String? vehiclePlate;
  final String? jobId;
  final String? jobNumber;
  final String? invoiceId;
  final String? invoiceNumber;
  final String category;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String? assignedTo;
  final String preferredContact;
  final List<String> attachments;
  final String? resolutionComment;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final DateTime? reopenedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastMessageAt;
  final String lastMessageBy;
  final String lastMessagePreview;
  final bool unreadCustomer;
  final bool unreadMerchant;

  bool get isOpen => status == 'open' || status == 'reopened';
  bool get isInProgress => status == 'in_progress' || status == 'assigned';
  bool get isWaitingCustomer => status == 'waiting_for_customer';
  bool get isWaitingMerchant => status == 'waiting_for_merchant';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get canCustomerReopen => status == 'resolved' || status == 'closed';

  bool get isHighOrUrgent => priority == 'high' || priority == 'urgent';

  SupportTicketModel copyWith({
    String? id,
    String? ticketNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? merchantId,
    String? garageId,
    String? garageName,
    String? vehicleId,
    String? vehicleDisplay,
    String? vehiclePlate,
    String? jobId,
    String? jobNumber,
    String? invoiceId,
    String? invoiceNumber,
    String? category,
    String? subject,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    String? preferredContact,
    List<String>? attachments,
    String? resolutionComment,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
    String? lastMessageBy,
    String? lastMessagePreview,
    bool? unreadCustomer,
    bool? unreadMerchant,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      merchantId: merchantId ?? this.merchantId,
      garageId: garageId ?? this.garageId,
      garageName: garageName ?? this.garageName,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleDisplay: vehicleDisplay ?? this.vehicleDisplay,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      jobId: jobId ?? this.jobId,
      jobNumber: jobNumber ?? this.jobNumber,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      preferredContact: preferredContact ?? this.preferredContact,
      attachments: attachments ?? this.attachments,
      resolutionComment: resolutionComment ?? this.resolutionComment,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      reopenedAt: reopenedAt ?? this.reopenedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCustomer: unreadCustomer ?? this.unreadCustomer,
      unreadMerchant: unreadMerchant ?? this.unreadMerchant,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'merchantId': merchantId,
      'garageId': garageId,
      'garageName': garageName,
      'vehicleId': vehicleId,
      'vehicleDisplay': vehicleDisplay,
      'vehiclePlate': vehiclePlate,
      'jobId': jobId,
      'jobNumber': jobNumber,
      'invoiceId': invoiceId,
      'invoiceNumber': invoiceNumber,
      'category': category,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'preferredContact': preferredContact,
      'attachments': attachments,
      'resolutionComment': resolutionComment,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'reopenedAt': reopenedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessageBy': lastMessageBy,
      'lastMessagePreview': lastMessagePreview,
      'unreadCustomer': unreadCustomer,
      'unreadMerchant': unreadMerchant,
    };
  }

  factory SupportTicketModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SupportTicketModel(
      id: id ?? map['id'] as String? ?? '',
      ticketNumber: map['ticketNumber'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? 'Customer',
      customerPhone: map['customerPhone'] as String? ?? '',
      merchantId: map['merchantId'] as String? ?? '',
      garageId: map['garageId'] as String? ?? '',
      garageName: map['garageName'] as String? ?? '',
      vehicleId: map['vehicleId'] as String?,
      vehicleDisplay: map['vehicleDisplay'] as String?,
      vehiclePlate: map['vehiclePlate'] as String?,
      jobId: map['jobId'] as String?,
      jobNumber: map['jobNumber'] as String?,
      invoiceId: map['invoiceId'] as String?,
      invoiceNumber: map['invoiceNumber'] as String?,
      category: map['category'] as String? ?? 'general_support',
      subject: map['subject'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      priority: map['priority'] as String? ?? 'medium',
      assignedTo: map['assignedTo'] as String?,
      preferredContact: map['preferredContact'] as String? ?? 'in_app',
      attachments:
          (map['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      resolutionComment: map['resolutionComment'] as String?,
      resolvedAt: DateFormatter.parse(map['resolvedAt']),
      closedAt: DateFormatter.parse(map['closedAt']),
      reopenedAt: DateFormatter.parse(map['reopenedAt']),
      createdAt: DateFormatter.parse(map['createdAt']),
      updatedAt: DateFormatter.parse(map['updatedAt']),
      lastMessageAt: DateFormatter.parse(map['lastMessageAt']),
      lastMessageBy: map['lastMessageBy'] as String? ?? 'customer',
      lastMessagePreview: map['lastMessagePreview'] as String? ?? '',
      unreadCustomer: map['unreadCustomer'] as bool? ?? false,
      unreadMerchant: map['unreadMerchant'] as bool? ?? true,
    );
  }
}
