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
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import '../ViewModel/customer_dashboard_view_model.dart';
import '../Widgets/customer_active_job_card.dart';
import '../Widgets/customer_quick_action_button.dart';
import '../../notifications/ViewModel/customer_notifications_view_model.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:go_router/go_router.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({
    super.key,
    required this.onNavigateToNearbyGarages,
    required this.onNavigateToVehicles,
    required this.onNavigateToEstimates,
    required this.onNavigateToInvoices,
    required this.onNavigateToReminders,
    required this.onNavigateToJobDetail,
  });

  final VoidCallback onNavigateToNearbyGarages;
  final VoidCallback onNavigateToVehicles;
  final VoidCallback onNavigateToEstimates;
  final VoidCallback onNavigateToInvoices;
  final VoidCallback onNavigateToReminders;
  final ValueChanged<String> onNavigateToJobDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardViewModelProvider);
    final vm = ref.read(customerDashboardViewModelProvider.notifier);
    final notifState = ref.watch(customerNotificationsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (state.isLoading) {
      return const Scaffold(
        body: AppLoading(message: 'Loading your garage dashboard...'),
      );
    }

    if (state.errorMessage != null && state.activeJobs.isEmpty) {
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
              'My Garage',
              style: AppFonts.titleLarge(color: primaryTextColor),
            ),
            Text(
              'Track repairs, estimates & maintenance',
              style: AppFonts.labelSmall(color: secondaryTextColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: notifState.unreadCount > 0,
              label: Text('${notifState.unreadCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notifications',
            onPressed: () => context.push(RoutePaths.customerNotifications),
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
                Row(
                  children: [
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.near_me_rounded,
                        label: 'Garages',
                        accentColor: AppColors.accentBlue,
                        onTap: onNavigateToNearbyGarages,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.directions_car_rounded,
                        label: 'Vehicles',
                        accentColor: AppColors.info,
                        onTap: onNavigateToVehicles,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.request_quote_rounded,
                        label: 'Estimates',
                        accentColor: AppColors.accentAmber,
                        badgeCount: state.pendingEstimates.length,
                        onTap: onNavigateToEstimates,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.receipt_long_rounded,
                        label: 'Invoices',
                        accentColor: AppColors.success,
                        badgeCount: state.unpaidInvoices.length,
                        onTap: onNavigateToInvoices,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.pendingEstimates.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimate Pending Approval',
                                style: AppFonts.titleMedium(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.pendingEstimates.first.estimateNumber} for ${CurrencyFormatter.format(state.pendingEstimates.first.totalAmount)} requires your approval before work continues.',
                                style: AppFonts.bodyMedium(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: onNavigateToEstimates,
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Repairs',
                      style: AppFonts.titleLarge(color: primaryTextColor),
                    ),
                    Text(
                      '${state.activeJobs.length} active',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.activeJobs.isEmpty)
                  const AppEmptyState(
                    title: 'No active repair jobs',
                    message:
                        'Your vehicles are in prime shape! Book a service or request assistance whenever needed.',
                    icon: Icons.check_circle_outline_rounded,
                  )
                else
                  ...state.activeJobs.map(
                    (job) => CustomerActiveJobCard(
                      job: job,
                      onTap: () => onNavigateToJobDetail(job.id),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Maintenance',
                      style: AppFonts.titleLarge(color: primaryTextColor),
                    ),
                    TextButton(
                      onPressed: onNavigateToReminders,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state.upcomingReminders.isEmpty)
                  Text(
                    'No upcoming service reminders scheduled.',
                    style: AppFonts.bodyMedium(color: secondaryTextColor),
                  )
                else
                  ...state.upcomingReminders.take(2).map(
                        (rem) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: rem.isOverdue
                                    ? AppColors.errorBg
                                    : AppColors.infoBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                color: rem.isOverdue
                                    ? AppColors.error
                                    : AppColors.info,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              rem.title,
                              style: AppFonts.titleMedium(color: primaryTextColor),
                            ),
                            subtitle: Text(
                              '${rem.vehicleDisplay} • Due ${DateFormatter.formatDate(rem.dueDate)}',
                              style: AppFonts.labelSmall(
                                  color: secondaryTextColor),
                            ),
                            trailing: AppStatusBadge(status: rem.status),
                          ),
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
