import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/service_reminder_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';

class CustomerDashboardState {
  const CustomerDashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.activeJobs = const [],
    this.vehicles = const [],
    this.pendingEstimates = const [],
    this.unpaidInvoices = const [],
    this.upcomingReminders = const [],
    this.nearbyGarages = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<ServiceJobModel> activeJobs;
  final List<VehicleModel> vehicles;
  final List<EstimateModel> pendingEstimates;
  final List<InvoiceModel> unpaidInvoices;
  final List<ServiceReminderModel> upcomingReminders;
  final List<GarageModel> nearbyGarages;

  CustomerDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ServiceJobModel>? activeJobs,
    List<VehicleModel>? vehicles,
    List<EstimateModel>? pendingEstimates,
    List<InvoiceModel>? unpaidInvoices,
    List<ServiceReminderModel>? upcomingReminders,
    List<GarageModel>? nearbyGarages,
  }) {
    return CustomerDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeJobs: activeJobs ?? this.activeJobs,
      vehicles: vehicles ?? this.vehicles,
      pendingEstimates: pendingEstimates ?? this.pendingEstimates,
      unpaidInvoices: unpaidInvoices ?? this.unpaidInvoices,
      upcomingReminders: upcomingReminders ?? this.upcomingReminders,
      nearbyGarages: nearbyGarages ?? this.nearbyGarages,
    );
  }
}
