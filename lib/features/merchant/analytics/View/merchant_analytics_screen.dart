import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:go_router/go_router.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    if (state.isLoading && state.metrics == null) {
      return const Scaffold(
        body: AppLoading(message: 'Loading financial analytics & pipeline...'),
      );
    }

    if (state.errorMessage != null && state.metrics == null) {
      return Scaffold(
        body: AppErrorState(
          message: state.errorMessage!,
          onRetry: vm.refresh,
        ),
      );
    }

    final metrics = state.metrics;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Revenue & Operations Analytics',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        actions: [
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
                    state.selectedRange,
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
                FutureBuilder(
                  future: repo.getInvoices(garageId: 'garage_demo_1', limit: 50),
                  builder: (context, snapshot) {
                    final invoices = snapshot.data ?? [];
                    return BillAnalyticsList(
                      invoices: invoices,
                      onSelectInvoice: (_) =>
                          context.push(RoutePaths.merchantInvoices),
                    );
                  },
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
