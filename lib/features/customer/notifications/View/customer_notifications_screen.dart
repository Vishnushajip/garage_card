import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:go_router/go_router.dart';

import '../ViewModel/customer_notifications_view_model.dart';
import '../Widgets/notification_tile.dart';

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerNotificationsViewModelProvider);
    final vm = ref.read(customerNotificationsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.filterOnlyUnread
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: state.filterOnlyUnread ? AppColors.accentBlue : null,
            ),
            tooltip: 'Filter Unread Only',
            onPressed: vm.toggleFilterUnread,
          ),
          if (state.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: AppResponsiveLayout(
          child: Builder(
            builder: (context) {
              if (state.isLoading) {
                return const AppLoading(message: 'Loading notifications...');
              }
              if (state.errorMessage != null && state.notifications.isEmpty) {
                return AppErrorState(
                  message: state.errorMessage!,
                  onRetry: vm.refresh,
                );
              }
              final displayList = state.filteredNotifications;
              if (displayList.isEmpty) {
                return AppEmptyState(
                  title: state.filterOnlyUnread
                      ? 'No Unread Notifications'
                      : 'No Notifications Yet',
                  message: state.filterOnlyUnread ? 'You are all caught up!' : 'Repair status changes, estimate approvals, and reminders will notify you here.',
                  icon: Icons.notifications_none_rounded,
                );
              }

              return ListView.separated(
                itemCount: displayList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final notif = displayList[index];
                  return NotificationTile(
                    notification: notif,
                    onTap: () {
                      vm.markAsRead(notif.id);
                      if (notif.deepLink != null &&
                          notif.deepLink!.isNotEmpty) {
                        context.go(notif.deepLink!);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
