import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_notifications_state.dart';

class CustomerNotificationsViewModel
    extends Notifier<CustomerNotificationsState> {
  @override
  CustomerNotificationsState build() {
    Future.microtask(_loadNotifications);
    return const CustomerNotificationsState(isLoading: true);
  }

  String? get _currentUid {
    final profile = ref.read(authViewModelProvider).userProfile;
    if (profile != null && profile.uid.isNotEmpty) {
      return profile.uid;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final uid = _currentUid;
      if (uid == null) {
        state = state.copyWith(
          isLoading: false,
          notifications: const [],
          hasMore: false,
        );
        return;
      }

      final repo = ref.read(garageRepositoryProvider);
      final result = await repo.getNotificationsPaginated(
        recipientUid: uid,
        limit: 20,
      );

      state = state.copyWith(
        isLoading: false,
        notifications: result.items,
        hasMore: result.hasMore,
        lastDocument: result.lastDocument,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isFetchingNextPage || !state.hasMore || state.isLoading) return;

    final uid = _currentUid;
    if (uid == null) return;

    state = state.copyWith(isFetchingNextPage: true);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final result = await repo.getNotificationsPaginated(
        recipientUid: uid,
        lastDocument: state.lastDocument,
        limit: 20,
      );

      final combined = [...state.notifications, ...result.items];
      state = state.copyWith(
        isFetchingNextPage: false,
        notifications: combined,
        hasMore: result.hasMore,
        lastDocument: result.lastDocument,
      );
    } catch (e) {
      state = state.copyWith(isFetchingNextPage: false);
    }
  }

  void toggleSelect(String id) {
    final current = Set<String>.from(state.selectedIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(selectedIds: current);
  }

  void selectAll() {
    final allIds = state.filteredNotifications.map((n) => n.id).toSet();
    state = state.copyWith(selectedIds: allIds);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: const {});
  }

  Future<void> deleteSelected() async {
    if (state.selectedIds.isEmpty) return;

    final uid = _currentUid;
    final toDelete = state.selectedIds.toList();

    state = state.copyWith(isDeleting: true);
    try {
      if (uid != null) {
        await ref
            .read(garageRepositoryProvider)
            .deleteNotifications(notificationIds: toDelete, recipientUid: uid);
      }

      final updated = state.notifications
          .where((n) => !state.selectedIds.contains(n.id))
          .toList();

      state = state.copyWith(
        isDeleting: false,
        notifications: updated,
        selectedIds: const {},
      );
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteSingle(String id) async {
    final uid = _currentUid;
    try {
      if (uid != null) {
        await ref
            .read(garageRepositoryProvider)
            .deleteNotification(notificationId: id, recipientUid: uid);
      }
      final updated = state.notifications.where((n) => n.id != id).toList();
      final updatedSelected = Set<String>.from(state.selectedIds)..remove(id);
      state = state.copyWith(
        notifications: updated,
        selectedIds: updatedSelected,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    final uid = _currentUid;
    await ref
        .read(garageRepositoryProvider)
        .markNotificationAsRead(id, recipientUid: uid);
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllAsRead() async {
    final uid = _currentUid;
    final repo = ref.read(garageRepositoryProvider);
    for (final notif in state.notifications) {
      if (!notif.isRead) {
        await repo.markNotificationAsRead(notif.id, recipientUid: uid);
      }
    }
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated);
  }

  void toggleFilterUnread() {
    state = state.copyWith(filterOnlyUnread: !state.filterOnlyUnread);
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}

final customerNotificationsViewModelProvider =
    NotifierProvider<
      CustomerNotificationsViewModel,
      CustomerNotificationsState
    >(CustomerNotificationsViewModel.new);
