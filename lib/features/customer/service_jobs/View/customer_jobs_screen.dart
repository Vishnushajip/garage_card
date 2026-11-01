import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
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
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: const AppCustomAppBar(title: 'My Repair Orders'),
      body: AppResponsiveLayout(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: state.filterStatus == null,
                        label: Text(
                          context.tr('allOrders'),
                          style: TextStyle(
                            color: state.filterStatus == null
                                ? Colors.white
                                : primaryTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selectedColor: AppColors.accentBlue,
                        backgroundColor: cardBg,
                        side: BorderSide(
                          color: state.filterStatus == null
                              ? AppColors.accentBlue
                              : borderColor,
                        ),
                        onSelected: (_) => vm.setFilter(null),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: state.filterStatus == 'in_progress',
                        label: Text(
                          context.tr('activeRepairs'),
                          style: TextStyle(
                            color: state.filterStatus == 'in_progress'
                                ? Colors.white
                                : primaryTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selectedColor: AppColors.accentBlue,
                        backgroundColor: cardBg,
                        side: BorderSide(
                          color: state.filterStatus == 'in_progress'
                              ? AppColors.accentBlue
                              : borderColor,
                        ),
                        onSelected: (_) => vm.setFilter('in_progress'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: state.filterStatus == 'completed',
                        label: Text(
                          context.tr('serviceHistory'),
                          style: TextStyle(
                            color: state.filterStatus == 'completed'
                                ? Colors.white
                                : primaryTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selectedColor: AppColors.accentBlue,
                        backgroundColor: cardBg,
                        side: BorderSide(
                          color: state.filterStatus == 'completed'
                              ? AppColors.accentBlue
                              : borderColor,
                        ),
                        onSelected: (_) => vm.setFilter('completed'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AppFirestorePaginatedListView<ServiceJobModel>(
                items: state.jobs,
                isInitialLoading: state.isLoading,
                isFetchingNextPage: state.isFetchingNextPage,
                hasMore: state.hasMore,
                errorMessage: state.errorMessage,
                onRefresh: vm.refresh,
                onPrefetchNextPage: vm.fetchNextPage,
                emptyState: AppEmptyState(
                  title: state.filterStatus == 'in_progress'
                      ? context.tr('noActiveRepairsInProgress')
                      : state.filterStatus == 'completed'
                      ? context.tr('noCompletedServiceHistory')
                      : context.tr('noRepairOrdersFound'),
                  message: context.tr('whenYouCheckVehicleDesc'),
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
          ],
        ),
      ),
    );
  }
}
