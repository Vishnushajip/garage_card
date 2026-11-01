import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';

import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import 'garage_repository_store.dart';

mixin ChatRepository on GarageRepositoryStore {
  Future<ConversationModel> getOrCreateConversation({
    required String customerId,
    required String customerName,
    required String garageId,
    required String garageName,
    String? customerPhone,
    String? garagePhone,
    String? serviceJobId,
    String? serviceJobTitle,
  }) async {
    final existingLocal = conversations
        .where((c) => c.customerId == customerId && c.garageId == garageId)
        .firstOrNull;
    if (existingLocal != null) {
      if ((customerPhone != null && existingLocal.customerPhone == null) ||
          (garagePhone != null && existingLocal.garagePhone == null)) {
        final updated = existingLocal.copyWith(
          customerPhone: customerPhone ?? existingLocal.customerPhone,
          garagePhone: garagePhone ?? existingLocal.garagePhone,
        );
        final idx = conversations.indexOf(existingLocal);
        conversations[idx] = updated;
        return updated;
      }
      return existingLocal;
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('conversations')
            .where('customerId', isEqualTo: customerId)
            .where('garageId', isEqualTo: garageId)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final d = query.docs.first;
          final existing = ConversationModel.fromFirestore(d.data(), d.id);
          if ((customerPhone != null && existing.customerPhone == null) ||
              (garagePhone != null && existing.garagePhone == null)) {
            final updated = existing.copyWith(
              customerPhone: customerPhone ?? existing.customerPhone,
              garagePhone: garagePhone ?? existing.garagePhone,
            );
            await d.reference.set(
              updated.toFirestore(),
              SetOptions(merge: true),
            );
            return updated;
          }
          return existing;
        }

        final docRef = FirebaseFirestore.instance
            .collection('conversations')
            .doc();
        final newConv = ConversationModel(
          id: docRef.id,
          customerId: customerId,
          customerName: customerName,
          garageId: garageId,
          garageName: garageName,
          customerPhone: customerPhone,
          garagePhone: garagePhone,
          serviceJobId: serviceJobId,
          serviceJobTitle: serviceJobTitle,
          createdAt: DateTime.now(),
        );
        await docRef.set(newConv.toFirestore());
        conversations.insert(0, newConv);
        return newConv;
      } catch (_) {}
    }

    final newConv = ConversationModel(
      id: const Uuid().v4(),
      customerId: customerId,
      customerName: customerName,
      garageId: garageId,
      garageName: garageName,
      customerPhone: customerPhone,
      garagePhone: garagePhone,
      serviceJobId: serviceJobId,
      serviceJobTitle: serviceJobTitle,
      createdAt: DateTime.now(),
    );
    conversations.insert(0, newConv);
    return newConv;
  }

  Stream<List<ConversationModel>> streamUserConversations(
    String userId, {
    required bool isMerchant,
    int limit = 25,
  }) {
    if (userId.isEmpty) {
      return Stream.value(const []);
    }
    if (FirebaseConfig.isInitialized) {
      final field = isMerchant ? 'garageId' : 'customerId';
      return FirebaseFirestore.instance
          .collection('conversations')
          .where(field, isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => ConversationModel.fromFirestore(d.data(), d.id))
                .toList(),
          );
    }
    final fieldFilter = isMerchant
        ? (ConversationModel c) => c.garageId == userId
        : (ConversationModel c) => c.customerId == userId;
    return Stream.value(conversations.where(fieldFilter).toList());
  }

  Stream<List<ChatMessageModel>> streamConversationMessages(
    String conversationId, {
    int limit = 40,
  }) {
    if (conversationId.isEmpty) {
      return Stream.value(const []);
    }
    if (FirebaseConfig.isInitialized) {
      return FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => ChatMessageModel.fromFirestore(d.data(), d.id))
                .toList(),
          );
    }
    return Stream.value(
      conversations.isEmpty
            ? messages.where((m) => m.conversationId == conversationId).toList()
            : messages.where((m) => m.conversationId == conversationId).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        ),
    );
  }

  Future<void> sendChatMessage({
    required String conversationId,
    required String senderId,
    required String senderRole,
    required String text,
    String? attachmentUrl,
  }) async {
    final now = DateTime.now();
    final messageId = const Uuid().v4();
    final msg = ChatMessageModel(
      id: messageId,
      conversationId: conversationId,
      senderId: senderId,
      senderRole: senderRole,
      text: text,
      attachmentUrl: attachmentUrl,
      createdAt: now,
      isRead: false,
    );
    messages.insert(0, msg);

    final convIdx = conversations.indexWhere((c) => c.id == conversationId);
    if (convIdx >= 0) {
      final c = conversations[convIdx];
      conversations[convIdx] = c.copyWith(
        lastMessage: text,
        lastMessageTime: now,
        lastSenderId: senderId,
        unreadCountCustomer: senderRole == 'merchant'
            ? c.unreadCountCustomer + 1
            : c.unreadCountCustomer,
        unreadCountMerchant: senderRole == 'customer'
            ? c.unreadCountMerchant + 1
            : c.unreadCountMerchant,
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final convRef = FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId);
        final msgRef = convRef.collection('messages').doc(messageId);

        final batch = FirebaseFirestore.instance.batch();
        batch.set(msgRef, msg.toFirestore());

        final isCustomer = senderRole == 'customer';
        batch.update(convRef, {
          'lastMessage': text,
          'lastMessageTime': now.toIso8601String(),
          'lastSenderId': senderId,
          if (isCustomer)
            'unreadCountMerchant': FieldValue.increment(1)
          else
            'unreadCountCustomer': FieldValue.increment(1),
        });

        await batch.commit();

        final convSnap = await convRef.get();
        if (convSnap.exists && convSnap.data() != null) {
          final data = convSnap.data()!;
          final recipientUid = isCustomer
              ? (data['garageId'] as String? ?? '')
              : (data['customerId'] as String? ?? '');
          final senderTitle = isCustomer
              ? (data['customerName'] as String? ?? 'Customer')
              : (data['garageName'] as String? ?? 'Garage');
          if (recipientUid.isNotEmpty) {
            final notifId =
                'chat_${conversationId}_${now.millisecondsSinceEpoch}';
            await FirebaseFirestore.instance
                .collection('users')
                .doc(recipientUid)
                .collection('notifications')
                .doc(notifId)
                .set({
                  'recipientUid': recipientUid,
                  'title': 'New message from $senderTitle',
                  'body': text,
                  'type': 'chat',
                  'referenceId': conversationId,
                  'deepLink': '/chat/$conversationId',
                  'eventId': notifId,
                  'isRead': false,
                  'createdAt': now.toIso8601String(),
                }, SetOptions(merge: true));
          }
        }
      } catch (_) {}
    }
  }

  Future<void> markConversationRead(
    String conversationId, {
    required bool isMerchant,
  }) async {
    final convIdx = conversations.indexWhere((c) => c.id == conversationId);
    if (convIdx >= 0) {
      final c = conversations[convIdx];
      conversations[convIdx] = isMerchant
          ? c.copyWith(unreadCountMerchant: 0)
          : c.copyWith(unreadCountCustomer: 0);
    }

    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId)
            .update({
              isMerchant ? 'unreadCountMerchant' : 'unreadCountCustomer': 0,
            });
      } catch (_) {}
    }
  }
}
