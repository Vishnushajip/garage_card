import 'package:garage_card/features/shared/models/appointment_model.dart';

class CustomerAppointmentState {
  const CustomerAppointmentState({
    this.appointments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<AppointmentModel> appointments;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  CustomerAppointmentState copyWith({
    List<AppointmentModel>? appointments,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return CustomerAppointmentState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
