import 'package:garage_card/features/shared/models/notification_model.dart';

class CustomerNotificationsState {
  const CustomerNotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.isFetchingNextPage = false,
    this.hasMore = false,
    this.lastDocument,
    this.selectedIds = const {},
    this.isDeleting = false,
    this.errorMessage,
    this.filterOnlyUnread = false,
  });

  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool isFetchingNextPage;
  final bool hasMore;
  final Object? lastDocument;
  final Set<String> selectedIds;
  final bool isDeleting;
  final String? errorMessage;
  final bool filterOnlyUnread;

  bool get isSelectionMode => selectedIds.isNotEmpty;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filteredNotifications {
    if (filterOnlyUnread) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  bool isSelected(String id) => selectedIds.contains(id);

  bool get areAllSelected =>
      filteredNotifications.isNotEmpty &&
      filteredNotifications.every((n) => selectedIds.contains(n.id));

  CustomerNotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? isFetchingNextPage,
    bool? hasMore,
    Object? lastDocument,
    Set<String>? selectedIds,
    bool? isDeleting,
    String? errorMessage,
    bool? filterOnlyUnread,
  }) {
    return CustomerNotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      selectedIds: selectedIds ?? this.selectedIds,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
      filterOnlyUnread: filterOnlyUnread ?? this.filterOnlyUnread,
    );
  }
}
