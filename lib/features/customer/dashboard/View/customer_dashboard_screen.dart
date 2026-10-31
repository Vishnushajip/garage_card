import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/customer/nearby_garages/ViewModel/nearby_garages_view_model.dart';
import 'package:garage_card/features/customer/nearby_garages/Widgets/garage_card_item.dart';
import 'package:garage_card/features/customer/appointments/View/customer_appointments_screen.dart';
import 'package:garage_card/features/shared/profile_prompt/profile_completion_prompt_service.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/ViewModel/customer_notifications_view_model.dart';
import '../ViewModel/customer_dashboard_view_model.dart';
import '../Widgets/customer_active_job_card.dart';
import '../Widgets/customer_quick_action_button.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({
    super.key,
    required this.onNavigateToNearbyGarages,
    required this.onNavigateToInvoices,
    required this.onNavigateToReminders,
    required this.onNavigateToJobDetail,
    this.onNavigateToJobs,
  });

  final VoidCallback onNavigateToNearbyGarages;
  final VoidCallback onNavigateToInvoices;
  final VoidCallback onNavigateToReminders;
  final ValueChanged<String> onNavigateToJobDetail;
  final VoidCallback? onNavigateToJobs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardViewModelProvider);
    final vm = ref.read(customerDashboardViewModelProvider.notifier);
    final notifState = ref.watch(customerNotificationsViewModelProvider);
    final nearbyState = ref.watch(nearbyGaragesViewModelProvider);
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
        body: AppLoading(message: 'Loading your garage portal...'),
      );
    }

    if (state.errorMessage != null && state.activeJobs.isEmpty) {
      return Scaffold(
        body: AppErrorState(message: state.errorMessage!, onRetry: vm.refresh),
      );
    }

    final customerGreeting =
        (user?.fullName.isNotEmpty == true && user?.fullName != 'User')
        ? 'Hello, ${user!.fullName.split(' ').first}'
        : 'Welcome Back';

    return Scaffold(
      appBar: AppCustomAppBar(
        title: customerGreeting,
        subtitle: 'Discover workshops, packages & service tracking',
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
            tooltip: 'Messages',
            onPressed: () => context.push(RoutePaths.chatList),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: notifState.unreadCount > 0,
              label: Text(
                notifState.unreadCount > 99
                    ? '99+'
                    : notifState.unreadCount.toString(),
              ),
              backgroundColor: AppColors.primaryRed,
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
            tooltip: 'Notifications',
            onPressed: () => context.push(RoutePaths.customerNotifications),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AppRefresh(
        onRefresh: () async {
          await vm.refresh();
          await ref.read(nearbyGaragesViewModelProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppResponsiveLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null && !user.isProfileComplete) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.contact_phone_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Incomplete',
                                style: AppFonts.titleSmall(
                                  color: AppColors.primaryDark,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Complete your profile to receive instant repair & WhatsApp alerts.',
                                style: AppFonts.labelSmall(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(profileCompletionPromptServiceProvider)
                                .showCompletionSheet(context, user);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Complete Now',
                            style: AppFonts.labelSmall(color: Colors.white)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(RoutePaths.customerSearch),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: AppColors.accentBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search Garages, Services & Packages...',
                                style: AppFonts.labelMedium(
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Bike wash, oil change, periodic maintenance...',
                                style: AppFonts.bodySmall(
                                  color: secondaryTextColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ).copyWith(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Filter',
                                style: AppFonts.labelSmall(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          {'tag': 'Bike Wash', 'query': 'Bike Wash'},
                          {'tag': 'Car Wash', 'query': 'Car Wash'},
                          {'tag': 'Oil Change', 'query': 'Oil Change'},
                          {
                            'tag': 'Periodic Service',
                            'query': 'Periodic Service',
                          },
                          {'tag': 'Brake Overhaul', 'query': 'Brake'},
                          {'tag': 'EV Service', 'query': 'Electric'},
                        ].map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              avatar: const Icon(
                                Icons.trending_up_rounded,
                                size: 14,
                                color: AppColors.accentBlue,
                              ),
                              label: Text(item['tag']!),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                color: primaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              backgroundColor: cardBg,
                              side: BorderSide(color: borderColor),
                              padding: EdgeInsets.zero,
                              onPressed: () => context.push(
                                '${RoutePaths.customerSearch}?q=${Uri.encodeComponent(item['query']!)}',
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.storefront_rounded,
                        label: 'Garages',
                        accentColor: AppColors.accentBlue,
                        onTap: onNavigateToNearbyGarages,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.car_repair_rounded,
                        label: 'Repairs',
                        accentColor: AppColors.info,
                        badgeCount: state.activeJobs.length,
                        onTap:
                            onNavigateToJobs ??
                            () => context.push(RoutePaths.customerJobs),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.receipt_long_rounded,
                        label: 'Invoices',
                        accentColor: AppColors.success,
                        badgeCount: state.unpaidInvoices.length,
                        onTap: onNavigateToInvoices,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomerQuickActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Support',
                        accentColor: AppColors.accentAmber,
                        onTap: () => context.push(RoutePaths.chatList),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'FEATURED OFFERS',
                              style: AppFonts.labelSmall(color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Genuine Parts',
                                    style: AppFonts.labelSmall(
                                      color: Colors.white70,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Workshop Packages & Periodic Care',
                        style: AppFonts.headlineSmall(color: Colors.white)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Periodic Service packages from ₹1,499 • Foam Water Wash & Detailing from ₹499 • Computerized Engine Diagnostics from ₹799.',
                        style: AppFonts.bodySmall(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        label: 'Explore Workshop Packages',
                        onPressed: onNavigateToNearbyGarages,
                        variant: AppButtonVariant.primary,
                        height: 38,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Featured & Verified Garages',
                        style: AppFonts.titleLarge(color: primaryTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToNearbyGarages,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (nearbyState.isLoading && nearbyState.garages.isEmpty)
                  const AppLoading(message: 'Locating top verified garages...')
                else if (nearbyState.garages.isEmpty)
                  AppEmptyState(
                    title: 'No garages found in range',
                    description: 'No partner workshops are currently active in your immediate vicinity. Try searching or adjusting radius.',
                    icon: Icons.storefront_outlined,
                    actionLabel: 'Search Garages',
                    onAction: onNavigateToNearbyGarages,
                    layoutSize: AppStateLayoutSize.compact,
                  )
                else
                  ...nearbyState.garages
                      .take(3)
                      .map(
                        (garage) => GarageCardItem(
                          garage: garage,
                          userLat: nearbyState.userLatitude,
                          userLon: nearbyState.userLongitude,
                          onTap: () =>
                              context.push('/customer/garages/${garage.id}'),
                          onRequestService: () =>
                              CustomerAppointmentsScreen.showBookingSheet(
                                context,
                                garageId: garage.id,
                              ),
                        ),
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Active Repairs',
                              style: AppFonts.titleLarge(
                                color: primaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (state.activeJobs.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.activeJobs.length}',
                                style: AppFonts.labelSmall(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed:
                          onNavigateToJobs ??
                          () => context.push(RoutePaths.customerJobs),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.activeJobs.isEmpty)
                  AppEmptyState(
                    title: 'No active repair jobs',
                    description: 'Your vehicles are in prime shape! Book a service or request assistance whenever needed.',
                    icon: Icons.car_repair_rounded,
                    actionLabel: 'Explore Workshops',
                    onAction: onNavigateToNearbyGarages,
                    layoutSize: AppStateLayoutSize.compact,
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
                    Expanded(
                      child: Text(
                        'Upcoming Maintenance',
                        style: AppFonts.titleLarge(color: primaryTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToReminders,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state.upcomingReminders.isEmpty)
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No upcoming service reminders scheduled.',
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.upcomingReminders
                      .take(2)
                      .map(
                        (rem) => Card(
                          color: cardBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: borderColor),
                          ),
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
                              style: AppFonts.titleMedium(
                                color: primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              '${rem.vehicleDisplay} • Due ${DateFormatter.formatDate(rem.dueDate)}',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
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
