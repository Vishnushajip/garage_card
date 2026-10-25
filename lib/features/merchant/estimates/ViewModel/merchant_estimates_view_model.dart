import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_estimates_state.dart';

class MerchantEstimatesViewModel extends Notifier<MerchantEstimatesState> {
  @override
  MerchantEstimatesState build() {
    Future.microtask(_loadEstimates);
    return const MerchantEstimatesState(isLoading: true);
  }

  Future<void> _loadEstimates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ref
          .read(garageRepositoryProvider)
          .getEstimates(garageId: 'garage_demo_1');
      state = state.copyWith(isLoading: false, estimates: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createEstimate({
    required String estimateNumber,
    required List<LineItemModel> items,
    required double taxRate,
    required double discountAmount,
  }) async {
    state = state.copyWith(isCreating: true, errorMessage: null);
    try {
      final subtotal = items.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final taxAmount = (subtotal - discountAmount) * (taxRate / 100);
      final total = (subtotal - discountAmount + taxAmount).clamp(
        0.0,
        double.infinity,
      );

      final est = EstimateModel(
        id: '',
        garageId: 'garage_demo_1',
        jobId: 'job_demo_1',
        customerId: 'cust_demo_1',
        estimateNumber: estimateNumber,
        items: items,
        subtotal: subtotal,
        taxRate: taxRate,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        totalAmount: total,
        status: 'sent',
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(garageRepositoryProvider)
          .createEstimate(est);
      state = state.copyWith(
        isCreating: false,
        estimates: [created, ...state.estimates],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> convertToInvoice(EstimateModel estimate) async {
    state = state.copyWith(isConverting: true, errorMessage: null);
    try {
      await ref
          .read(garageRepositoryProvider)
          .createInvoiceFromEstimate(estimate);
      state = state.copyWith(isConverting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isConverting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadEstimates();
  }
}

final merchantEstimatesViewModelProvider =
    NotifierProvider<MerchantEstimatesViewModel, MerchantEstimatesState>(
      MerchantEstimatesViewModel.new,
    );
