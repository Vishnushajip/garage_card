import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/pagination/paginated_result.dart';

import '../models/notification_model.dart';
import 'garage_repository_store.dart';

mixin NotificationRepository on GarageRepositoryStore {
  Future<List<NotificationModel>> getNotifications({
    required String recipientUid,
    int page = 0,
    int limit = 20,
  }) async {
    if (FirebaseConfig.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 3));

        return snapshot.docs
            .map((d) => NotificationModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (_) {}
    }

    final list = notifications
        .where((n) => n.recipientUid == recipientUid)
        .toList();
    final start = page * limit;
    if (start >= list.length) return [];
    final end = (start + limit) > list.length ? list.length : (start + limit);
    return list.sublist(start, end);
  }

  Future<PaginatedResult<NotificationModel>> getNotificationsPaginated({
    required String recipientUid,
    Object? lastDocument,
    int limit = 20,
  }) async {
    if (FirebaseConfig.isInitialized && recipientUid.isNotEmpty) {
      try {
        Query query = FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(limit);

        if (lastDocument is DocumentSnapshot) {
          query = query.startAfterDocument(lastDocument);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 3));
        final items = snapshot.docs
            .map(
              (d) => NotificationModel.fromFirestore(
                d.data() as Map<String, dynamic>,
                d.id,
              ),
            )
            .toList();

        final hasMore = snapshot.docs.length >= limit;
        final nextLastDoc = snapshot.docs.isNotEmpty
            ? snapshot.docs.last
            : null;

        return PaginatedResult(
          items: items,
          hasMore: hasMore,
          lastDocument: nextLastDoc,
        );
      } catch (_) {}
    }

    final local = notifications
        .where((n) => n.recipientUid == recipientUid)
        .toList();
    return PaginatedResult(
      items: local.take(limit).toList(),
      hasMore: local.length > limit,
      lastDocument: null,
    );
  }

  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    final id = notification.id.isNotEmpty ? notification.id : const Uuid().v4();
    final newNotif = notification.copyWith(id: id);

    if (FirebaseConfig.isInitialized &&
        FirebaseConfig.isFirestoreDatabaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newNotif.recipientUid)
            .collection('notifications')
            .doc(newNotif.id)
            .set(newNotif.toFirestore(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    notifications.insert(0, newNotif);
    return newNotif;
  }

  Future<void> markNotificationAsRead(
    String notificationId, {
    String? recipientUid,
  }) async {
    if (FirebaseConfig.isInitialized &&
        recipientUid != null &&
        recipientUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
      } catch (_) {}
    }

    final idx = notifications.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
    }
  }

  Future<void> deleteNotification({
    required String notificationId,
    required String recipientUid,
  }) async {
    if (FirebaseConfig.isInitialized && recipientUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .doc(notificationId)
            .delete();
      } catch (_) {}
    }

    notifications.removeWhere((n) => n.id == notificationId);
  }

  Future<void> deleteNotifications({
    required List<String> notificationIds,
    required String recipientUid,
  }) async {
    if (FirebaseConfig.isInitialized &&
        recipientUid.isNotEmpty &&
        notificationIds.isNotEmpty) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final col = FirebaseFirestore.instance
            .collection('users')
            .doc(recipientUid)
            .collection('notifications');
        for (final id in notificationIds) {
          batch.delete(col.doc(id));
        }
        await batch.commit();
      } catch (_) {}
    }

    notifications.removeWhere((n) => notificationIds.contains(n.id));
  }
}
