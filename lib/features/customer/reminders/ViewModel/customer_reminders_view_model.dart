import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/models/service_reminder_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_reminders_state.dart';

class CustomerRemindersViewModel extends Notifier<CustomerRemindersState> {
  @override
  CustomerRemindersState build() {
    Future.microtask(_loadReminders);
    return const CustomerRemindersState(isLoading: true);
  }

  Future<void> _loadReminders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getReminders(customerId: 'cust_demo_1');
      state = state.copyWith(isLoading: false, reminders: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> recordExternalService({
    required String vehicleId,
    required String vehicleDisplay,
    required String serviceType,
    required DateTime serviceDate,
    required int odometerReading,
    required String notes,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final nextDueDate = serviceDate.add(const Duration(days: 180));
      final nextDueMileage = odometerReading + 10000;

      final reminder = ServiceReminderModel(
        id: '',
        garageId: 'garage_demo_1',
        customerId: 'cust_demo_1',
        vehicleId: vehicleId,
        vehicleDisplay: vehicleDisplay,
        title: '$serviceType Next Interval',
        serviceType: serviceType,
        dueDate: nextDueDate,
        dueMileage: nextDueMileage,
        status: 'pending',
        isCustomerReported: true,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(garageRepositoryProvider)
          .createReminder(reminder);
      state = state.copyWith(
        isSaving: false,
        reminders: [created, ...state.reminders],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadReminders();
  }
}

final customerRemindersViewModelProvider =
    NotifierProvider<CustomerRemindersViewModel, CustomerRemindersState>(
      CustomerRemindersViewModel.new,
    );
