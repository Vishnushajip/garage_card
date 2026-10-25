import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_invoices_state.dart';

class CustomerInvoicesViewModel extends Notifier<CustomerInvoicesState> {
  @override
  CustomerInvoicesState build() {
    Future.microtask(_loadData);
    return const CustomerInvoicesState(isLoading: true);
  }

  String? get _currentCustomerId {
    final profile = ref.read(authViewModelProvider).userProfile;
    if (profile != null && profile.uid.isNotEmpty) {
      return profile.uid;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final uid = _currentCustomerId;
      final invoices = uid != null
          ? await repo.getInvoices(customerId: uid)
          : <InvoiceModel>[];
      final payments = await repo.getPayments(garageId: 'garage_demo_1');

      state = state.copyWith(
        isLoading: false,
        invoices: invoices,
        payments: payments,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }
}

final customerInvoicesViewModelProvider =
    NotifierProvider<CustomerInvoicesViewModel, CustomerInvoicesState>(
      CustomerInvoicesViewModel.new,
    );
