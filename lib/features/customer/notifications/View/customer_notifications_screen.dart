import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_firestore_paginated_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/shared/models/notification_model.dart';
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
        leading: state.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: vm.clearSelection,
              )
            : null,
        title: Text(
          state.isSelectionMode
              ? '${state.selectedIds.length} selected'
              : 'Notifications',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        actions: [
          if (state.isSelectionMode) ...[
            TextButton(
              onPressed: state.areAllSelected
                  ? vm.clearSelection
                  : vm.selectAll,
              child: Text(state.areAllSelected ? 'Deselect All' : 'Select All'),
            ),
            IconButton(
              icon: state.isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.delete_rounded,
                      color: AppColors.primaryRed,
                    ),
              tooltip: 'Delete Selected',
              onPressed: state.isDeleting
                  ? null
                  : () async {
                      final confirmed = await AppDialog.confirm(
                        context,
                        title: 'Delete Notifications',
                        message:
                            'Are you sure you want to delete ${state.selectedIds.length} notification(s)?',
                        confirmLabel: 'Delete',
                        isDestructive: true,
                      );
                      if (confirmed == true) {
                        await vm.deleteSelected();
                      }
                    },
            ),
          ] else ...[
            if (state.filteredNotifications.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.checklist_rounded),
                tooltip: 'Select Notifications',
                onPressed: vm.selectAll,
              ),
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
        ],
      ),
      body: AppResponsiveLayout(
        child: AppFirestorePaginatedListView<NotificationModel>(
          items: state.filteredNotifications,
          isInitialLoading: state.isLoading,
          isFetchingNextPage: state.isFetchingNextPage,
          hasMore: state.hasMore,
          errorMessage: state.errorMessage,
          onRefresh: vm.refresh,
          onPrefetchNextPage: vm.fetchNextPage,
          padding: EdgeInsets.zero,
          separator: const Divider(height: 1),
          emptyState: AppEmptyState(
            title: state.filterOnlyUnread
                ? 'No Unread Notifications'
                : 'No Notifications Yet',
            message: state.filterOnlyUnread ? 'You are all caught up!' : 'Repair status changes, estimate approvals, and reminders will notify you here.',
            icon: Icons.notifications_none_rounded,
          ),
          itemBuilder: (context, notif, index) {
            final isSelected = state.isSelected(notif.id);
            return NotificationTile(
              notification: notif,
              isSelectionMode: state.isSelectionMode,
              isSelected: isSelected,
              onSelectChanged: (_) => vm.toggleSelect(notif.id),
              onLongPress: () => vm.toggleSelect(notif.id),
              onDelete: () async {
                final confirmed = await AppDialog.confirm(
                  context,
                  title: 'Delete Notification',
                  message: 'Are you sure you want to delete this notification?',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                );
                if (confirmed == true) {
                  await vm.deleteSingle(notif.id);
                }
              },
              onTap: () {
                if (state.isSelectionMode) {
                  vm.toggleSelect(notif.id);
                  return;
                }
                vm.markAsRead(notif.id);
                if (notif.deepLink != null && notif.deepLink!.isNotEmpty) {
                  context.go(notif.deepLink!);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
