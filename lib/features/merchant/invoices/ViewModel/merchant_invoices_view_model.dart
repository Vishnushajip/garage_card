import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_invoices_state.dart';

class MerchantInvoicesViewModel extends Notifier<MerchantInvoicesState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return 'garage_demo_1';
  }

  @override
  MerchantInvoicesState build() {
    Future.microtask(_loadInvoices);
    return const MerchantInvoicesState(isLoading: true);
  }

  Future<void> _loadInvoices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final garageId = _effectiveGarageId();
      final invoices = await repo.getInvoices(garageId: garageId);
      final payments = await repo.getPayments(garageId: garageId);

      state = state.copyWith(
        isLoading: false,
        invoices: invoices,
        payments: payments,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    required String referenceNumber,
    required String notes,
    double discountAdjustment = 0.0,
  }) async {
    state = state.copyWith(isRecordingPayment: true, errorMessage: null);
    try {
      final user = ref.read(authViewModelProvider).userProfile;
      await ref
          .read(garageRepositoryProvider)
          .recordPayment(
            invoiceId: invoiceId,
            amount: amount,
            paymentMethod: paymentMethod,
            referenceNumber: referenceNumber,
            notes: notes,
            recordedByUid: user?.uid ?? 'merchant_1',
            discountAdjustment: discountAdjustment,
          );
      await _loadInvoices();
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

  Future<void> refresh() async {
    await _loadInvoices();
  }
}

final merchantInvoicesViewModelProvider =
    NotifierProvider<MerchantInvoicesViewModel, MerchantInvoicesState>(
      MerchantInvoicesViewModel.new,
    );
