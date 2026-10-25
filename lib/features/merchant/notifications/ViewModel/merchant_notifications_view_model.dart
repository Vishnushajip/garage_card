import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import '../Model/merchant_notifications_state.dart';

class MerchantNotificationsViewModel
    extends Notifier<MerchantNotificationsState> {
  @override
  MerchantNotificationsState build() {
    Future.microtask(_loadNotifications);
    return const MerchantNotificationsState(isLoading: true);
  }

  Future<void> _loadNotifications() async {
    try {
      final repo = ref.read(garageRepositoryProvider);
      final notifs = await repo.getNotifications(
        recipientUid: 'user_merchant_1',
      );
      state = state.copyWith(
        notifications: notifs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(garageRepositoryProvider);
    await repo.markNotificationAsRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(garageRepositoryProvider);
    for (final notif in state.notifications) {
      if (!notif.isRead) {
        await repo.markNotificationAsRead(notif.id);
      }
    }
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void toggleFilterUnread() {
    state = state.copyWith(filterOnlyUnread: !state.filterOnlyUnread);
  }
}

final merchantNotificationsViewModelProvider = NotifierProvider<
    MerchantNotificationsViewModel, MerchantNotificationsState>(
  MerchantNotificationsViewModel.new,
);
