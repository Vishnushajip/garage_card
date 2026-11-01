import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/notifications/fcm_notification_sender.dart';
import 'package:garage_card/features/support/models/support_ticket_model.dart';
import 'package:garage_card/features/support/models/ticket_history_model.dart';
import 'package:garage_card/features/support/models/ticket_message_model.dart';
import 'package:garage_card/features/support/models/ticket_stats_model.dart';
import 'package:uuid/uuid.dart';

class SupportRepository {
  SupportRepository({FirebaseFirestore? firestore})
    : _customFirestore = firestore;

  final FirebaseFirestore? _customFirestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  final List<SupportTicketModel> _memoryTickets = [];
  final Map<String, List<TicketMessageModel>> _memoryMessages = {};
  final Map<String, List<TicketHistoryModel>> _memoryHistory = {};

  void clearCache() {
    _memoryTickets.clear();
    _memoryMessages.clear();
    _memoryHistory.clear();
  }

  String _generateTicketNumber() {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    final randomPart = 1000 + Random().nextInt(9000);
    return 'TKT-$yearMonth-$randomPart';
  }

  Future<SupportTicketModel> createTicket(
    SupportTicketModel ticket, {
    String? initialMessage,
  }) async {
    final ticketId = ticket.id.isNotEmpty ? ticket.id : _uuid.v4();
    final ticketNumber = ticket.ticketNumber.isNotEmpty
        ? ticket.ticketNumber
        : _generateTicketNumber();
    final now = DateTime.now();

    final preparedTicket = ticket.copyWith(
      id: ticketId,
      ticketNumber: ticketNumber,
      createdAt: now,
      updatedAt: now,
      lastMessageAt: now,
      lastMessageBy: 'customer',
      lastMessagePreview: initialMessage ?? ticket.description,
      unreadCustomer: false,
      unreadMerchant: true,
      status: 'open',
    );

    final historyItem = TicketHistoryModel(
      id: _uuid.v4(),
      ticketId: ticketId,
      action: 'created',
      newValue: 'open',
      performedBy: ticket.customerId,
      performedByName: ticket.customerName,
      performedByRole: 'customer',
      comment: 'Ticket opened with subject: ${ticket.subject}',
      createdAt: now,
    );

    final firstMsg = TicketMessageModel(
      id: _uuid.v4(),
      ticketId: ticketId,
      senderId: ticket.customerId,
      senderName: ticket.customerName,
      senderRole: 'customer',
      message: initialMessage ?? ticket.description,
      attachments: ticket.attachments,
      isInternal: false,
      createdAt: now,
    );

    if (FirebaseConfig.isInitialized) {
      try {
        final batch = _firestore.batch();
        final ticketRef = _firestore.collection('supportTickets').doc(ticketId);
        final historyRef = ticketRef.collection('history').doc(historyItem.id);
        final msgRef = ticketRef.collection('messages').doc(firstMsg.id);

        batch.set(ticketRef, preparedTicket.toMap());
        batch.set(historyRef, historyItem.toMap());
        batch.set(msgRef, firstMsg.toMap());
        await batch.commit().timeout(const Duration(seconds: 6));
      } catch (e) {
        debugPrint('SUPPORT_REPO_CREATE_TICKET_FIREBASE_ERROR: $e');
      }
    }

    _memoryTickets.removeWhere((t) => t.id == ticketId);
    _memoryTickets.insert(0, preparedTicket);
    _memoryMessages.putIfAbsent(ticketId, () => []).add(firstMsg);
    _memoryHistory.putIfAbsent(ticketId, () => []).add(historyItem);

    if (preparedTicket.garageId.isNotEmpty) {
      FcmNotificationSender.send(
        title: 'New Support Ticket: $ticketNumber',
        content: '${ticket.customerName}: ${ticket.subject}',
        garageId: preparedTicket.garageId,
        deepLink: '/merchant/support/$ticketId',
        type: 'support_ticket_created',
      );
    }

    FcmNotificationSender.send(
      title: 'Support Ticket Registered',
      content:
          'Your ticket $ticketNumber has been received. Our team will review it shortly.',
      recipientUid: ticket.customerId,
      deepLink: '/customer/support/$ticketId',
      type: 'support_ticket_ack',
    );

    return preparedTicket;
  }

  Future<List<SupportTicketModel>> getCustomerTickets(
    String customerId, {
    String? status,
    String? category,
    String? query,
  }) async {
    if (customerId.isEmpty) return [];

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> ref = _firestore
            .collection('supportTickets')
            .where('customerId', isEqualTo: customerId);

        if (status != null && status.isNotEmpty && status != 'all') {
          ref = ref.where('status', isEqualTo: status);
        }
        if (category != null && category.isNotEmpty && category != 'all') {
          ref = ref.where('category', isEqualTo: category);
        }

        final snap = await ref.get().timeout(const Duration(seconds: 5));
        var list = snap.docs
            .map((d) => SupportTicketModel.fromMap(d.data(), id: d.id))
            .toList();

        list.sort((a, b) {
          final bDate = b.updatedAt ?? b.createdAt ?? DateTime(2000);
          final aDate = a.updatedAt ?? a.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });

        if (query != null && query.trim().isNotEmpty) {
          final q = query.toLowerCase().trim();
          list = list.where((t) {
            return t.ticketNumber.toLowerCase().contains(q) ||
                t.subject.toLowerCase().contains(q) ||
                t.garageName.toLowerCase().contains(q) ||
                (t.vehicleDisplay?.toLowerCase().contains(q) ?? false);
          }).toList();
        }

        return list;
      } catch (e) {
        debugPrint('SUPPORT_REPO_GET_CUSTOMER_TICKETS_ERROR: $e');
      }
    }

    var list = _memoryTickets.where((t) => t.customerId == customerId).toList();
    if (status != null && status.isNotEmpty && status != 'all') {
      list = list.where((t) => t.status == status).toList();
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      list = list.where((t) => t.category == category).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((t) {
        return t.ticketNumber.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.garageName.toLowerCase().contains(q) ||
            (t.vehicleDisplay?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    list.sort((a, b) {
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime(2000);
      final aDate = a.updatedAt ?? a.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return list;
  }

  Future<List<SupportTicketModel>> getMerchantTickets(
    String garageId, {
    String? status,
    String? category,
    String? priority,
    String? query,
  }) async {
    if (garageId.isEmpty) return [];

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> ref = _firestore
            .collection('supportTickets')
            .where('garageId', isEqualTo: garageId);

        if (status != null && status.isNotEmpty && status != 'all') {
          ref = ref.where('status', isEqualTo: status);
        }
        if (category != null && category.isNotEmpty && category != 'all') {
          ref = ref.where('category', isEqualTo: category);
        }
        if (priority != null && priority.isNotEmpty && priority != 'all') {
          ref = ref.where('priority', isEqualTo: priority);
        }

        final snap = await ref.get().timeout(const Duration(seconds: 5));
        var list = snap.docs
            .map((d) => SupportTicketModel.fromMap(d.data(), id: d.id))
            .toList();

        list.sort((a, b) {
          final bDate = b.updatedAt ?? b.createdAt ?? DateTime(2000);
          final aDate = a.updatedAt ?? a.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });

        if (query != null && query.trim().isNotEmpty) {
          final q = query.toLowerCase().trim();
          list = list.where((t) {
            return t.ticketNumber.toLowerCase().contains(q) ||
                t.subject.toLowerCase().contains(q) ||
                t.customerName.toLowerCase().contains(q) ||
                (t.vehiclePlate?.toLowerCase().contains(q) ?? false);
          }).toList();
        }

        return list;
      } catch (e) {
        debugPrint('SUPPORT_REPO_GET_MERCHANT_TICKETS_ERROR: $e');
      }
    }

    var list = _memoryTickets.where((t) => t.garageId == garageId).toList();
    if (status != null && status.isNotEmpty && status != 'all') {
      list = list.where((t) => t.status == status).toList();
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      list = list.where((t) => t.category == category).toList();
    }
    if (priority != null && priority.isNotEmpty && priority != 'all') {
      list = list.where((t) => t.priority == priority).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((t) {
        return t.ticketNumber.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.customerName.toLowerCase().contains(q) ||
            (t.vehiclePlate?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    list.sort((a, b) {
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime(2000);
      final aDate = a.updatedAt ?? a.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return list;
  }

  Future<SupportTicketModel?> getTicketDetails(String ticketId) async {
    if (ticketId.isEmpty) return null;

    if (FirebaseConfig.isInitialized) {
      try {
        final doc = await _firestore
            .collection('supportTickets')
            .doc(ticketId)
            .get()
            .timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          return SupportTicketModel.fromMap(doc.data()!, id: doc.id);
        }
      } catch (e) {
        debugPrint('SUPPORT_REPO_GET_DETAILS_ERROR: $e');
      }
    }

    try {
      return _memoryTickets.firstWhere((t) => t.id == ticketId);
    } catch (_) {
      return null;
    }
  }

  Stream<SupportTicketModel?> watchTicket(String ticketId) {
    if (FirebaseConfig.isInitialized) {
      return _firestore
          .collection('supportTickets')
          .doc(ticketId)
          .snapshots()
          .map((doc) {
            if (!doc.exists || doc.data() == null) return null;
            return SupportTicketModel.fromMap(doc.data()!, id: doc.id);
          })
          .handleError((_) => null);
    }

    try {
      final item = _memoryTickets.firstWhere((t) => t.id == ticketId);
      return Stream.value(item);
    } catch (_) {
      return Stream.value(null);
    }
  }

  Stream<List<TicketMessageModel>> watchTicketMessages(
    String ticketId, {
    bool includeInternal = false,
  }) {
    if (FirebaseConfig.isInitialized) {
      return _firestore
          .collection('supportTickets')
          .doc(ticketId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snap) {
            var msgs = snap.docs
                .map((d) => TicketMessageModel.fromMap(d.data(), id: d.id))
                .toList();
            if (!includeInternal) {
              msgs = msgs.where((m) => !m.isInternal).toList();
            }
            return msgs;
          })
          .handleError((_) => <TicketMessageModel>[]);
    }

    final msgs = _memoryMessages[ticketId] ?? [];
    final filtered = includeInternal
        ? msgs
        : msgs.where((m) => !m.isInternal).toList();
    return Stream.value(List<TicketMessageModel>.from(filtered));
  }

  Future<TicketMessageModel> sendMessage(
    String ticketId,
    TicketMessageModel message, {
    String? updateStatusTo,
  }) async {
    final msgId = message.id.isNotEmpty ? message.id : _uuid.v4();
    final now = DateTime.now();

    final preparedMsg = message.copyWith(
      id: msgId,
      ticketId: ticketId,
      createdAt: now,
    );

    final isCustomer = message.senderRole == 'customer';
    String newStatus = updateStatusTo ?? '';
    if (newStatus.isEmpty) {
      if (isCustomer) {
        newStatus = 'waiting_for_merchant';
      } else if (!message.isInternal) {
        newStatus = 'waiting_for_customer';
      }
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final batch = _firestore.batch();
        final msgRef = _firestore
            .collection('supportTickets')
            .doc(ticketId)
            .collection('messages')
            .doc(msgId);
        final ticketRef = _firestore.collection('supportTickets').doc(ticketId);

        batch.set(msgRef, preparedMsg.toMap());

        final Map<String, dynamic> updateFields = {
          'lastMessageAt': now.toIso8601String(),
          'lastMessageBy': message.senderRole,
          'lastMessagePreview': message.isInternal
              ? '[Internal Note]'
              : message.message,
          'updatedAt': now.toIso8601String(),
        };

        if (isCustomer) {
          updateFields['unreadMerchant'] = true;
        } else if (!message.isInternal) {
          updateFields['unreadCustomer'] = true;
        }

        if (newStatus.isNotEmpty && !message.isInternal) {
          updateFields['status'] = newStatus;
        }

        batch.update(ticketRef, updateFields);
        await batch.commit().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('SUPPORT_REPO_SEND_MESSAGE_FIREBASE_ERROR: $e');
      }
    }

    _memoryMessages.putIfAbsent(ticketId, () => []).add(preparedMsg);

    final idx = _memoryTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final existing = _memoryTickets[idx];
      _memoryTickets[idx] = existing.copyWith(
        lastMessageAt: now,
        lastMessageBy: message.senderRole,
        lastMessagePreview: message.isInternal
            ? '[Internal Note]'
            : message.message,
        updatedAt: now,
        unreadMerchant: isCustomer ? true : existing.unreadMerchant,
        unreadCustomer: (!isCustomer && !message.isInternal)
            ? true
            : existing.unreadCustomer,
        status: (newStatus.isNotEmpty && !message.isInternal)
            ? newStatus
            : existing.status,
      );
    }

    final ticket = await getTicketDetails(ticketId);
    if (ticket != null) {
      if (isCustomer && ticket.garageId.isNotEmpty) {
        FcmNotificationSender.send(
          title: 'Reply on Ticket ${ticket.ticketNumber}',
          content: '${message.senderName}: ${message.message}',
          garageId: ticket.garageId,
          deepLink: '/merchant/support/$ticketId',
          type: 'support_message_received',
        );
      } else if (!isCustomer && !message.isInternal) {
        FcmNotificationSender.send(
          title: 'Reply on Ticket ${ticket.ticketNumber}',
          content: '${message.senderName}: ${message.message}',
          recipientUid: ticket.customerId,
          deepLink: '/customer/support/$ticketId',
          type: 'support_message_received',
        );
      }
    }

    return preparedMsg;
  }

  Future<void> updateTicketStatus(
    String ticketId,
    String newStatus, {
    String? resolutionComment,
    required String performedBy,
    required String performedByName,
    required String performedByRole,
  }) async {
    final now = DateTime.now();
    final ticket = await getTicketDetails(ticketId);
    if (ticket == null) return;

    final historyItem = TicketHistoryModel(
      id: _uuid.v4(),
      ticketId: ticketId,
      action: 'status_changed',
      previousValue: ticket.status,
      newValue: newStatus,
      performedBy: performedBy,
      performedByName: performedByName,
      performedByRole: performedByRole,
      comment: resolutionComment,
      createdAt: now,
    );

    final Map<String, dynamic> updateFields = {
      'status': newStatus,
      'updatedAt': now.toIso8601String(),
    };

    if (newStatus == 'resolved') {
      updateFields['resolvedAt'] = now.toIso8601String();
      if (resolutionComment != null) {
        updateFields['resolutionComment'] = resolutionComment;
      }
    } else if (newStatus == 'closed') {
      updateFields['closedAt'] = now.toIso8601String();
    } else if (newStatus == 'reopened') {
      updateFields['reopenedAt'] = now.toIso8601String();
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final batch = _firestore.batch();
        final ticketRef = _firestore.collection('supportTickets').doc(ticketId);
        final historyRef = ticketRef.collection('history').doc(historyItem.id);

        batch.update(ticketRef, updateFields);
        batch.set(historyRef, historyItem.toMap());
        await batch.commit().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('SUPPORT_REPO_UPDATE_STATUS_FIREBASE_ERROR: $e');
      }
    }

    _memoryHistory.putIfAbsent(ticketId, () => []).add(historyItem);
    final idx = _memoryTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _memoryTickets[idx] = _memoryTickets[idx].copyWith(
        status: newStatus,
        updatedAt: now,
        resolvedAt: newStatus == 'resolved' ? now : null,
        closedAt: newStatus == 'closed' ? now : null,
        reopenedAt: newStatus == 'reopened' ? now : null,
        resolutionComment:
            resolutionComment ?? _memoryTickets[idx].resolutionComment,
      );
    }

    if (performedByRole == 'merchant') {
      FcmNotificationSender.send(
        title: 'Ticket ${ticket.ticketNumber} Updated',
        content: 'Status changed to ${_formatStatus(newStatus)}',
        recipientUid: ticket.customerId,
        deepLink: '/customer/support/$ticketId',
        type: 'support_status_updated',
      );
    } else if (performedByRole == 'customer' && ticket.garageId.isNotEmpty) {
      FcmNotificationSender.send(
        title: 'Ticket ${ticket.ticketNumber} Reopened',
        content: 'Customer reopened this ticket',
        garageId: ticket.garageId,
        deepLink: '/merchant/support/$ticketId',
        type: 'support_status_updated',
      );
    }
  }

  Future<void> updateTicketPriority(
    String ticketId,
    String newPriority, {
    required String performedBy,
    required String performedByName,
  }) async {
    final now = DateTime.now();
    final ticket = await getTicketDetails(ticketId);
    if (ticket == null) return;

    final historyItem = TicketHistoryModel(
      id: _uuid.v4(),
      ticketId: ticketId,
      action: 'priority_changed',
      previousValue: ticket.priority,
      newValue: newPriority,
      performedBy: performedBy,
      performedByName: performedByName,
      performedByRole: 'merchant',
      createdAt: now,
    );

    if (FirebaseConfig.isInitialized) {
      try {
        final batch = _firestore.batch();
        final ticketRef = _firestore.collection('supportTickets').doc(ticketId);
        final historyRef = ticketRef.collection('history').doc(historyItem.id);

        batch.update(ticketRef, {
          'priority': newPriority,
          'updatedAt': now.toIso8601String(),
        });
        batch.set(historyRef, historyItem.toMap());
        await batch.commit().timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('SUPPORT_REPO_UPDATE_PRIORITY_FIREBASE_ERROR: $e');
      }
    }

    _memoryHistory.putIfAbsent(ticketId, () => []).add(historyItem);
    final idx = _memoryTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _memoryTickets[idx] = _memoryTickets[idx].copyWith(
        priority: newPriority,
        updatedAt: now,
      );
    }
  }

  Future<List<TicketHistoryModel>> getTicketHistory(String ticketId) async {
    if (ticketId.isEmpty) return [];

    if (FirebaseConfig.isInitialized) {
      try {
        final snap = await _firestore
            .collection('supportTickets')
            .doc(ticketId)
            .collection('history')
            .orderBy('createdAt', descending: true)
            .get()
            .timeout(const Duration(seconds: 4));
        return snap.docs
            .map((d) => TicketHistoryModel.fromMap(d.data(), id: d.id))
            .toList();
      } catch (e) {
        debugPrint('SUPPORT_REPO_GET_HISTORY_ERROR: $e');
      }
    }

    final list = _memoryHistory[ticketId] ?? [];
    return List<TicketHistoryModel>.from(list.reversed);
  }

  Future<TicketStatsModel> calculateMerchantTicketStats(String garageId) async {
    final tickets = await getMerchantTickets(garageId);
    int open = 0;
    int newTickets = 0;
    int inProgress = 0;
    int waitingCustomer = 0;
    int waitingMerchant = 0;
    int resolved = 0;
    int closed = 0;

    for (final t in tickets) {
      if (t.status == 'open') {
        open++;
        newTickets++;
      } else if (t.status == 'in_progress' || t.status == 'assigned') {
        inProgress++;
      } else if (t.status == 'waiting_for_customer') {
        waitingCustomer++;
      } else if (t.status == 'waiting_for_merchant') {
        waitingMerchant++;
      } else if (t.status == 'resolved') {
        resolved++;
      } else if (t.status == 'closed') {
        closed++;
      }
    }

    return TicketStatsModel(
      total: tickets.length,
      open: open,
      newTickets: newTickets,
      inProgress: inProgress,
      waitingForCustomer: waitingCustomer,
      waitingForMerchant: waitingMerchant,
      resolved: resolved,
      closed: closed,
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'waiting_for_customer':
        return 'Waiting for Customer';
      case 'waiting_for_merchant':
        return 'Waiting for Merchant';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      case 'reopened':
        return 'Reopened';
      default:
        return 'Open';
    }
  }
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository();
});
