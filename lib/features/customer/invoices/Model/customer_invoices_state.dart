import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/payment_model.dart';

class CustomerInvoicesState {
  const CustomerInvoicesState({
    this.invoices = const [],
    this.payments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<InvoiceModel> invoices;
  final List<PaymentModel> payments;
  final bool isLoading;
  final String? errorMessage;

  CustomerInvoicesState copyWith({
    List<InvoiceModel>? invoices,
    List<PaymentModel>? payments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerInvoicesState(
      invoices: invoices ?? this.invoices,
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
