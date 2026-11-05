import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/job_status_history_model.dart';
import 'package:garage_card/features/shared/models/mechanic_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class MerchantJobsState {
  const MerchantJobsState({
    this.jobs = const [],
    this.invoices = const [],
    this.customers = const [],
    this.mechanics = const [],
    this.selectedJob,
    this.selectedInvoice,
    this.history = const [],
    this.isLoading = false,
    this.isUpdatingStatus = false,
    this.isCreatingJob = false,
    this.isSavingInvoice = false,
    this.isRecordingPayment = false,
    this.isFetchingNextPage = false,
    this.isLoadingCustomers = false,
    this.isAddingCustomer = false,
    this.hasMoreCustomers = true,
    this.customerLastDoc,
    this.isLoadingMechanics = false,
    this.isAddingMechanic = false,
    this.hasMoreMechanics = true,
    this.mechanicLastDoc,
    this.hasMore = true,
    this.lastDocument,
    this.errorMessage,
    this.searchQuery = '',
    this.filterStatus,
    this.activeTabIndex = 0,
  });

  final List<ServiceJobModel> jobs;
  final List<InvoiceModel> invoices;
  final List<CustomerModel> customers;
  final List<MechanicModel> mechanics;
  final ServiceJobModel? selectedJob;
  final InvoiceModel? selectedInvoice;
  final List<JobStatusHistoryModel> history;
  final bool isLoading;
  final bool isUpdatingStatus;
  final bool isCreatingJob;
  final bool isSavingInvoice;
  final bool isRecordingPayment;
  final bool isFetchingNextPage;
  final bool isLoadingCustomers;
  final bool isAddingCustomer;
  final bool hasMoreCustomers;
  final Object? customerLastDoc;
  final bool isLoadingMechanics;
  final bool isAddingMechanic;
  final bool hasMoreMechanics;
  final Object? mechanicLastDoc;
  final bool hasMore;
  final Object? lastDocument;
  final String? errorMessage;
  final String searchQuery;
  final String? filterStatus;
  final int activeTabIndex;

  MerchantJobsState copyWith({
    List<ServiceJobModel>? jobs,
    List<InvoiceModel>? invoices,
    List<CustomerModel>? customers,
    List<MechanicModel>? mechanics,
    ServiceJobModel? selectedJob,
    InvoiceModel? selectedInvoice,
    List<JobStatusHistoryModel>? history,
    bool? isLoading,
    bool? isUpdatingStatus,
    bool? isCreatingJob,
    bool? isSavingInvoice,
    bool? isRecordingPayment,
    bool? isFetchingNextPage,
    bool? isLoadingCustomers,
    bool? isAddingCustomer,
    bool? hasMoreCustomers,
    Object? customerLastDoc,
    bool? isLoadingMechanics,
    bool? isAddingMechanic,
    bool? hasMoreMechanics,
    Object? mechanicLastDoc,
    bool? hasMore,
    Object? lastDocument,
    String? errorMessage,
    String? searchQuery,
    String? filterStatus,
    int? activeTabIndex,
  }) {
    return MerchantJobsState(
      jobs: jobs ?? this.jobs,
      invoices: invoices ?? this.invoices,
      customers: customers ?? this.customers,
      mechanics: mechanics ?? this.mechanics,
      selectedJob: selectedJob ?? this.selectedJob,
      selectedInvoice: selectedInvoice ?? this.selectedInvoice,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isCreatingJob: isCreatingJob ?? this.isCreatingJob,
      isSavingInvoice: isSavingInvoice ?? this.isSavingInvoice,
      isRecordingPayment: isRecordingPayment ?? this.isRecordingPayment,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      isLoadingCustomers: isLoadingCustomers ?? this.isLoadingCustomers,
      isAddingCustomer: isAddingCustomer ?? this.isAddingCustomer,
      hasMoreCustomers: hasMoreCustomers ?? this.hasMoreCustomers,
      customerLastDoc: customerLastDoc ?? this.customerLastDoc,
      isLoadingMechanics: isLoadingMechanics ?? this.isLoadingMechanics,
      isAddingMechanic: isAddingMechanic ?? this.isAddingMechanic,
      hasMoreMechanics: hasMoreMechanics ?? this.hasMoreMechanics,
      mechanicLastDoc: mechanicLastDoc ?? this.mechanicLastDoc,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }
}
