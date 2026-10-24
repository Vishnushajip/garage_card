import 'package:garage_card/features/shared/models/notification_model.dart';

class CustomerNotificationsState {
  const CustomerNotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  CustomerNotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerNotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
