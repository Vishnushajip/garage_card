import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:garage_card/features/support/models/support_ticket_model.dart';
import 'package:garage_card/features/support/repositories/support_repository.dart';

class CreateTicketState {
  const CreateTicketState({
    this.isLoadingContext = false,
    this.isSubmitting = false,
    this.vehicles = const [],
    this.jobs = const [],
    this.invoices = const [],
    this.garages = const [],
    this.selectedVehicle,
    this.selectedJob,
    this.selectedInvoice,
    this.selectedGarage,
    this.category = 'vehicle_issue',
    this.priority = 'medium',
    this.preferredContact = 'in_app',
    this.createdTicket,
    this.errorMessage,
  });

  final bool isLoadingContext;
  final bool isSubmitting;
  final List<VehicleModel> vehicles;
  final List<ServiceJobModel> jobs;
  final List<InvoiceModel> invoices;
  final List<GarageModel> garages;
  final VehicleModel? selectedVehicle;
  final ServiceJobModel? selectedJob;
  final InvoiceModel? selectedInvoice;
  final GarageModel? selectedGarage;
  final String category;
  final String priority;
  final String preferredContact;
  final SupportTicketModel? createdTicket;
  final String? errorMessage;

  CreateTicketState copyWith({
    bool? isLoadingContext,
    bool? isSubmitting,
    List<VehicleModel>? vehicles,
    List<ServiceJobModel>? jobs,
    List<InvoiceModel>? invoices,
    List<GarageModel>? garages,
    VehicleModel? selectedVehicle,
    ServiceJobModel? selectedJob,
    InvoiceModel? selectedInvoice,
    GarageModel? selectedGarage,
    String? category,
    String? priority,
    String? preferredContact,
    SupportTicketModel? createdTicket,
    String? errorMessage,
  }) {
    return CreateTicketState(
      isLoadingContext: isLoadingContext ?? this.isLoadingContext,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      vehicles: vehicles ?? this.vehicles,
      jobs: jobs ?? this.jobs,
      invoices: invoices ?? this.invoices,
      garages: garages ?? this.garages,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedInvoice: selectedInvoice ?? this.selectedInvoice,
      selectedGarage: selectedGarage ?? this.selectedGarage,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      preferredContact: preferredContact ?? this.preferredContact,
      createdTicket: createdTicket ?? this.createdTicket,
      errorMessage: errorMessage,
    );
  }
}

class CreateTicketViewModel extends Notifier<CreateTicketState> {
  @override
  CreateTicketState build() {
    Future.microtask(loadCustomerContext);
    return const CreateTicketState(isLoadingContext: true);
  }

  GarageRepository get _garageRepo => ref.read(garageRepositoryProvider);
  SupportRepository get _supportRepo => ref.read(supportRepositoryProvider);

  Future<void> loadCustomerContext({
    String? preselectedJobId,
    String? preselectedGarageId,
    String? preselectedVehicleId,
    String? preselectedInvoiceId,
  }) async {
    final user = ref.read(authViewModelProvider).userProfile;
    final customerId = user?.uid ?? '';
    if (customerId.isEmpty) {
      state = state.copyWith(isLoadingContext: false);
      return;
    }

    state = state.copyWith(isLoadingContext: true, errorMessage: null);

    try {
      final vehicles = await _garageRepo.getVehicles(customerId: customerId);
      final jobs = await _garageRepo.getServiceJobs(customerId: customerId);
      final invoices = await _garageRepo.getInvoices(customerId: customerId);
      final garages = await _garageRepo.getNearbyGarages(
        latitude: 0,
        longitude: 0,
      );

      VehicleModel? matchedVehicle;
      if (preselectedVehicleId != null) {
        matchedVehicle = vehicles
            .where((v) => v.id == preselectedVehicleId)
            .firstOrNull;
      }

      ServiceJobModel? matchedJob;
      if (preselectedJobId != null) {
        matchedJob = jobs.where((j) => j.id == preselectedJobId).firstOrNull;
      }

      InvoiceModel? matchedInvoice;
      if (preselectedInvoiceId != null) {
        matchedInvoice = invoices
            .where((i) => i.id == preselectedInvoiceId)
            .firstOrNull;
      }

      GarageModel? matchedGarage;
      if (matchedJob != null) {
        matchedGarage = garages
            .where((g) => g.id == matchedJob?.garageId)
            .firstOrNull;
      } else if (matchedInvoice != null) {
        matchedGarage = garages
            .where((g) => g.id == matchedInvoice?.garageId)
            .firstOrNull;
      } else if (preselectedGarageId != null) {
        matchedGarage = garages
            .where((g) => g.id == preselectedGarageId)
            .firstOrNull;
      }

      state = state.copyWith(
        isLoadingContext: false,
        vehicles: vehicles,
        jobs: jobs,
        invoices: invoices,
        garages: garages,
        selectedVehicle:
            matchedVehicle ?? (vehicles.isNotEmpty ? vehicles.first : null),
        selectedJob: matchedJob,
        selectedInvoice: matchedInvoice,
        selectedGarage: matchedGarage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingContext: false,
        errorMessage: 'Failed to load customer profile details.',
      );
    }
  }

  void selectJob(ServiceJobModel? job) {
    if (job == null) {
      state = state.copyWith(selectedJob: null);
      return;
    }
    final garage = state.garages.where((g) => g.id == job.garageId).firstOrNull;
    final vehicle = state.vehicles
        .where((v) => v.id == job.vehicleId)
        .firstOrNull;

    state = state.copyWith(
      selectedJob: job,
      selectedGarage: garage ?? state.selectedGarage,
      selectedVehicle: vehicle ?? state.selectedVehicle,
    );
  }

  void selectInvoice(InvoiceModel? invoice) {
    if (invoice == null) {
      state = state.copyWith(selectedInvoice: null);
      return;
    }
    final garage = state.garages
        .where((g) => g.id == invoice.garageId)
        .firstOrNull;
    state = state.copyWith(
      selectedInvoice: invoice,
      selectedGarage: garage ?? state.selectedGarage,
    );
  }

  void selectVehicle(VehicleModel? vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
  }

  void selectGarage(GarageModel? garage) {
    state = state.copyWith(selectedGarage: garage);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setPriority(String priority) {
    state = state.copyWith(priority: priority);
  }

  void setPreferredContact(String contact) {
    state = state.copyWith(preferredContact: contact);
  }

  Future<bool> submitTicket({
    required String subject,
    required String description,
    List<String> attachments = const [],
  }) async {
    final user = ref.read(authViewModelProvider).userProfile;
    final customerId = user?.uid ?? '';
    final customerName = user?.fullName ?? 'Customer';
    final customerPhone = user?.phoneNumber ?? '';

    if (subject.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a ticket subject.');
      return false;
    }
    if (description.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please provide issue details.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final vehicle = state.selectedVehicle;
      final job = state.selectedJob;
      final invoice = state.selectedInvoice;
      final garage = state.selectedGarage;

      final ticket = SupportTicketModel(
        id: '',
        ticketNumber: '',
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        merchantId: garage?.ownerUid ?? '',
        garageId: garage?.id ?? '',
        garageName: garage?.name ?? 'General Support',
        vehicleId: vehicle?.id,
        vehicleDisplay: vehicle != null
            ? '${vehicle.make} ${vehicle.model} (${vehicle.licensePlate})'
            : null,
        vehiclePlate: vehicle?.licensePlate,
        jobId: job?.id,
        jobNumber: job?.jobNumber,
        invoiceId: invoice?.id,
        invoiceNumber: invoice?.invoiceNumber,
        category: state.category,
        subject: subject.trim(),
        description: description.trim(),
        priority: state.priority,
        preferredContact: state.preferredContact,
        attachments: attachments,
      );

      final created = await _supportRepo.createTicket(ticket);
      state = state.copyWith(isSubmitting: false, createdTicket: created);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create support ticket. Please retry.',
      );
      return false;
    }
  }
}

final createTicketViewModelProvider =
    NotifierProvider<CreateTicketViewModel, CreateTicketState>(
      CreateTicketViewModel.new,
    );
