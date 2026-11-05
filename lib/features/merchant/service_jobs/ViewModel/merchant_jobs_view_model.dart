import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';
import 'package:garage_card/features/shared/models/mechanic_model.dart';
import 'package:garage_card/features/shared/models/payment_record_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/supplemental_work_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:uuid/uuid.dart';

import '../Model/merchant_jobs_state.dart';

class MerchantJobsViewModel extends Notifier<MerchantJobsState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return '';
  }

  @override
  MerchantJobsState build() {
    Future.microtask(_loadJobs);
    return const MerchantJobsState(isLoading: true);
  }

  Future<void> _loadJobs() async {
    final garageId = _effectiveGarageId();
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastDocument: null,
      hasMore: true,
    );
    try {
      final res = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(
            garageId: garageId,
            status: state.filterStatus,
            search: state.searchQuery,
            limit: 25,
          );

      final invoices = await ref
          .read(garageRepositoryProvider)
          .getInvoices(garageId: garageId, limit: 100);

      final customersRes = await ref
          .read(garageRepositoryProvider)
          .getCustomersPaginated(garageId: garageId, limit: 25);

      final mechanicsRes = await ref
          .read(garageRepositoryProvider)
          .getMechanicsPaginated(garageId: garageId, limit: 25);

      state = state.copyWith(
        isLoading: false,
        jobs: res.items,
        invoices: invoices,
        customers: customersRes.items,
        hasMoreCustomers: customersRes.hasMore,
        customerLastDoc: customersRes.lastDocument,
        mechanics: mechanicsRes.items,
        hasMoreMechanics: mechanicsRes.hasMore,
        mechanicLastDoc: mechanicsRes.lastDocument,
        hasMore: res.hasMore,
        lastDocument: res.lastDocument,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadCustomers({bool refresh = false, String? search}) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return;

    state = state.copyWith(
      isLoadingCustomers: true,
      customerLastDoc: refresh ? null : state.customerLastDoc,
      hasMoreCustomers: refresh ? true : state.hasMoreCustomers,
    );

    try {
      final res = await ref
          .read(garageRepositoryProvider)
          .getCustomersPaginated(
            garageId: garageId,
            search: search,
            limit: 25,
            lastDocument: refresh ? null : state.customerLastDoc,
          );
      state = state.copyWith(
        isLoadingCustomers: false,
        customers: refresh ? res.items : [...state.customers, ...res.items],
        hasMoreCustomers: res.hasMore,
        customerLastDoc: res.lastDocument,
      );
    } catch (_) {
      state = state.copyWith(isLoadingCustomers: false);
    }
  }

  Future<void> fetchNextCustomersPage({String? search}) async {
    if (state.isLoadingCustomers || !state.hasMoreCustomers) return;
    await loadCustomers(refresh: false, search: search);
  }

  Future<CustomerModel?> addCustomer({
    required String name,
    required String phone,
    String email = '',
    String address = '',
  }) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return null;

    state = state.copyWith(isAddingCustomer: true);
    try {
      final newCustomer = CustomerModel(
        id: const Uuid().v4(),
        garageId: garageId,
        name: name.trim(),
        phone: phone.trim(),
        whatsappNumber: phone.trim(),
        email: email.trim(),
        address: address.trim(),
        createdAt: DateTime.now(),
      );
      final saved = await ref
          .read(garageRepositoryProvider)
          .createCustomer(newCustomer);

      final updatedList = [
        saved,
        ...state.customers.where((c) => c.id != saved.id),
      ];

      state = state.copyWith(isAddingCustomer: false, customers: updatedList);
      return saved;
    } catch (_) {
      state = state.copyWith(isAddingCustomer: false);
      return null;
    }
  }

  Future<void> loadMechanics({bool refresh = false}) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return;

    state = state.copyWith(
      isLoadingMechanics: true,
      mechanicLastDoc: refresh ? null : state.mechanicLastDoc,
      hasMoreMechanics: refresh ? true : state.hasMoreMechanics,
    );

    try {
      final res = await ref
          .read(garageRepositoryProvider)
          .getMechanicsPaginated(
            garageId: garageId,
            limit: 25,
            lastDocument: refresh ? null : state.mechanicLastDoc,
          );
      state = state.copyWith(
        isLoadingMechanics: false,
        mechanics: refresh ? res.items : [...state.mechanics, ...res.items],
        hasMoreMechanics: res.hasMore,
        mechanicLastDoc: res.lastDocument,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMechanics: false);
    }
  }

  Future<void> fetchNextMechanicsPage() async {
    if (state.isLoadingMechanics || !state.hasMoreMechanics) return;
    await loadMechanics(refresh: false);
  }

  Future<MechanicModel?> addMechanic({
    required String name,
    String phone = '',
    String specialization = '',
  }) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return null;

    state = state.copyWith(isAddingMechanic: true);
    try {
      final newMechanic = MechanicModel(
        id: const Uuid().v4(),
        garageId: garageId,
        name: name.trim(),
        phone: phone.trim(),
        specialization: specialization.trim(),
        isActive: true,
        createdAt: DateTime.now(),
      );
      final saved = await ref
          .read(garageRepositoryProvider)
          .createMechanic(newMechanic);

      final updated = [
        saved,
        ...state.mechanics.where((m) => m.id != saved.id),
      ];

      state = state.copyWith(isAddingMechanic: false, mechanics: updated);
      return saved;
    } catch (_) {
      state = state.copyWith(isAddingMechanic: false);
      return null;
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isFetchingNextPage || !state.hasMore || state.isLoading) {
      return;
    }
    state = state.copyWith(isFetchingNextPage: true);
    try {
      final res = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(
            garageId: _effectiveGarageId(),
            status: state.filterStatus,
            search: state.searchQuery,
            limit: 25,
            lastDocument: state.lastDocument,
          );
      state = state.copyWith(
        isFetchingNextPage: false,
        jobs: [...state.jobs, ...res.items],
        hasMore: res.hasMore,
        lastDocument: res.lastDocument,
      );
    } catch (_) {
      state = state.copyWith(isFetchingNextPage: false);
    }
  }

  Future<void> selectJob(String jobId) async {
    state = state.copyWith(isLoading: true);
    try {
      final garageId = _effectiveGarageId();
      final jobs = await ref
          .read(garageRepositoryProvider)
          .getServiceJobs(garageId: garageId, limit: 100);
      final job = jobs.cast<ServiceJobModel?>().firstWhere(
        (j) => j?.id == jobId,
        orElse: () => null,
      );
      final history = await ref
          .read(garageRepositoryProvider)
          .getJobHistory(jobId);

      final invoice = await ref
          .read(garageRepositoryProvider)
          .getInvoiceByJobId(garageId, jobId);

      state = state.copyWith(
        isLoading: false,
        selectedJob: job,
        selectedInvoice: invoice,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createJob({
    required String customerName,
    String? customerPhone,
    required String bikeNumber,
    String? bikeModel,
    required String problem,
    required String mechanicName,
    String? customerId,
  }) async {
    state = state.copyWith(isCreatingJob: true, errorMessage: null);
    try {
      final garageId = _effectiveGarageId();
      String effectiveCustId = customerId ?? '';

      if (effectiveCustId.isEmpty) {
        final existing = state.customers.where(
          (c) =>
              c.name.toLowerCase() == customerName.toLowerCase() ||
              (customerPhone != null &&
                  customerPhone.isNotEmpty &&
                  c.phone.replaceAll(RegExp(r'\D'), '') ==
                      customerPhone.replaceAll(RegExp(r'\D'), '')),
        );
        if (existing.isNotEmpty) {
          effectiveCustId = existing.first.id;
        } else {
          final newCust = CustomerModel(
            id: const Uuid().v4(),
            garageId: garageId,
            name: customerName,
            phone: customerPhone ?? '',
            whatsappNumber: customerPhone ?? '',
            createdAt: DateTime.now(),
          );
          final savedCust = await ref
              .read(garageRepositoryProvider)
              .createCustomer(newCust);
          effectiveCustId = savedCust.id;
        }
      }

      final vehicleDisplay = (bikeModel != null && bikeModel.trim().isNotEmpty)
          ? '${bikeModel.trim()} (${bikeNumber.trim()})'
          : bikeNumber.trim();

      final newJob = ServiceJobModel(
        id: const Uuid().v4(),
        garageId: garageId,
        customerId: effectiveCustId,
        vehicleId: '',
        jobNumber:
            'JOB-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}',
        status: 'pending',
        odometerReading: 0,
        complaints: [problem.trim()],
        technicianName: mechanicName.trim(),
        customerName: customerName.trim(),
        customerPhone: customerPhone?.trim() ?? '',
        customerWhatsApp: customerPhone?.trim() ?? '',
        vehicleDisplay: vehicleDisplay,
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(garageRepositoryProvider)
          .createServiceJob(newJob);

      if (mechanicName.trim().isNotEmpty) {
        final exists = state.mechanics.any(
          (m) =>
              m.name.trim().toLowerCase() == mechanicName.trim().toLowerCase(),
        );
        if (!exists) {
          final newMech = MechanicModel(
            id: const Uuid().v4(),
            garageId: garageId,
            name: mechanicName.trim(),
            isActive: true,
            createdAt: DateTime.now(),
          );
          await ref.read(garageRepositoryProvider).createMechanic(newMech);
        }
      }

      state = state.copyWith(
        isCreatingJob: false,
        jobs: [created, ...state.jobs],
      );

      await _loadJobs();
      return true;
    } catch (e) {
      state = state.copyWith(isCreatingJob: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateStatus({
    required String jobId,
    required String newStatus,
    required String notes,
  }) async {
    state = state.copyWith(isUpdatingStatus: true, errorMessage: null);
    try {
      await ref
          .read(garageRepositoryProvider)
          .updateJobStatus(
            jobId: jobId,
            newStatus: newStatus,
            notes: notes,
            updatedBy: 'Staff',
          );
      await selectJob(jobId);
      await _loadJobs();
      state = state.copyWith(isUpdatingStatus: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> assignMechanic({
    required String jobId,
    required String mechanicName,
  }) async {
    state = state.copyWith(isUpdatingStatus: true, errorMessage: null);
    try {
      final garageId = _effectiveGarageId();
      if (mechanicName.trim().isNotEmpty) {
        final exists = state.mechanics.any(
          (m) =>
              m.name.trim().toLowerCase() == mechanicName.trim().toLowerCase(),
        );
        if (!exists) {
          final newMech = MechanicModel(
            id: const Uuid().v4(),
            garageId: garageId,
            name: mechanicName.trim(),
            isActive: true,
            createdAt: DateTime.now(),
          );
          await ref.read(garageRepositoryProvider).createMechanic(newMech);
        }
      }
      await ref
          .read(garageRepositoryProvider)
          .startRepair(
            garageId: garageId,
            jobId: jobId,
            startedByUid: 'Staff',
            technicianName: mechanicName,
            notes: 'Mechanic assigned: $mechanicName',
          );
      await selectJob(jobId);
      await _loadJobs();
      state = state.copyWith(isUpdatingStatus: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> addExtraWork({
    required String jobId,
    required String title,
    required double charge,
    String? description,
  }) async {
    try {
      final garageId = _effectiveGarageId();
      final item = SupplementalWorkItem(
        id: const Uuid().v4(),
        jobId: jobId,
        title: title.trim(),
        reason: (description != null && description.trim().isNotEmpty)
            ? description.trim()
            : title.trim(),
        partsCost: charge,
        laborCost: 0.0,
        status: 'approved',
        createdAt: DateTime.now(),
      );

      await ref
          .read(garageRepositoryProvider)
          .addSupplementalWork(garageId, jobId, item);

      await selectJob(jobId);
      await _loadJobs();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> completeJobWithBilling({
    required String jobId,
    required double laborCharges,
    required List<LineItemModel> parts,
    required double extraWorkCharges,
    required double discountAmount,
    required double paidAmount,
    required String paymentMethod,
    String? paymentNotes,
  }) async {
    state = state.copyWith(isSavingInvoice: true, errorMessage: null);
    try {
      final garageId = _effectiveGarageId();
      final targetJob = state.jobs.cast<ServiceJobModel?>().firstWhere(
        (j) => j?.id == jobId,
        orElse: () => state.selectedJob,
      );

      if (targetJob == null) {
        throw Exception('Job not found');
      }

      final partsTotal = parts.fold<double>(
        0.0,
        (acc, item) => acc + item.totalPrice,
      );
      final subtotal = partsTotal + laborCharges + extraWorkCharges;
      final finalAmount = (subtotal - discountAmount).clamp(
        0.0,
        double.infinity,
      );

      if (finalAmount <= 0.0) {
        throw Exception('Final bill amount must be greater than zero');
      }

      final balanceDue = (finalAmount - paidAmount).clamp(0.0, double.infinity);
      final paymentStatus = balanceDue <= 0.0
          ? 'paid'
          : (paidAmount > 0.0 ? 'partially_paid' : 'unpaid');

      final lineItems = <LineItemModel>[];
      lineItems.addAll(parts);

      if (laborCharges > 0.0) {
        lineItems.add(
          LineItemModel(
            id: const Uuid().v4(),
            description: 'Labour Charges',
            type: 'labor',
            quantity: 1,
            unitPrice: laborCharges,
          ),
        );
      }

      if (extraWorkCharges > 0.0) {
        lineItems.add(
          LineItemModel(
            id: const Uuid().v4(),
            description: 'Extra Work Charges',
            type: 'extra',
            quantity: 1,
            unitPrice: extraWorkCharges,
          ),
        );
      }

      final invoiceId = const Uuid().v4();
      final paymentRecords = <PaymentRecordModel>[];
      if (paidAmount > 0.0) {
        paymentRecords.add(
          PaymentRecordModel(
            id: const Uuid().v4(),
            invoiceId: invoiceId,
            amount: paidAmount,
            method: paymentMethod,
            recordedAt: DateTime.now(),
            notes: paymentNotes ?? 'Initial payment at completion',
          ),
        );
      }

      final invoice = InvoiceModel(
        id: invoiceId,
        garageId: garageId,
        jobId: jobId,
        customerId: targetJob.customerId,
        invoiceNumber:
            'INV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 100000}',
        items: lineItems,
        subtotal: subtotal,
        discountAmount: discountAmount,
        totalAmount: finalAmount,
        paidAmount: paidAmount,
        balanceDue: balanceDue,
        status: paymentStatus,
        paymentRecords: paymentRecords,
        issuedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(garageRepositoryProvider).createInvoice(invoice);

      await ref
          .read(garageRepositoryProvider)
          .completeRepair(
            garageId: garageId,
            jobId: jobId,
            completedByUid: 'Staff',
            notes: 'Completed with bill ${invoice.invoiceNumber}',
          );

      await selectJob(jobId);
      await _loadJobs();
      state = state.copyWith(isSavingInvoice: false);
      return true;
    } catch (e) {
      debugPrint('COMPLETE_JOB_BILLING_ERROR: $e');
      state = state.copyWith(
        isSavingInvoice: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateInvoice(InvoiceModel invoice) async {
    state = state.copyWith(isSavingInvoice: true, errorMessage: null);
    try {
      await ref.read(garageRepositoryProvider).updateInvoice(invoice);
      await selectJob(invoice.jobId);
      await _loadJobs();
      state = state.copyWith(isSavingInvoice: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSavingInvoice: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    String? reference,
    String? notes,
  }) async {
    state = state.copyWith(isRecordingPayment: true, errorMessage: null);
    try {
      await ref
          .read(garageRepositoryProvider)
          .recordPayment(
            invoiceId: invoiceId,
            amount: amount,
            paymentMethod: paymentMethod,
            referenceNumber: reference ?? '',
            notes: notes ?? '',
            recordedByUid: 'Staff',
          );
      if (state.selectedJob != null) {
        await selectJob(state.selectedJob!.id);
      }
      await _loadJobs();
      state = state.copyWith(isRecordingPayment: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isRecordingPayment: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _loadJobs();
  }

  void setActiveTab(int tabIndex) {
    String? filter;
    if (tabIndex == 1) {
      filter = 'pending';
    } else if (tabIndex == 2) {
      filter = 'in_progress';
    } else if (tabIndex == 3) {
      filter = 'completed';
    }
    state = state.copyWith(activeTabIndex: tabIndex, filterStatus: filter);
    _loadJobs();
  }

  Future<void> refresh() async {
    await _loadJobs();
    if (state.selectedJob != null) {
      await selectJob(state.selectedJob!.id);
    }
  }
}

final merchantJobsViewModelProvider =
    NotifierProvider<MerchantJobsViewModel, MerchantJobsState>(
      MerchantJobsViewModel.new,
    );
