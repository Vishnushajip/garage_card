import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading_state.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

import '../ViewModel/service_recalls_view_model.dart';
import '../Widgets/recall_vehicle_card.dart';

class MerchantRecallsScreen extends ConsumerWidget {
  const MerchantRecallsScreen({super.key});

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: AppFonts.titleLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppFonts.labelSmall(color: secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(serviceRecallsViewModelProvider);
    final vm = ref.read(serviceRecallsViewModelProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('serviceRecalls'),
        subtitle: context.tr('recallsSubtitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: context.tr('refresh'),
            onPressed: () => vm.refresh(),
          ),
        ],
      ),
      body: state.isLoading
          ? const AppLoadingState()
          : AppResponsiveLayout(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isDesktop = constraints.maxWidth >= 600;
                        return Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context: context,
                                label: context.tr('overdue'),
                                value: '${state.overdueCount}',
                                icon: Icons.warning_amber_rounded,
                                color: AppColors.primaryRed,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                primaryText: primaryText,
                                secondaryText: secondaryText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricCard(
                                context: context,
                                label: context.tr('dueThisMonth'),
                                value: '${state.dueThisMonthCount}',
                                icon: Icons.event_repeat_rounded,
                                color: AppColors.accentAmber,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                primaryText: primaryText,
                                secondaryText: secondaryText,
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildMetricCard(
                                  context: context,
                                  label: 'Total Monitored',
                                  value: '${state.totalRecalls}',
                                  icon: Icons.history_rounded,
                                  color: AppColors.accentBlue,
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                  primaryText: primaryText,
                                  secondaryText: secondaryText,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            hint: 'Search vehicle plate, customer, phone...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 20,
                            ),
                            onChanged: vm.setSearchQuery,
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
                              color: state.filterStatus != 'all'
                                  ? AppColors.primaryRed
                                  : borderColor,
                              width: state.filterStatus != 'all' ? 1.5 : 1,
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            tooltip: 'Filter by Status',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: borderColor),
                            ),
                            color: cardBg,
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: state.filterStatus != 'all'
                                  ? AppColors.primaryRed
                                  : primaryText,
                              size: 22,
                            ),
                            onSelected: vm.setFilterStatus,
                            itemBuilder: (ctx) => [
                              PopupMenuItem<String>(
                                value: 'all',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.all_inbox_rounded,
                                      size: 18,
                                      color: AppColors.accentBlue,
                                    ),
                                    const SizedBox(width: 10),
                                    Text('All (${state.items.length})'),
                                    if (state.filterStatus == 'all') ...[
                                      const Spacer(),
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: AppColors.accentBlue,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'overdue',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 18,
                                      color: AppColors.primaryRed,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${context.tr("overdue")} (${state.overdueCount})',
                                    ),
                                    if (state.filterStatus == 'overdue') ...[
                                      const Spacer(),
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: AppColors.primaryRed,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'dueThisMonth',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: AppColors.accentAmber,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${context.tr("dueThisMonth")} (${state.dueThisMonthCount})',
                                    ),
                                    if (state.filterStatus ==
                                        'dueThisMonth') ...[
                                      const Spacer(),
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: AppColors.accentAmber,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (state.filterStatus != 'all')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (state.filterStatus == 'overdue'
                                            ? AppColors.primaryRed
                                            : AppColors.accentAmber)
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      (state.filterStatus == 'overdue'
                                              ? AppColors.primaryRed
                                              : AppColors.accentAmber)
                                          .withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.filterStatus == 'overdue'
                                        ? context.tr('overdue')
                                        : context.tr('dueThisMonth'),
                                    style: AppFonts.labelSmall(
                                      color: state.filterStatus == 'overdue'
                                          ? AppColors.primaryRed
                                          : AppColors.accentAmber,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => vm.setFilterStatus('all'),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: state.filterStatus == 'overdue'
                                          ? AppColors.primaryRed
                                          : AppColors.accentAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    if (state.filteredItems.isEmpty)
                      AppEmptyState(
                        icon: Icons.done_all_rounded,
                        title: context.tr('noVehiclesDue'),
                        message: 'Vehicles previously serviced at your workshop will appear here as they approach their periodic maintenance intervals.',
                        actionLabel: 'Refresh',
                        onAction: () => vm.refresh(),
                      )
                    else
                      ListView.builder(
                        itemCount: state.filteredItems.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          final item = state.filteredItems[index];
                          return RecallVehicleCard(item: item);
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
