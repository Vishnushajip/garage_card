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
    final garageName =
        (rawGarageName.isNotEmpty &&
            !rawGarageName.contains('Vishnu') &&
            !rawGarageName.endsWith('\'s Garage'))
        ? rawGarageName
        : 'Garage Operations';

    final financial = state.financialMetrics;
    final operational = state.operationalMetrics;
    final customer = state.customerMetrics;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0C1019)
          : const Color(0xFFF1F5F9),
      appBar: AppCustomAppBar(
        title: garageName,
        subtitle: 'Workshop Intelligence & Performance',
        leading: InkWell(
          onTap: () => context.push(RoutePaths.merchantSettings),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
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
                    final int crossAxisCount;

                    if (width >= 1100) {
                      crossAxisCount = 4;
                    } else if (width >= 640) {
                      crossAxisCount = 2;
                    } else {
                      crossAxisCount = 1;
                    }

                    final kpis = [
                      ClayKpiCard(
                        title: 'Total Revenue',
                        value: CurrencyFormatter.format(
                          financial.totalCollected,
                        ),
                        icon: PhosphorIconsFill.wallet,
                        accentColor: AppColors.success,
                        trendPercent: financial.collectedGrowthRate,
                        subtitle: 'Collected in selected period',
                        tooltipMessage: 'Total settled revenue from paid invoices and partial payment receipts within this timeframe.',
                        onTap: onNavigateToAnalytics,
                      ),
                      ClayKpiCard(
                        title: 'Active Floor Repairs',
                        value: '${operational.jobsInProgress}',
                        icon: PhosphorIconsFill.wrench,
                        accentColor: AppColors.accentBlue,
                        subtitle:
                            '${operational.vehiclesCurrentlyUnderService} vehicles in garage bays',
                        tooltipMessage: 'Total repair jobs currently in progress, waiting for parts, or undergoing inspection.',
                        onTap: onNavigateToJobs,
                      ),
                      ClayKpiCard(
                        title: 'Completed Jobs',
                        value: '${operational.jobsCompleted}',
                        icon: PhosphorIconsFill.checkCircle,
                        accentColor: const Color(0xFF10B981),
                        trendPercent: operational.jobsGrowthRate,
                        subtitle: 'Finished & verified repairs',
                        tooltipMessage: 'Vehicles where all servicing, testing, and inspection requirements have been fulfilled.',
                        onTap: onNavigateToJobs,
                      ),
                      ClayKpiCard(
                        title: 'Receivables Due',
                        value: CurrencyFormatter.format(
                          financial.totalOutstanding,
                        ),
                        icon: PhosphorIconsFill.receipt,
                        accentColor: AppColors.error,
                        subtitle: financial.overdueOutstanding > 0
                            ? '${CurrencyFormatter.format(financial.overdueOutstanding)} overdue'
                            : 'Pending invoice balances',
                        tooltipMessage: 'Unsettled payments owed by customers across all active workshop invoices.',
                        onTap: onNavigateToInvoices,
                      ),
                      ClayKpiCard(
                        title: 'Awaiting Tech Assignment',
                        value: '${operational.jobsAwaitingAssignment}',
                        icon: PhosphorIconsFill.userPlus,
                        accentColor: AppColors.accentAmber,
                        subtitle: 'Checked in without technician',
                        tooltipMessage: 'Jobs in queue requiring a mechanic to be allocated to begin diagnosis or repair.',
                        onTap: onNavigateToJobs,
                      ),
                      ClayKpiCard(
                        title: 'Estimates Pending',
                        value: '${operational.estimatesAwaitingApproval}',
                        icon: PhosphorIconsFill.fileText,
                        accentColor: const Color(0xFF8B5CF6),
                        subtitle: 'Quotes awaiting client approval',
                        tooltipMessage: 'Digital estimates sent to customers that require digital consent before starting work.',
                        onTap: onNavigateToEstimates,
                      ),
                      ClayKpiCard(
                        title: 'Ready for Pickup',
                        value: '${operational.jobsReadyForPickup}',
                        icon: PhosphorIconsFill.key,
                        accentColor: const Color(0xFF06B6D4),
                        subtitle: 'Awaiting client collection',
                        tooltipMessage: 'Vehicles fully repaired, cleaned, and awaiting gate pass issuance or customer pickup.',
                        onTap: onNavigateToJobs,
                      ),
                      ClayKpiCard(
                        title: 'Repeat Clients',
                        value: '${customer.returningCustomersInPeriod}',
                        icon: PhosphorIconsFill.arrowsClockwise,
                        accentColor: const Color(0xFF6366F1),
                        subtitle:
                            '${customer.repeatCustomerRate.toStringAsFixed(1)}% retention rate',
                        tooltipMessage: 'Customers returning to your garage for repeat maintenance or follow-up service.',
                        onTap: onNavigateToCustomers,
                      ),
                    ];

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 86,
                      ),
                      itemCount: kpis.length,
                      itemBuilder: (context, index) => kpis[index],
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
                            flex: 6,
                            child: RevenueAnalyticsCard(
                              financialMetrics: financial,
                              currencyCode: state.garage?.currencyCode ?? 'INR',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: PaymentMethodBreakdownCard(
                              breakdown: financial.paymentMethodBreakdown,
                              percentages: financial.paymentMethodPercentages,
                              totalCollected: financial.totalCollected,
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
                            child: JobDistributionCard(
                              operationalMetrics: operational,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MechanicProductivityCard(
                              mechanics: state.mechanicMetrics,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        JobDistributionCard(operationalMetrics: operational),
                        const SizedBox(height: 16),
                        MechanicProductivityCard(
                          mechanics: state.mechanicMetrics,
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
                            child: CustomerRetentionCard(
                              customerMetrics: customer,
                              onNavigateToCustomers: onNavigateToCustomers,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FinancialOperationsCard(
                              financialMetrics: financial,
                              transactions: state.recentTransactions,
                              onNavigateToInvoices: onNavigateToInvoices,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        CustomerRetentionCard(
                          customerMetrics: customer,
                          onNavigateToCustomers: onNavigateToCustomers,
                        ),
                        const SizedBox(height: 16),
                        FinancialOperationsCard(
                          financialMetrics: financial,
                          transactions: state.recentTransactions,
                          onNavigateToInvoices: onNavigateToInvoices,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                RecentJobsSegmentedFeed(
                  jobs: state.filteredRecentJobs,
                  selectedFilter: state.selectedJobFilter,
                  onFilterChanged: vm.setJobFilter,
                  onJobSelected: onJobSelected,
                  onNavigateToJobs: onNavigateToJobs,
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
