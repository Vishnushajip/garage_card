import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import '../Model/customer_estimates_state.dart';

class CustomerEstimatesViewModel extends Notifier<CustomerEstimatesState> {
  @override
  CustomerEstimatesState build() {
    Future.microtask(_loadEstimates);
    return const CustomerEstimatesState(isLoading: true);
  }

  Future<void> _loadEstimates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getEstimates(customerId: 'cust_demo_1');
      state = state.copyWith(isLoading: false, estimates: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> approveEstimate(String estimateId) async {
    state = state.copyWith(isActionInProgress: true, errorMessage: null);
    try {
      final success = await ref
          .read(garageRepositoryProvider)
          .approveEstimate(estimateId);
      if (success) {
        await _loadEstimates();
      }
      state = state.copyWith(isActionInProgress: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> rejectEstimate(String estimateId, String reason) async {
    state = state.copyWith(isActionInProgress: true, errorMessage: null);
    try {
      final success = await ref
          .read(garageRepositoryProvider)
          .rejectEstimate(estimateId, reason);
      if (success) {
        await _loadEstimates();
      }
      state = state.copyWith(isActionInProgress: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadEstimates();
  }
}

final customerEstimatesViewModelProvider =
    NotifierProvider<CustomerEstimatesViewModel, CustomerEstimatesState>(
  CustomerEstimatesViewModel.new,
);
