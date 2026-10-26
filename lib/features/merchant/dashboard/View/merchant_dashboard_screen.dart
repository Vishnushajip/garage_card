import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';

import '../ViewModel/merchant_dashboard_view_model.dart';
import '../Widgets/kpi_metric_card.dart';
import '../Widgets/merchant_job_row.dart';
import '../../analytics/ViewModel/merchant_analytics_view_model.dart';
import '../../analytics/Widgets/daily_briefing_modal.dart';
import '../../notifications/ViewModel/merchant_notifications_view_model.dart';

import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/features/shared/profile_prompt/profile_completion_prompt_service.dart';
import 'package:go_router/go_router.dart';

class MerchantDashboardScreen extends ConsumerWidget {
  const MerchantDashboardScreen({
    super.key,
    required this.onNavigateToJobs,
    required this.onNavigateToCustomers,
    required this.onNavigateToEstimates,
    required this.onNavigateToInvoices,
    required this.onNavigateToAppointments,
    required this.onNavigateToAnalytics,
    required this.onJobSelected,
  });

  final VoidCallback onNavigateToJobs;
  final VoidCallback onNavigateToCustomers;
  final VoidCallback onNavigateToEstimates;
  final VoidCallback onNavigateToInvoices;
  final VoidCallback onNavigateToAppointments;
  final VoidCallback onNavigateToAnalytics;
  final ValueChanged<String> onJobSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantDashboardViewModelProvider);
    final vm = ref.read(merchantDashboardViewModelProvider.notifier);
    final analyticsState = ref.watch(merchantAnalyticsViewModelProvider);
    final analyticsVm = ref.read(merchantAnalyticsViewModelProvider.notifier);
    final merchantNotifState = ref.watch(
      merchantNotificationsViewModelProvider,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    if (state.isLoading) {
      return const Scaffold(
        body: AppLoading(message: 'Loading garage dashboard...'),
      );
    }

    if (state.errorMessage != null && state.recentJobs.isEmpty) {
      return Scaffold(
        body: AppErrorState(message: state.errorMessage!, onRetry: vm.refresh),
      );
    }

    if (!state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref
              .read(profileCompletionPromptServiceProvider)
              .checkAndShowPrompt(context, ref);
        }
      });
    }

    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Apex Precision Automotive',
        subtitle: 'Garage Operations & Overview',
        showAccountSwitch: true,
        showNotifications: true,
        unreadNotificationCount: merchantNotifState.unreadCount,
        actions: [
          IconButton(
            icon: const Icon(Icons.miscellaneous_services_rounded),
            tooltip: 'Services & Pricing',
            onPressed: () => context.push(RoutePaths.merchantServices),
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'Messages',
            onPressed: () => context.push(RoutePaths.chatList),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              vm.refresh();
              analyticsVm.refresh();
            },
          ),
        ],
      ),
      body: AppRefresh(
        onRefresh: () async {
          await vm.refresh();
          await analyticsVm.refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppResponsiveLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (analyticsState.showMorningBriefing) ...[
                  DailyBriefingModal(
                    todayDeliveries: analyticsState.todayDeliveriesCount,
                    pendingDues: analyticsState.todayPendingPaymentsCount,
                    yesterdayCompleted: analyticsState.yesterdayCompletedCount,
                    onDismiss: analyticsVm.dismissMorningBriefing,
                    onViewTodo: onNavigateToAnalytics,
                  ),
                  const SizedBox(height: 16),
                ],
                GridView.count(
                  crossAxisCount: AppResponsiveLayout.isDesktop(context)
                      ? 4
                      : AppResponsiveLayout.isTablet(context)
                      ? 3
                      : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    KpiMetricCard(
                      title: 'Active Jobs',
                      value: '${state.totalActiveJobs}',
                      icon: Icons.car_repair_rounded,
                      accentColor: AppColors.accentBlue,
                      onTap: onNavigateToJobs,
                    ),
                    KpiMetricCard(
                      title: 'In Progress',
                      value: '${state.jobsInProgress}',
                      icon: Icons.handyman_rounded,
                      accentColor: AppColors.info,
                      onTap: onNavigateToJobs,
                    ),
                    KpiMetricCard(
                      title: 'Pending Estimate',
                      value: '${state.estimatesAwaitingApproval}',
                      icon: Icons.request_quote_rounded,
                      accentColor: AppColors.warning,
                      onTap: onNavigateToEstimates,
                    ),
                    KpiMetricCard(
                      title: 'Ready for Pickup',
                      value: '${state.vehiclesReady}',
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: AppColors.success,
                      onTap: onNavigateToJobs,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outstanding Receivables',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(state.totalUnpaidAmount),
                              style: AppFonts.numberLarge(
                                color: AppColors.error,
                              ),
                            ),
                            Text(
                              '${state.unpaidInvoices.length} invoices awaiting payment',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        AppButton(
                          label: 'View Invoices',
                          onPressed: onNavigateToInvoices,
                          variant: AppButtonVariant.outline,
                          height: 38,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentBlue.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.insights_rounded,
                                      color: AppColors.accentBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Daily Pipeline & Analytics',
                                      style: AppFonts.titleMedium(
                                        color: primaryTextColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: onNavigateToAnalytics,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Full Analytics'),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.info.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Due Today',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${analyticsState.todayDeliveriesCount} Vehicles',
                                      style: AppFonts.titleMedium(
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.success.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Completed Yesterday',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${analyticsState.yesterdayCompletedCount} Jobs',
                                      style: AppFonts.titleMedium(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Dues',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${analyticsState.todayPendingPaymentsCount} Invoices',
                                      style: AppFonts.titleMedium(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Service Jobs',
                      style: AppFonts.titleLarge(color: primaryTextColor),
                    ),
                    TextButton(
                      onPressed: onNavigateToJobs,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Card(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.recentJobs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final job = state.recentJobs[index];
                      return MerchantJobRow(
                        job: job,
                        onTap: () => onJobSelected(job.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
