import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_customers_state.dart';

class MerchantCustomersViewModel extends Notifier<MerchantCustomersState> {
  @override
  MerchantCustomersState build() {
    Future.microtask(_loadCustomers);
    return const MerchantCustomersState(isLoading: true);
  }

  Future<void> _loadCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getCustomers(garageId: 'garage_demo_1', search: state.searchQuery);
      state = state.copyWith(isLoading: false, customers: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _loadCustomers();
  }

  Future<bool> addCustomer({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String notes,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final cust = CustomerModel(
        id: '',
        garageId: 'garage_demo_1',
        name: name,
        phone: phone,
        email: email,
        address: address,
        notes: notes,
        createdAt: DateTime.now(),
      );
      final created = await ref
          .read(garageRepositoryProvider)
          .createCustomer(cust);
      state = state.copyWith(
        isSaving: false,
        customers: [created, ...state.customers],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadCustomers();
  }
}

final merchantCustomersViewModelProvider =
    NotifierProvider<MerchantCustomersViewModel, MerchantCustomersState>(
      MerchantCustomersViewModel.new,
    );
