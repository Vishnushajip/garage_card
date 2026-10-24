import 'package:garage_card/features/shared/models/customer_model.dart';

class MerchantCustomersState {
  const MerchantCustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  final List<CustomerModel> customers;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String searchQuery;

  MerchantCustomersState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? searchQuery,
  }) {
    return MerchantCustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
