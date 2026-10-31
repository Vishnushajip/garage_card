import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:go_router/go_router.dart';

import '../../analytics/ViewModel/merchant_analytics_view_model.dart';
import '../../analytics/Widgets/daily_briefing_modal.dart';
import '../../notifications/ViewModel/merchant_notifications_view_model.dart';
import '../ViewModel/merchant_dashboard_view_model.dart';
import '../Widgets/kpi_metric_card.dart';
import '../Widgets/merchant_job_row.dart';

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

  Widget _buildAppBarLogoFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentBlue, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppFonts.titleSmall(color: Colors.white)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPipelineCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color secondaryTextColor,
  }) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.labelSmall(color: secondaryTextColor),
          ),
          Text(value, maxLines: 1, style: AppFonts.numberLarge(color: color)),
          Text(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.labelSmall(color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantDashboardViewModelProvider);
    final vm = ref.read(merchantDashboardViewModelProvider.notifier);
    final analyticsState = ref.watch(merchantAnalyticsViewModelProvider);
    final analyticsVm = ref.read(merchantAnalyticsViewModelProvider.notifier);
    final merchantNotifState = ref.watch(
      merchantNotificationsViewModelProvider,
    );
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

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

    if (state.garage == null &&
        (user?.garageId == null || user!.garageId!.isEmpty)) {
      return Scaffold(
        appBar: const AppCustomAppBar(
          title: 'Workshop Setup',
          subtitle: 'Complete your garage registration',
        ),
        body: Center(
          child: AppResponsiveLayout(
            child: AppEmptyState(
              icon: Icons.storefront_rounded,
              title: 'You haven\'t registered a garage yet',
              description: 'Set up your garage profile, trading name, and business address to start managing repair jobs, clients, and digital invoices.',
              actionLabel: 'Add Your Garage',
              onAction: () => context.push(RoutePaths.merchantSettings),
            ),
          ),
        ),
      );
    }

    final garageName =
        state.garage?.name ??
        (user?.fullName.isNotEmpty == true
            ? '${user!.fullName}\'s Garage'
            : 'Garage Operations');
    final pipelineJobs = state.recentJobs
        .where((j) => j.status != 'completed' && j.status != 'closed')
        .toList();

    return Scaffold(
      appBar: AppCustomAppBar(
        title: garageName,
        subtitle: 'Garage Operations & Overview',
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child:
              state.garage?.logoUrl != null && state.garage!.logoUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    state.garage!.logoUrl!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        _buildAppBarLogoFallback(garageName),
                  ),
                )
              : _buildAppBarLogoFallback(garageName),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
            tooltip: 'Messages',
            onPressed: () => context.push(RoutePaths.chatList),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: merchantNotifState.unreadCount > 0,
              label: Text(
                merchantNotifState.unreadCount > 99
                    ? '99+'
                    : merchantNotifState.unreadCount.toString(),
              ),
              backgroundColor: AppColors.primaryRed,
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
            tooltip: 'Notifications',
            onPressed: () => context.push(RoutePaths.merchantNotifications),
          ),
          const SizedBox(width: 4),
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
                  childAspectRatio: AppResponsiveLayout.isMobile(context)
                      ? 1.4
                      : 1.5,
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
                Text(
                  'Quick Access',
                  style: AppFonts.titleMedium(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: AppResponsiveLayout.isDesktop(context)
                      ? 4
                      : AppResponsiveLayout.isTablet(context)
                      ? 4
                      : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: AppResponsiveLayout.isMobile(context)
                      ? 2.6
                      : 3.0,
                  children: [
                    _QuickAccessCard(
                      title: 'Analytics',
                      icon: Icons.insights_rounded,
                      color: AppColors.primaryRed,
                      onTap: onNavigateToAnalytics,
                    ),
                    _QuickAccessCard(
                      title: 'Invoices',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.success,
                      onTap: onNavigateToInvoices,
                    ),
                    _QuickAccessCard(
                      title: 'Clients',
                      icon: Icons.people_alt_rounded,
                      color: AppColors.accentBlue,
                      onTap: onNavigateToCustomers,
                    ),
                    _QuickAccessCard(
                      title: 'Garage Profile',
                      icon: Icons.storefront_rounded,
                      color: AppColors.accentAmber,
                      onTap: () => context.push(RoutePaths.merchantSettings),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Outstanding Receivables',
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  CurrencyFormatter.format(
                                    state.totalUnpaidAmount,
                                  ),
                                  style: AppFonts.numberLarge(
                                    color: AppColors.error,
                                  ),
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
                        ),
                        const SizedBox(width: 8),
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
                    side: BorderSide(color: borderColor),
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
                                      'Daily Pipeline',
                                      style: AppFonts.titleMedium(
                                        color: primaryTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: onNavigateToAnalytics,
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Analytics'),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPipelineCard(
                                label: 'Due Today',
                                value: '${analyticsState.todayDeliveriesCount}',
                                unit: 'Vehicles',
                                color: AppColors.info,
                                secondaryTextColor: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildPipelineCard(
                                label: 'Completed',
                                value:
                                    '${analyticsState.yesterdayCompletedCount}',
                                unit: 'Yesterday',
                                color: AppColors.success,
                                secondaryTextColor: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildPipelineCard(
                                label: 'Payment Due',
                                value:
                                    '${analyticsState.todayPendingPaymentsCount}',
                                unit: 'Invoices',
                                color: AppColors.warning,
                                secondaryTextColor: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (pipelineJobs.isNotEmpty) ...[
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          ...pipelineJobs
                              .take(2)
                              .map(
                                (job) => MerchantJobRow(
                                  job: job,
                                  onTap: () => onJobSelected(job.id),
                                ),
                              ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'All scheduled repair tasks are on track today.',
                                    style: AppFonts.bodySmall(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Service Jobs',
                        style: AppFonts.titleLarge(color: primaryTextColor),
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToJobs,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state.recentJobs.isEmpty)
                  AppEmptyState(
                    title: 'No repair jobs found',
                    description: 'Create your first repair job or digital inspection to get started.',
                    icon: Icons.car_repair_rounded,
                    actionLabel: 'Create New Job',
                    onAction: onNavigateToJobs,
                    layoutSize: AppStateLayoutSize.compact,
                  )
                else
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
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

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppFonts.bodySmall(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
