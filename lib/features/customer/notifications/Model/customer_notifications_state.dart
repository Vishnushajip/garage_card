import 'package:garage_card/features/shared/models/notification_model.dart';

class CustomerNotificationsState {
  const CustomerNotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterOnlyUnread = false,
  });

  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;
  final bool filterOnlyUnread;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filteredNotifications {
    if (filterOnlyUnread) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  CustomerNotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
    bool? filterOnlyUnread,
  }) {
    return CustomerNotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filterOnlyUnread: filterOnlyUnread ?? this.filterOnlyUnread,
    );
  }
}
