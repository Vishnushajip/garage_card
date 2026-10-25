import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_firestore_paginated_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/customer/dashboard/Widgets/customer_active_job_card.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:go_router/go_router.dart';

import '../ViewModel/customer_jobs_view_model.dart';

class CustomerJobsScreen extends ConsumerWidget {
  const CustomerJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerJobsViewModelProvider);
    final vm = ref.read(customerJobsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Repair Orders',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
      ),
      body: AppResponsiveLayout(
        child: AppFirestorePaginatedListView<ServiceJobModel>(
          items: state.jobs,
          isInitialLoading: state.isLoading,
          isFetchingNextPage: state.isFetchingNextPage,
          hasMore: state.hasMore,
          errorMessage: state.errorMessage,
          onRefresh: vm.refresh,
          onPrefetchNextPage: vm.fetchNextPage,
          emptyState: const AppEmptyState(
            title: 'No repair orders found',
            message: 'When you check your vehicle into an authorized garage, your live repair status will appear here.',
            icon: Icons.car_repair_rounded,
          ),
          itemBuilder: (context, job, index) {
            return CustomerActiveJobCard(
              job: job,
              onTap: () => context.go('/customer/jobs/${job.id}'),
            );
          },
        ),
      ),
    );
  }
}
