import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:go_router/go_router.dart';

import '../Model/financial_metrics_model.dart';
import '../Services/tax_export_service.dart';
import '../ViewModel/merchant_analytics_view_model.dart';
import '../Widgets/bill_analytics_list.dart';
import '../Widgets/daily_briefing_modal.dart';
import '../Widgets/daily_operations_todo_card.dart';
import '../Widgets/profit_loss_card.dart';
import '../Widgets/revenue_bar_chart.dart';
import '../Widgets/service_pipeline_summary.dart';
import '../Widgets/time_range_chips.dart';

class MerchantAnalyticsScreen extends ConsumerWidget {
  const MerchantAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantAnalyticsViewModelProvider);
    final vm = ref.read(merchantAnalyticsViewModelProvider.notifier);
    final repo = ref.watch(garageRepositoryProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    final garageId = (user?.garageId != null && user!.garageId!.isNotEmpty)
        ? user.garageId!
        : '';

    if (state.isLoading && state.metrics == null) {
      return const Scaffold(
        body: AppLoading(message: 'Loading financial analytics & pipeline...'),
      );
    }

    if (state.errorMessage != null && state.metrics == null) {
      return Scaffold(
        body: AppErrorState(message: state.errorMessage!, onRetry: vm.refresh),
      );
    }

    final metrics = state.metrics;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Revenue & Operations Analytics',
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export GST Tax Data (CSV)',
            onPressed: () async {
              final invoices = await repo.getInvoicesForTaxExport(garageId);
              if (invoices.isEmpty) {
                if (context.mounted) {
                  AppNotificationService.warning(
                    'No invoices found for tax export.',
                  );
                }
                return;
              }
              await TaxExportService.shareTaxCsv(invoices);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Analytics',
            onPressed: vm.refresh,
          ),
        ],
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppResponsiveLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.showMorningBriefing)
                  DailyBriefingModal(
                    todayDeliveries: state.todayDeliveriesCount,
                    pendingDues: state.todayPendingPaymentsCount,
                    yesterdayCompleted: state.yesterdayCompletedCount,
                    onDismiss: vm.dismissMorningBriefing,
                    onViewTodo: () {},
                  ),
                TimeRangeChips(
                  selectedRange: state.selectedRange,
                  customStart: state.customStartDate,
                  customEnd: state.customEndDate,
                  onSelect: (range) => vm.setTimeRange(range),
                  onSelectCustomRange: (start, end) => vm.setTimeRange(
                    AnalyticsTimeRange.custom,
                    customStart: start,
                    customEnd: end,
                  ),
                ),
                const SizedBox(height: 16),
                ServicePipelineSummary(
                  yesterdayCompleted: state.yesterdayCompletedCount,
                  todayDeliveries: state.todayDeliveriesCount,
                  inProgressCount: metrics?.totalJobsInProgress ?? 0,
                  pendingDuesCount: state.todayPendingPaymentsCount,
                ),
                const SizedBox(height: 16),
                if (metrics != null) ProfitLossCard(metrics: metrics),
                const SizedBox(height: 16),
                if (metrics != null)
                  RevenueBarChart(
                    dataPoints: metrics.chartPoints,
                    currencyCode: metrics.currencyCode,
                  ),
                const SizedBox(height: 16),
                DailyOperationsTodoCard(
                  items: state.todoItems,
                  onToggleDone: vm.toggleTodoItem,
                  onJobSelected: (jobId) =>
                      context.push('/merchant/jobs/$jobId'),
                  onInvoiceSelected: (_) =>
                      context.push(RoutePaths.merchantInvoices),
                ),
                const SizedBox(height: 16),
                BillAnalyticsList(
                  invoices: state.filteredInvoices,
                  onSelectInvoice: (_) =>
                      context.push(RoutePaths.merchantInvoices),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
