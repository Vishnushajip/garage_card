import 'package:garage_card/features/shared/models/service_reminder_model.dart';

class CustomerRemindersState {
  const CustomerRemindersState({
    this.reminders = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<ServiceReminderModel> reminders;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  CustomerRemindersState copyWith({
    List<ServiceReminderModel>? reminders,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return CustomerRemindersState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
