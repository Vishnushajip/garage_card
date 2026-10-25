import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';

import '../ViewModel/customer_invoices_view_model.dart';
import '../Widgets/invoice_card_item.dart';

class CustomerInvoicesScreen extends ConsumerWidget {
  const CustomerInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerInvoicesViewModelProvider);
    final vm = ref.read(customerInvoicesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Invoices & Payments',
            style: AppFonts.titleLarge(color: primaryTextColor),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Invoices'),
              Tab(text: 'Payment History'),
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
                        title: 'No Invoices Found',
                        message: 'Completed repair jobs and issued invoices will appear here.',
                        icon: Icons.receipt_long_outlined,
                      );
                    }
                    return ListView.builder(
                      itemCount: state.invoices.length,
                      itemBuilder: (ctx, index) {
                        return InvoiceCardItem(invoice: state.invoices[index]);
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
                      return const AppLoading(
                        message: 'Loading payment history...',
                      );
                    }
                    if (state.payments.isEmpty) {
                      return const AppEmptyState(
                        title: 'No Payments Recorded',
                        message: 'Payment receipts will be visible here.',
                        icon: Icons.payment_outlined,
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
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              CurrencyFormatter.format(p.amount),
                              style: AppFonts.titleMedium(
                                color: primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              '${p.paymentMethod.toUpperCase()} • ${DateFormatter.formatDateTime(p.createdAt)}',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            trailing: Text(
                              p.referenceNumber,
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
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
