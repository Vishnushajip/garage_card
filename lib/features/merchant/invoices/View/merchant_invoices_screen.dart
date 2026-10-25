import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import '../ViewModel/merchant_invoices_view_model.dart';
import '../Widgets/record_payment_dialog.dart';

class MerchantInvoicesScreen extends ConsumerWidget {
  const MerchantInvoicesScreen({super.key});

  void _showRecordPaymentDialog(
      BuildContext context, WidgetRef ref, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return RecordPaymentDialog(
          invoice: invoice,
          onRecord: ({
            required double amount,
            required String paymentMethod,
            required String referenceNumber,
            required String notes,
            double discountAdjustment = 0.0,
          }) {
            return ref
                .read(merchantInvoicesViewModelProvider.notifier)
                .recordPayment(
                  invoiceId: invoice.id,
                  amount: amount,
                  paymentMethod: paymentMethod,
                  referenceNumber: referenceNumber,
                  notes: notes,
                  discountAdjustment: discountAdjustment,
                );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantInvoicesViewModelProvider);
    final vm = ref.read(merchantInvoicesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Billing & Payments',
            style: AppFonts.titleLarge(color: primaryTextColor),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Invoices'),
              Tab(text: 'Payment Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AppRefresh(
              onRefresh: vm.refresh,
              child: AppResponsiveLayout(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading) {
                      return const AppLoading(message: 'Loading invoices...');
                    }
                    if (state.errorMessage != null && state.invoices.isEmpty) {
                      return AppErrorState(
                        message: state.errorMessage!,
                        onRetry: vm.refresh,
                      );
                    }
                    if (state.invoices.isEmpty) {
                      return const AppEmptyState(
                        title: 'No Invoices Yet',
                        message: 'Invoices converted from estimates will appear here.',
                        icon: Icons.receipt_long_outlined,
                      );
                    }

                    return ListView.builder(
                      itemCount: state.invoices.length,
                      itemBuilder: (ctx, index) {
                        final invoice = state.invoices[index];
                        return Card(
                          color: cardBg,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          invoice.invoiceNumber,
                                          style: AppFonts.titleLarge(
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          'Issued on ${DateFormatter.formatDate(invoice.issuedAt ?? invoice.createdAt)}',
                                          style: AppFonts.labelSmall(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppStatusBadge(status: invoice.status),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Amount',
                                          style: AppFonts.labelSmall(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(
                                              invoice.totalAmount,
                                              currencyCode:
                                                  invoice.currencyCode),
                                          style: AppFonts.titleMedium(
                                            color: primaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Balance Due',
                                          style: AppFonts.labelSmall(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(
                                              invoice.balanceDue,
                                              currencyCode:
                                                  invoice.currencyCode),
                                          style: AppFonts.titleMedium(
                                            color: invoice.balanceDue > 0
                                                ? AppColors.error
                                                : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (!invoice.isPaid) ...[
                                  const SizedBox(height: 16),
                                  AppButton(
                                    label: 'Record Payment Received',
                                    variant: AppButtonVariant.primary,
                                    isFullWidth: true,
                                    height: 42,
                                    onPressed: () => _showRecordPaymentDialog(
                                        context, ref, invoice),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            AppRefresh(
              onRefresh: vm.refresh,
              child: AppResponsiveLayout(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading) {
                      return const AppLoading(message: 'Loading payments...');
                    }
                    if (state.payments.isEmpty) {
                      return const AppEmptyState(
                        title: 'No Payments Recorded',
                        message: 'Payment entries will appear here.',
                        icon: Icons.payments_outlined,
                      );
                    }
                    return ListView.builder(
                      itemCount: state.payments.length,
                      itemBuilder: (ctx, index) {
                        final p = state.payments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.successBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              CurrencyFormatter.format(p.amount),
                              style: AppFonts.titleMedium(color: primaryTextColor),
                            ),
                            subtitle: Text(
                              '${p.paymentMethod.toUpperCase()} • ${DateFormatter.formatDateTime(p.createdAt)}',
                              style: AppFonts.labelSmall(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            trailing: Text(
                              p.referenceNumber,
                              style: AppFonts.labelSmall(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
