import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import '../Model/customer_invoices_state.dart';

class CustomerInvoicesViewModel extends Notifier<CustomerInvoicesState> {
  @override
  CustomerInvoicesState build() {
    Future.microtask(_loadData);
    return const CustomerInvoicesState(isLoading: true);
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final invoices = await repo.getInvoices(customerId: 'cust_demo_1');
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
