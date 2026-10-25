import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/appointment_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_appointment_state.dart';

class CustomerAppointmentViewModel extends Notifier<CustomerAppointmentState> {
  @override
  CustomerAppointmentState build() {
    _loadAppointments();
    return const CustomerAppointmentState(isLoading: true);
  }

  String? get _currentCustomerId {
    final profile = ref.read(authViewModelProvider).userProfile;
    if (profile != null && profile.uid.isNotEmpty) {
      return profile.uid;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadAppointments() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final uid = _currentCustomerId;
      if (uid == null) {
        state = state.copyWith(isLoading: false, appointments: []);
        return;
      }
      final list = await ref
          .read(garageRepositoryProvider)
          .getAppointments(customerId: uid);
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
      final uid = _currentCustomerId ?? '';
      final appt = AppointmentModel(
        id: '',
        garageId: garageId,
        customerId: uid,
        customerName: customerName,
        customerPhone: customerPhone,
        vehicleInfo: vehicleInfo,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        issueDescription: issueDescription,
        status: 'submitted',
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(garageRepositoryProvider)
          .createAppointment(appt);
      state = state.copyWith(
        isSubmitting: false,
        appointments: [created, ...state.appointments],
        successMessage: 'Appointment request submitted successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadAppointments();
  }
}

final customerAppointmentViewModelProvider =
    NotifierProvider<CustomerAppointmentViewModel, CustomerAppointmentState>(
      CustomerAppointmentViewModel.new,
    );
