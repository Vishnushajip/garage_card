import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/models/appointment_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import '../Model/customer_appointment_state.dart';

class CustomerAppointmentViewModel
    extends Notifier<CustomerAppointmentState> {
  @override
  CustomerAppointmentState build() {
    _loadAppointments();
    return const CustomerAppointmentState(isLoading: true);
  }

  Future<void> _loadAppointments() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getAppointments(customerId: 'cust_demo_1');
      state = state.copyWith(isLoading: false, appointments: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> submitAppointmentRequest({
    required String garageId,
    required String customerName,
    required String customerPhone,
    required String vehicleInfo,
    required DateTime preferredDate,
    required String preferredTime,
    required String issueDescription,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final appt = AppointmentModel(
        id: '',
        garageId: garageId,
        customerId: 'cust_demo_1',
        customerName: customerName,
        customerPhone: customerPhone,
        vehicleInfo: vehicleInfo,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        issueDescription: issueDescription,
        status: 'submitted',
        createdAt: DateTime.now(),
      );

      final created =
          await ref.read(garageRepositoryProvider).createAppointment(appt);
      state = state.copyWith(
        isSubmitting: false,
        appointments: [created, ...state.appointments],
        successMessage: 'Appointment request submitted successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadAppointments();
  }
}

final customerAppointmentViewModelProvider = NotifierProvider<
    CustomerAppointmentViewModel, CustomerAppointmentState>(
  CustomerAppointmentViewModel.new,
);
