import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
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
    required this.onJobSelected,
  });

  final VoidCallback onNavigateToJobs;
  final VoidCallback onNavigateToCustomers;
  final VoidCallback onNavigateToEstimates;
  final VoidCallback onNavigateToInvoices;
  final VoidCallback onNavigateToAppointments;
  final ValueChanged<String> onJobSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantDashboardViewModelProvider);
    final vm = ref.read(merchantDashboardViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    if (state.isLoading) {
      return const Scaffold(
        body: AppLoading(message: 'Loading garage dashboard...'),
      );
    }

    if (state.errorMessage != null && state.recentJobs.isEmpty) {
      return Scaffold(
        body: AppErrorState(
          message: state.errorMessage!,
          onRetry: vm.refresh,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apex Precision Automotive',
              style: AppFonts.titleLarge(color: primaryTextColor),
            ),
            Text(
              'Garage Operations & Overview',
              style: AppFonts.labelSmall(color: secondaryTextColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
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
                              style:
                                  AppFonts.labelSmall(color: secondaryTextColor),
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
                              style:
                                  AppFonts.labelSmall(color: secondaryTextColor),
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
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.recentJobs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
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
