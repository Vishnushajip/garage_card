import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_firestore_paginated_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/utils/debouncer.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/active_job_card.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/completed_job_card.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/jobs_analytics_view.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import '../ViewModel/merchant_jobs_view_model.dart';
import 'merchant_create_job_screen.dart';
import 'merchant_job_detail_screen.dart';

class MerchantJobsScreen extends ConsumerStatefulWidget {
  const MerchantJobsScreen({super.key});

  @override
  ConsumerState<MerchantJobsScreen> createState() => _MerchantJobsScreenState();
}

class _MerchantJobsScreenState extends ConsumerState<MerchantJobsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Debouncer _debouncer = Debouncer();

  @override
  void dispose() {
    _debouncer.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showCreateJobPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MerchantCreateJobScreen()),
    );
  }

  void _navigateToDetail(BuildContext context, String jobId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MerchantJobDetailScreen(jobId: jobId)),
    );
  }

  String _tabTitle(BuildContext context, int index) {
    switch (index) {
      case 1:
        return context.tr('pendingJobs');
      case 2:
        return context.tr('inProgressJobs');
      case 3:
        return context.tr('completedJobsTab');
      case 4:
        return context.tr('analyticsRevenueTab');
      default:
        return context.tr('allJobs');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final state = ref.watch(merchantJobsViewModelProvider);
    final vm = ref.read(merchantJobsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final invoiceMap = <String, InvoiceModel>{};
    for (final inv in state.invoices) {
      if (inv.jobId.isNotEmpty) {
        invoiceMap[inv.jobId] = inv;
      }
    }

    final isAnalyticsTab = state.activeTabIndex == 4;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('jobsManagement'),
        subtitle: isAnalyticsTab
            ? context.tr('revenueFinancialAnalytics')
            : (state.activeTabIndex == 0
                  ? context.tr('workshopOrdersRepairs')
                  : '${_tabTitle(context, state.activeTabIndex)} ${context.tr('orders')}'),
        showChat: true,
        showNotifications: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: context.tr('refresh'),
            onPressed: () => vm.refresh(),
          ),
        ],
      ),
      body: AppResponsiveLayout(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _searchCtrl,
                      hint: context.tr('searchJobsHint'),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                vm.search('');
                              },
                            )
                          : null,
                      onChanged: (val) {
                        _debouncer.run(() => vm.search(val));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.activeTabIndex != 0
                            ? AppColors.accentBlue
                            : borderColor,
                        width: state.activeTabIndex != 0 ? 1.5 : 1,
                      ),
                    ),
                    child: PopupMenuButton<int>(
                      tooltip: context.tr('filterJobs'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: borderColor),
                      ),
                      color: cardBg,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: state.activeTabIndex != 0
                            ? AppColors.accentBlue
                            : primaryTextColor,
                        size: 22,
                      ),
                      onSelected: (int index) {
                        vm.setActiveTab(index);
                      },
                      itemBuilder: (BuildContext popupCtx) => [
                        _buildFilterItem(
                          0,
                          context.tr('allJobs'),
                          Icons.all_inbox_rounded,
                          state.activeTabIndex == 0,
                        ),
                        _buildFilterItem(
                          1,
                          context.tr('pendingJobs'),
                          Icons.schedule_rounded,
                          state.activeTabIndex == 1,
                        ),
                        _buildFilterItem(
                          2,
                          context.tr('inProgressJobs'),
                          Icons.build_circle_outlined,
                          state.activeTabIndex == 2,
                        ),
                        _buildFilterItem(
                          3,
                          context.tr('completedJobsTab'),
                          Icons.check_circle_outline_rounded,
                          state.activeTabIndex == 3,
                        ),
                        const PopupMenuDivider(),
                        _buildFilterItem(
                          4,
                          context.tr('analyticsRevenueTab'),
                          Icons.analytics_outlined,
                          state.activeTabIndex == 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state.activeTabIndex != 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tabTitle(context, state.activeTabIndex),
                            style: AppFonts.labelSmall(
                              color: AppColors.accentBlue,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => vm.setActiveTab(0),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${state.jobs.length} ${context.tr('jobsCount')}',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            if (!isAnalyticsTab) ...[
              Expanded(
                child: AppFirestorePaginatedListView<ServiceJobModel>(
                  items: state.jobs,
                  isInitialLoading: state.isLoading,
                  isFetchingNextPage: state.isFetchingNextPage,
                  hasMore: state.hasMore,
                  onPrefetchNextPage: vm.fetchNextPage,
                  onRefresh: vm.refresh,
                  errorMessage: state.errorMessage,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  emptyState: AppEmptyState(
                    title: context.tr('noJobsFound'),
                    message: state.activeTabIndex == 3
                        ? context.tr('completedJobsEmptyMsg')
                        : context.tr('activeJobsEmptyMsg'),
                    icon: Icons.two_wheeler_rounded,
                    actionLabel: context.tr('newJobOrder'),
                    onAction: () => _showCreateJobPage(context),
                  ),
                  itemBuilder: (ctx, job, index) {
                    if (state.activeTabIndex == 3 ||
                        job.status.toLowerCase() == 'completed' ||
                        job.status.toLowerCase() == 'closed' ||
                        job.status.toLowerCase() == 'delivered') {
                      return CompletedJobCard(
                        job: job,
                        invoice: invoiceMap[job.id],
                        onViewDetails: () => _navigateToDetail(context, job.id),
                      );
                    }

                    return ActiveJobCard(
                      job: job,
                      onViewDetails: () => _navigateToDetail(context, job.id),
                    );
                  },
                ),
              ),
            ] else ...[
              const Expanded(child: JobsAnalyticsView()),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateJobPage(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('newJob')),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  PopupMenuItem<int> _buildFilterItem(
    int value,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? AppColors.accentBlue : null),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.accentBlue : null,
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_rounded,
              size: 18,
              color: AppColors.accentBlue,
            ),
        ],
      ),
    );
  }
}
