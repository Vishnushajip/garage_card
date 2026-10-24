import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/payment_model.dart';

class MerchantInvoicesState {
  const MerchantInvoicesState({
    this.invoices = const [],
    this.payments = const [],
    this.isLoading = false,
    this.isRecordingPayment = false,
    this.errorMessage,
  });

  final List<InvoiceModel> invoices;
  final List<PaymentModel> payments;
  final bool isLoading;
  final bool isRecordingPayment;
  final String? errorMessage;

  MerchantInvoicesState copyWith({
    List<InvoiceModel>? invoices,
    List<PaymentModel>? payments,
    bool? isLoading,
    bool? isRecordingPayment,
    String? errorMessage,
  }) {
    return MerchantInvoicesState(
      invoices: invoices ?? this.invoices,
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      isRecordingPayment: isRecordingPayment ?? this.isRecordingPayment,
      errorMessage: errorMessage,
    );
  }
}
