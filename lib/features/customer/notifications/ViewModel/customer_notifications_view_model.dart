import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import '../Model/customer_notifications_state.dart';

class CustomerNotificationsViewModel
    extends Notifier<CustomerNotificationsState> {
  @override
  CustomerNotificationsState build() {
    Future.microtask(_loadNotifications);
    return const CustomerNotificationsState(isLoading: true);
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getNotifications(recipientUid: 'customer_demo_uid');
      state = state.copyWith(isLoading: false, notifications: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    await ref.read(garageRepositoryProvider).markNotificationAsRead(id);
    await _loadNotifications();
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}

final customerNotificationsViewModelProvider = NotifierProvider<
    CustomerNotificationsViewModel, CustomerNotificationsState>(
  CustomerNotificationsViewModel.new,
);
