import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_cached_image.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../notifications/ViewModel/merchant_notifications_view_model.dart';
import '../ViewModel/merchant_dashboard_view_model.dart';
import '../Widgets/clay_kpi_card.dart';
import '../Widgets/customer_retention_card.dart';
import '../Widgets/dashboard_header.dart';
import '../Widgets/financial_operations_card.dart';
import '../Widgets/job_distribution_card.dart';
import '../Widgets/mechanic_productivity_card.dart';
import '../Widgets/payment_method_breakdown_card.dart';
import '../Widgets/recent_jobs_segmented_feed.dart';
import '../Widgets/revenue_analytics_card.dart';
import '../Widgets/smart_alerts_banner.dart';
import '../Widgets/workshop_pipeline_diagram.dart';

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
      width: 38,
      height: 38,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantDashboardViewModelProvider);
    final vm = ref.read(merchantDashboardViewModelProvider.notifier);
    final unreadNotifCount = ref.watch(
      merchantNotificationsViewModelProvider.select((s) => s.unreadCount),
    );
    final user = ref.watch(authViewModelProvider.select((s) => s.userProfile));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    if (state.isLoading) {
      return const Scaffold(
        body: AppLoading(message: 'Loading workshop analytics dashboard...'),
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

    final rawGarageName = state.garage?.name ?? '';
    final garageName = rawGarageName.trim().isNotEmpty
        ? rawGarageName
        : 'Apex Garage Workshop';
    final garageCity = state.garage?.city ?? 'Bengaluru';
    final addressText = state.garage?.address;
    final garageAddress = (addressText != null && addressText.isNotEmpty)
        ? addressText
        : 'Main Bay - $garageCity';

    final operational = state.operationalMetrics;
    final financial = state.financialMetrics;
    final customer = state.customerMetrics;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppCustomAppBar(
        title: garageName,
        subtitle: 'Workshop Intelligence & Performance',
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppCachedImage(
              imageUrl: state.garage?.logoUrl,
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(9),
              errorWidget: _buildAppBarLogoFallback(garageName),
            ),
          ),
        ),
        showChat: true,
        showNotifications: true,
        unreadNotificationCount: unreadNotifCount,
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppResponsiveLayout(
            maxWidth: 1440,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.smartAlerts.isNotEmpty) ...[
                  SmartAlertsBanner(alerts: state.smartAlerts),
                  const SizedBox(height: 8),
                ],
                DashboardHeader(
                  ownerName: user?.fullName ?? '',
                  garageName: garageName,
                  garageAddress: garageAddress,
                  selectedTimeRange: state.selectedTimeRange,
                  customStartDate: state.customStartDate,
                  customEndDate: state.customEndDate,
                  onTimeRangeSelected: vm.setTimeRange,
                  onNavigateToJobs: onNavigateToJobs,
                  onNavigateToCustomers: onNavigateToCustomers,
                  onNavigateToInvoices: onNavigateToInvoices,
                ),
                const SizedBox(height: 16),
                WorkshopPipelineDiagram(
                  operationalMetrics: operational,
                  onNavigateToJobs: onNavigateToJobs,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final int cols = width >= 1100 ? 4 : (width >= 640 ? 2 : 1);

                    final majorKpis = [
                      ClayMajorKpiCard(
                        title: 'Total Revenue',
                        value: CurrencyFormatter.format(
                          financial.totalCollected,
                        ),
                        icon: PhosphorIconsFill.wallet,
                        iconBgColor: const Color(0xFFDCFCE7),
                        iconColor: const Color(0xFF16A34A),
                        trendPercent: financial.collectedGrowthRate,
                        subtitle: 'Collected in selected period',
                        tooltipMessage: 'Total settled revenue from paid invoices and receipts within this timeframe.',
                        onTap: onNavigateToAnalytics,
                      ),
                      ClayMajorKpiCard(
                        title: 'Active Floor Repairs',
                        value: '${operational.jobsInProgress}',
                        icon: PhosphorIconsFill.wrench,
                        iconBgColor: const Color(0xFFFEE2E2),
                        iconColor: const Color(0xFFEF4444),
                        subtitle:
                            '${operational.vehiclesCurrentlyUnderService} vehicles in garage bays',
                        tooltipMessage: 'Total repair jobs currently in progress, waiting for parts, or undergoing inspection.',
                        onTap: onNavigateToJobs,
                      ),
                      ClayMajorKpiCard(
                        title: 'Completed Jobs',
                        value: '${operational.jobsCompleted}',
                        icon: PhosphorIconsFill.checkCircle,
                        iconBgColor: const Color(0xFFDCFCE7),
                        iconColor: const Color(0xFF16A34A),
                        trendPercent: operational.jobsGrowthRate,
                        subtitle: 'Finished & verified repairs',
                        tooltipMessage: 'Vehicles where all servicing, testing, and inspection requirements have been fulfilled.',
                        onTap: onNavigateToJobs,
                      ),
                      ClayMajorKpiCard(
                        title: 'Receivables Due',
                        value: CurrencyFormatter.format(
                          financial.totalOutstanding,
                        ),
                        icon: PhosphorIconsFill.receipt,
                        iconBgColor: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF3B82F6),
                        subtitle: financial.overdueOutstanding > 0
                            ? '${CurrencyFormatter.format(financial.overdueOutstanding)} overdue'
                            : 'Pending invoice balances',
                        tooltipMessage: 'Unsettled payments owed by customers across all active workshop invoices.',
                        onTap: onNavigateToInvoices,
                      ),
                    ];

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 148,
                      ),
                      itemCount: majorKpis.length,
                      itemBuilder: (context, index) => majorKpis[index],
                    );
                  },
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final int cols = width >= 1100 ? 4 : (width >= 640 ? 2 : 1);

                    final subKpis = [
                      ClaySubKpiCard(
                        title: 'Awaiting Tech Assignment',
                        value: '${operational.jobsAwaitingAssignment}',
                        icon: PhosphorIconsFill.userPlus,
                        iconColor: const Color(0xFFF59E0B),
                        subtitle: 'Checked-in w/o tech',
                        tooltipMessage: 'Vehicles registered at intake but not yet allocated to a technician bay.',
                        onTap: onNavigateToJobs,
                      ),
                      ClaySubKpiCard(
                        title: 'Estimates Pending',
                        value: '${operational.estimatesAwaitingApproval}',
                        icon: PhosphorIconsFill.fileText,
                        iconColor: const Color(0xFF8B5CF6),
                        subtitle: 'Quotes awaiting approval',
                        tooltipMessage: 'Price quotations sent to car owners awaiting authorization.',
                        onTap: onNavigateToEstimates,
                      ),
                      ClaySubKpiCard(
                        title: 'Ready for Pickup',
                        value: '${operational.jobsReadyForPickup}',
                        icon: PhosphorIconsFill.key,
                        iconColor: const Color(0xFF06B6D4),
                        subtitle: 'Awaiting collection',
                        tooltipMessage: 'Vehicles that have passed quality inspection and are awaiting customer hand-off.',
                        onTap: onNavigateToJobs,
                      ),
                      ClaySubKpiCard(
                        title: 'Repeat Clients',
                        value:
                            '${customer.returningCustomersInPeriod} (${customer.repeatCustomerRate.toStringAsFixed(1)}%)',
                        icon: PhosphorIconsFill.users,
                        iconColor: const Color(0xFF3B82F6),
                        subtitle: customer.repeatCustomerRate >= 50
                            ? 'High retention'
                            : 'Workshop loyalty',
                        tooltipMessage: 'Percentage of workshop clients who have serviced more than one vehicle.',
                        onTap: onNavigateToCustomers,
                      ),
                    ];

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 72,
                      ),
                      itemCount: subKpis.length,
                      itemBuilder: (context, index) => subKpis[index],
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 960;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                RevenueAnalyticsCard(
                                  financialMetrics: financial,
                                  currencyCode:
                                      state.garage?.currencyCode ?? 'INR',
                                ),
                                const SizedBox(height: 16),
                                JobDistributionCard(
                                  operationalMetrics: operational,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                PaymentMethodBreakdownCard(
                                  breakdown: financial.paymentMethodBreakdown,
                                  percentages:
                                      financial.paymentMethodPercentages,
                                  totalCollected: financial.totalCollected,
                                ),
                                const SizedBox(height: 16),
                                MechanicProductivityCard(
                                  mechanics: state.mechanicMetrics,
                                ),
                                const SizedBox(height: 16),
                                CustomerRetentionCard(
                                  customerMetrics: customer,
                                  onNavigateToCustomers: onNavigateToCustomers,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        RevenueAnalyticsCard(
                          financialMetrics: financial,
                          currencyCode: state.garage?.currencyCode ?? 'INR',
                        ),
                        const SizedBox(height: 16),
                        PaymentMethodBreakdownCard(
                          breakdown: financial.paymentMethodBreakdown,
                          percentages: financial.paymentMethodPercentages,
                          totalCollected: financial.totalCollected,
                        ),
                        const SizedBox(height: 16),
                        JobDistributionCard(operationalMetrics: operational),
                        const SizedBox(height: 16),
                        MechanicProductivityCard(
                          mechanics: state.mechanicMetrics,
                        ),
                        const SizedBox(height: 16),
                        CustomerRetentionCard(
                          customerMetrics: customer,
                          onNavigateToCustomers: onNavigateToCustomers,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 960;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: FinancialOperationsCard(
                              financialMetrics: financial,
                              transactions: state.recentTransactions,
                              onNavigateToInvoices: onNavigateToInvoices,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 7,
                            child: RecentJobsSegmentedFeed(
                              jobs: state.filteredRecentJobs,
                              selectedFilter: state.selectedJobFilter,
                              onFilterChanged: vm.setJobFilter,
                              onJobSelected: onJobSelected,
                              onNavigateToJobs: onNavigateToJobs,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        FinancialOperationsCard(
                          financialMetrics: financial,
                          transactions: state.recentTransactions,
                          onNavigateToInvoices: onNavigateToInvoices,
                        ),
                        const SizedBox(height: 16),
                        RecentJobsSegmentedFeed(
                          jobs: state.filteredRecentJobs,
                          selectedFilter: state.selectedJobFilter,
                          onFilterChanged: vm.setJobFilter,
                          onJobSelected: onJobSelected,
                          onNavigateToJobs: onNavigateToJobs,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2638) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Apex Garage Operations ERP • v4.10.2 Stable • All systems operational',
                          style: AppFonts.labelSmall(color: secondaryTextColor)
                              .copyWith(fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Keyboard shortcut: ⌘+K to quick-add vehicle',
                        style: AppFonts.labelSmall(
                          color: secondaryTextColor.withValues(alpha: 0.7),
                        ).copyWith(fontSize: 10),
                      ),
                    ],
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
